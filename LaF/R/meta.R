# Copyright 2012 Jan van der Laan
#
# This file is part of LaF.
#
# LaF is free software: you can redistribute it and/or modify it under the terms
# of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# LaF is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# LaF.  If not, see <http://www.gnu.org/licenses/>.


detect_dm_csv <- function(filename, sep=",", dec=".", header=FALSE, 
        nrow=1000, nlines=NULL, sample=FALSE, factor_fraction=0.4, ...) {
    if (sample) {
        lines <- sample_lines(filename, n=nrow, nlines=nlines)
        con <- textConnection(lines)
    } else con <- file(filename, "rt")
    data  <- read.table(con, nrow=nrow, sep=sep, dec=dec, header=header, ...)
    close(con)
    name <- names(data)
    type <- sapply(data, function(d) {
        type <- class(d)
        if (identical(type, "factor")) {
            f <- nlevels(d)/length(d)
            if (f > factor_fraction) {
                type <- "string"
            } else {
                type <- "categorical"
            }
        }
        if (identical(type, "numeric"))   type <- "double"
        if (identical(type, "character")) type <- "string"
        return(type)
    })
    return(list(
        type = "csv",
        filename = filename,
        columns = data.frame(name=name, type=type, stringsAsFactors=FALSE),
        dec = dec,
        sep = sep,
        skip = ifelse(header, 1, 0)
    ))
}

read_dm <- function(filename, ...) {
    if (!require("yaml")) 
        stop("The library yaml is required to read and write data models.")
    model <- yaml.load_file(filename)
    # columns are stored rowwise in file convert to column wise
    columns <- model$columns
    model$columns <- list()
    if (length(columns)) {
        for (col in names(columns[[1]])) {
            model$columns[[col]] <- sapply(columns, function(d) d[[col]])
        }
    }
    model$columns <- as.data.frame(model$columns, stringsAsFactors=FALSE)
    # overwrite options in file by extra options given in call
    model[names(list(...))] <- list(...)
    return(model)
}

write_dm <- function(model, filename) {
    if (!require("yaml")) 
        stop("The library yaml is required to read and write data models.")
    # if model is a laf object, build data model from laf object
    if (inherits(model, "laf")) {
        laf <- model
        model <- list()
        model$type <- laf@file_type
        model$filename <- laf@filename
        model[names(laf@options)] <- laf@options
        model$columns <- data.frame(name=laf@column_names,
            type=.laf_to_type(laf@column_types))
        if (length(laf@column_widths)) 
            model$columns$width <- laf@column_widths
    }
    # write model to file in yaml format
    writeLines(as.yaml(model, column.major=F), con=filename)
}

laf_open <- function(model, ...) {
    model[names(list(...))] <- list(...)
    model$column_names  <- model$columns$name
    model$column_types <- model$columns$type
    if (is.null(model$type)) stop("Type is missing from data model")
    if (identical(model$type, "csv")) {
        open <- "laf_open_csv"
    } else if (identical(model$type, "fwf")) {
        model$column_widths <- model$columns$width
        open <- "laf_open_fwf"
    }
    model$type    <- NULL
    model$columns <- NULL
    laf <- do.call(open, model)
    return (laf)
}

