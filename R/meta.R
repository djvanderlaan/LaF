# Copyright 2012, 2013 Jan van der Laan
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


#' Automatically detect data models for CSV-files
#' 
#' Automatically detect data models for CSV-files.  Opening of files using the
#' data models can be done using \code{\link{laf_open}}.
#' 
#' @param filename character containing the filename of the csv-file.
#' @param sep character vector containing the separator used in the file.
#' @param dec the character used for decimal points.
#' @param header does the first line in the file contain the column names.
#' @param nrows the number of lines that should be read in to detect the column
#'   types. The more lines the more likely that the correct types are detected.
#' @param nlines (only needed when the sample option is used) the expected number
#'   of lines in the file. If not specified the number of lines in the file is
#'   first calculated.
#' @param sample by default the first \code{nrows} lines are read in for
#'   determining the column types. When sample is used random lines from the file
#'   are used. This is more robust, but takes longer.
#' @param factor_fraction the fraction of unique string in a column below which
#'   the column is converted to a factor/categorical. For more information see
#'   details.
#' @param stringsAsFactors passed on to \code{\link{read.table}}. Set to 
#'   \code{FALSE} to read all text columns as character. In that case 
#'   \code{factor_fraction} is ignored. 
#' @param ... additional arguments are passed on to \code{\link{read.table}}.
#'   However, be careful with using these as some of these arguments are not
#'   supported by \code{\link{laf_open_csv}}.
#'
#' @details
#' The argument \code{factor_fraction} determines the fraction of unique strings
#' below which the column is converted to factor/categorical. If all column need
#' to be converted to character a value larger than one can be used. A value
#' smaller than zero will ensure that all columns will be converted to
#' categorical. Note that LaF stores the levels of a categorical in memory.
#' Therefore, for categorical columns with a very large number of (almost) unique
#' levels can cause memory problems. 
#' 
#' @return
#' \code{read_dm} returns a data model which can be used by
#' \code{\link{laf_open}}. The data model can be written to file using
#' \code{\link{write_dm}}.
#' 
#' @seealso
#' See \code{\link{write_dm}} to write the data model to file.  The data models
#' can be used to open a file using \code{\link{laf_open}}.
#' 
#' @examples
#' # Create temporary filename
#' tmpcsv  <- tempfile(fileext="csv")
#'
#' # Generate test data
#' ntest <- 10
#' column_types <- c("integer", "integer", "double", "string")
#' testdata <- data.frame(
#'     a = 1:ntest,
#'     b = sample(1:2, ntest, replace=TRUE),
#'     c = round(runif(ntest), 13),
#'     d = sample(c("jan", "pier", "tjores", "corneel"), ntest, replace=TRUE),
#'     stringsAsFactors = FALSE
#'     )
#' # Write test data to csv file
#' write.table(testdata, file=tmpcsv, row.names=FALSE, col.names=TRUE, sep=',')
#' 
#' # Detect data model
#' model <- detect_dm_csv(tmpcsv, header=TRUE)
#' 
#' # Create LaF-object
#' laf <- laf_open(model)
#'
#' # Cleanup
#' file.remove(tmpcsv)
#'
#' @importFrom utils read.table 
#' @export
detect_dm_csv <- function(filename, sep=",", dec=".", header=FALSE, 
        nrows=1000, nlines=NULL, sample=FALSE, stringsAsFactors = TRUE, 
        factor_fraction=0.4, ...) {
    if (sample) {
        lines <- sample_lines(filename, n=nrows, nlines=nlines)
        con <- textConnection(lines)
    } else con <- file(filename, "rt")
    data  <- read.table(con, nrows=nrows, sep=sep, dec=dec, header=header, 
      stringsAsFactors = stringsAsFactors, ...)
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
        } else if (identical(type, "numeric")) {
            type <- "double"
        } else if (identical(type, "character")) {
            type <- "string"
        } else if (identical(type, "integer")) {
        } else {
            warning("Unsupported type '", type, 
                "'; using default type 'string'")
            type <- "string"
        }
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


