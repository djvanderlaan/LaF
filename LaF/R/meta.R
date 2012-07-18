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
        nrows=1000, nlines=NULL, sample=FALSE, factor_fraction=0.4, ...) {
    if (sample) {
        lines <- sample_lines(filename, n=nrow, nlines=nlines)
        con <- textConnection(lines)
    } else con <- file(filename, "rt")
    data  <- read.table(con, nrows=nrows, sep=sep, dec=dec, header=header, ...)
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

read_dm <- function(modelfile, ...) {
    if (!require("yaml")) 
        stop("The library yaml is required to read and write data models.")
    model <- yaml.load_file(modelfile)
    # columns are stored rowwise in file convert to column wise
    columns <- data.frame()
    levels  <- list()
    for (i in seq_along(model$columns)) {
        column <- list()
        for (j in names(model$columns[[i]])) {
            if (j == "labels") {
                collevels <- sapply(model$columns[[i]][[j]], 
                    function(d) d[["level"]])
                collabels <- sapply(model$columns[[i]][[j]], 
                    function(d) d[["label"]])
                levels[[ model$columns[[i]]$name ]] <- data.frame(
                    levels=collevels, labels=collabels,
                    stringsAsFactors = FALSE)
                next
            }
            column[[j]] <- model$columns[[i]][[j]]
        }
        columns <- rbind(columns, as.data.frame(column, 
            stringsAsFactors=FALSE))
    }
    model$columns <- columns
    if (length(levels)) model$levels  <- levels
    # overwrite options in file by extra options given in call
    model[names(list(...))] <- list(...)
    return(model)
}

write_dm <- function(model, modelfile) {
    if (!require("yaml")) 
        stop("The library yaml is required to read and write data models.")
    # if model is a laf object, build data model from laf object
    if (inherits(model, "laf")) {
        laf <- model
        model <- list()
        model$type <- laf@file_type
        model$filename <- laf@filename
        model[names(laf@options)] <- laf@options
        model$columns <- list()
        for (i in seq_along(laf@column_names)) {
            col <- list()
            name <- laf@column_names[i]
            col[["name"]] <- laf@column_names[i]
            col[["type"]] <- .laf_to_type(laf@column_types[i])
            if (length(laf@column_widths)) 
                col[["width"]] <- laf@column_widths[i]
            if (!is.null(laf@levels[[name]]) && nrow(laf@levels[[name]])) {
                col[["labels"]] <- laf@levels[[name]]
                names(col[["labels"]]) <- c("level", "label")
            }
            model$columns[[name]] <- col
        }
        names(model$columns) <- NULL
    }
    # write model to file in yaml format
    writeLines(as.yaml(model, column.major=F), con=modelfile)
}

laf_open <- function(model, ...) {
    model[names(list(...))] <- list(...)
    model$column_names  <- model$columns$name
    model$column_types <- model$columns$type
    levels <- model$levels
    if (is.null(model$type)) stop("Type is missing from data model")
    if (identical(model$type, "csv")) {
        open <- "laf_open_csv"
    } else if (identical(model$type, "fwf")) {
        model$column_widths <- model$columns$width
        open <- "laf_open_fwf"
    }
    model$type    <- NULL
    model$columns <- NULL
    model$levels  <- NULL
    laf <- do.call(open, model)
    if (!is.null(levels)) {
        levels(laf)[names(levels)] <- levels
    }
    return (laf)
}