#' Read and write data models for LaF
#' 
#' Using these routines data models can be written and read. These data models
#' can be used to create LaF object without the need to specify all arguments
#' (column names, column types etc.). Opening of files using the data models can
#' be done using \code{\link{laf_open}}.
#'
#' @param modelfile character containing the filename of the file the model is to
#'   be written to/read from.
#' @param model a data model or an object of type \code{\linkS4class{laf}}. See
#'   details for more information.
#' @param ... additional arguments are added to the data model or, when they are
#'   also present in the file are used to overwrite the values specified in the
#'   file.
#' 
#' @details
#' A data model is a list containing information which open routine should be
#' used (e.g. \code{\link{laf_open_csv}} or \code{\link{laf_open_fwf}}), and the
#' arguments needed for these routines. Required elements are `type', which can
#' (currently) be `csv', or `fwf', and `columns', which should be a
#' \code{data.frame} containing at least the columns `name' and `type', and for
#' fwf `width'. These columns correspond to the arguments \code{column_names},
#' \code{column_types} and \code{column_widths} respectively. Other arguments of
#' the \code{laf_open_*} routines can be specified as additional elements of the
#' list. 
#'
#' \code{write_dm} can also be used to write a data model that is created
#' from an object of type \code{\linkS4class{laf}}. This is probably one of the
#' easiest ways to create a data model.
#'
#' The data model is stored in a text file in YAML format which is a format in
#' which data structures can be stored in a readable and editable format. 
#'
#' @return
#' \code{read_dm} returns a data model which can be used by
#' \code{\link{laf_open}}. 
#'
#' @seealso
#' See \code{\link{detect_dm_csv}} for a routine which can automatically
#' create a data model from a CSV-file. The data models can be used to open a
#' file using \code{\link{laf_open}}.
#' 
#' @examples
#' # Create some temporary files
#' tmpcsv  <- tempfile(fileext="csv")
#' tmp2csv <- tempfile(fileext="csv")
#' tmpyaml <- tempfile(fileext="yaml")
#' 
#' # Generate test data
#' ntest <- 10
#' column_types <- c("integer", "integer", "double", "string")
#' testdata <- data.frame(
#'     a = 1:ntest,
#'     b = sample(1:2, ntest, replace=TRUE),
#'     c = round(runif(ntest), 13),
#'     d = sample(c("jan", "pier", "tjores", "corneel"), ntest, replace=TRUE)
#'     )
#' # Write test data to csv file
#' write.table(testdata, file=tmpcsv, row.names=FALSE, col.names=FALSE, sep=',')
#' 
#' # Create LaF-object
#' laf <- laf_open_csv(tmpcsv, column_types=column_types)
#' 
#' # Write data model to stdout() (screen)
#' write_dm(laf, stdout())
#' 
#' # Write data model to file
#' write_dm(laf, tmpyaml)
#' 
#' # Read data model and open file
#' laf2 <- laf_open(read_dm(tmpyaml))
#' 
#' # Write test data to second csv file
#' write.table(testdata, file=tmp2csv, row.names=FALSE, col.names=FALSE, sep=',')
#' 
#' # Read data model and open seconde file, demonstrating the use of the optional
#' # arguments to read_dm
#' laf2 <- laf_open(read_dm(tmpyaml, filename=tmp2csv))
#' 
#' # Cleanup
#' file.remove(tmpcsv)
#' file.remove(tmp2csv)
#' file.remove(tmpyaml)
#'
#' @rdname datamodels
#' @export
read_dm <- function(modelfile, ...) {
    if (!requireNamespace("yaml")) 
        stop("The library yaml is required to read and write data models.")
    model <- yaml::yaml.load_file(modelfile)
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

#' @rdname datamodels
#' @export
write_dm <- function(model, modelfile) {
    if (!requireNamespace("yaml")) 
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
    writeLines(yaml::as.yaml(model, column.major=F), con=modelfile)
}

#' Create a connection to a file using a data model.
#' 
#' Uses a data model to create a connection to a file. The data model contains
#' all the information needed to open the file (column types, column widths,
#' etc.). 
#' 
#' @param model a {data model}, such as one returned by \link{read_dm} or
#'   \link{detect_dm_csv}.
#' @param ... additional arguments can be used to overwrite the values specified
#'   by the data model. These are listed in the argument documentation for
#'   \code{\link{laf_open_csv}} and \code{\link{laf_open_fwf}}, e.g.
#'   see \code{ignore_failed_conversion}.
#' 
#' @details
#' Depending on the field `type' \code{laf_open} uses \code{\link{laf_open_csv}}
#' and \code{\link{laf_open_fwf}} to open the file. The data model should contain
#' all information needed by these routines to open the file.
#' 
#' @return
#' Object of type \code{\linkS4class{laf}}. Values can be extracted from this
#' object using indexing, and methods such as \code{\link{read_lines}},
#' \code{\link{next_block}}. 
#'
#' @seealso
#' See \code{\link{read_dm}} and \code{\link{detect_dm_csv}} for ways of creating
#' data models. 
#'
#'
#' @examples
#' # Create some temporary files
#' tmpcsv  <- tempfile(fileext="csv")
#' tmp2csv <- tempfile(fileext="csv")
#' tmpyaml <- tempfile(fileext="yaml")
#' 
#' # Generate test data
#' ntest <- 10
#' column_types <- c("integer", "integer", "double", "string")
#' testdata <- data.frame(
#'     a = 1:ntest,
#'     b = sample(1:2, ntest, replace=TRUE),
#'     c = round(runif(ntest), 13),
#'     d = sample(c("jan", "pier", "tjores", "corneel"), ntest, replace=TRUE)
#'     )
#' # Write test data to csv file
#' write.table(testdata, file=tmpcsv, row.names=FALSE, col.names=FALSE, sep=',')
#' 
#' # Create LaF-object
#' laf <- laf_open_csv(tmpcsv, column_types=column_types)
#' 
#' # Write data model to file
#' write_dm(laf, tmpyaml)
#' 
#' # Read data model and open file
#' laf <- laf_open(read_dm(tmpyaml))
#' 
#' # Write test data to second csv file
#' write.table(testdata, file=tmp2csv, row.names=FALSE, col.names=FALSE, sep=',')
#' 
#' # Read data model and open second file, demonstrating the use of the optional
#' # arguments to laf_open
#' laf2 <- laf_open(read_dm(tmpyaml), filename=tmp2csv)
#'
#' # Cleanup
#' file.remove(tmpcsv)
#' file.remove(tmp2csv)
#' file.remove(tmpyaml)
#'
#' @export
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

