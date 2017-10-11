# Copyright 2011, 2013, 2014 Jan van der Laan
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

#' @include generics.R
#' @import methods
#' @importFrom Rcpp evalCpp
{}

#' Large File object
#'
#' A Large File object. This is a reference to a dataset on disk. The data
#' itself is not read into memory (yet). This can be done by the methods for
#' blockwise processing or by indexing the object as a data.frame. The code has
#' been optimised for fast access.
#'
#' @section Objects from the Class:
#' Objects can be created by opening a file using one of the methods 
#' \code{\link{laf_open_csv}} or \code{\link{laf_open_fwf}}. These create a 
#' reference to either a CSV file or a fixed width file. The data in these
#' files can either be accessed using blockwise operations using the methods
#' \code{begin}, \code{next_block} and \code{goto}. Or by indexing the laf 
#' object as you would a data.frame. In the following example a CSV file
#' is opened and its first column (of type integer) is read into memory:
#' \preformatted{
#'    laf <- laf_open_csv("file.csv", column_types=c("integer", "double"))
#'    data <- laf[ , 1]
#'  }
#' 
#' @export
setClass(
    Class = "laf",
    representation = representation(
        file_id = "integer",
        filename = "character",
        file_type = "character",
        column_names = "character",
        column_types = "integer",
        column_widths = "integer",
        levels = "list",
        options = "list"
    )
)


# =============================================================================
# Return to the beginning of the file
#

#' @rdname begin
#' @useDynLib LaF
#' @export
setMethod(
    f = "begin",
    signature = "laf",
    definition = function(x, ...) {
        .Call("laf_reset", PACKAGE="LaF", as.integer(x@file_id))
        return(invisible(NULL))
    }
)

# =============================================================================
# Go to a specific line of the file
#

#' @rdname goto
#' @useDynLib LaF
#' @export
setMethod(
    f = "goto",
    signature = c("laf", "numeric"),
    definition = function(x, i, ...) {
        .Call("laf_goto_line", PACKAGE="LaF", as.integer(x@file_id), 
          as.integer(i))
        return(invisible(NULL))
    }
)

# =============================================================================
# Get the position in the file
#

#' @rdname current_line
#' @useDynLib LaF
#' @export
setMethod(
    f = "current_line",
    signature = "laf",
    definition = function(x) {
        result <- .Call("laf_current_line", PACKAGE="LaF", 
          as.integer(x@file_id))
        return(result)
    }
)

#' Get the number of rows in a Large File object
#' @param x a \code{"\link[=laf-class]{laf}"} object. 
#' @rdname nrow
#' @useDynLib LaF
#' @export
setMethod(
    f = "nrow",
    signature = "laf",
    definition = function(x) {
        nrow <- .Call("laf_nrow", PACKAGE="LaF", as.integer(x@file_id))
        return(nrow)
    }
)

#' Get the number of columns in a Large File object
#' @param x a \code{"\link[=laf-class]{laf}"} object. 
#' @rdname ncol
#' @export
setMethod(
    f = "ncol",
    signature = "laf",
    definition = function(x) {
        return(length(x@column_types))
    }
)

#' Get and set the names of the columns in a Large File object
#' @param x a \code{"\link[=laf-class]{laf}"} object. 
#' @param value a character vector with the new column names 
#' @rdname names
#' @export
setMethod(
    f = "names",
    signature = "laf",
    definition = function(x) {
        return(x@column_names)
    }
)

#' @rdname names
#' @export
setMethod(
    f = "names<-",
    signature = "laf",
    definition = function(x, value) {
        if (!is.character(value)) 
            stop("Column names should be of type character.")
        if (length(value) != ncol(x))
            stop("Number of names does not match the number of columns") 
        x@column_names <- value
        return(x)
    }
)

#' Print the Large File object to screen
#' @rdname show
#' @export
setMethod(
    f = "show",
    signature = "laf",
    definition = function(object) {
       if (object@file_type == "fwf") {
           cat("Connection to fixed width ASCII file\n")
       } else {
           cat("Connection to comma separated ASCII file\n")
       }
       cat("  Filename: ", object@filename, "\n", sep="")
       for (i in 1:ncol(object)) {
           cat("  Column ", i, ":",
               " name = ", object@column_names[i], 
               ", type = ", .laf_to_type(object@column_types[i]),
               ", internal type = ", .laf_to_rtype(object@column_types[i]), sep="")
           if (object@file_type == "fwf")
               cat(", column width = ", object@column_widths[i], sep="")
           cat("\n")
       }
    }
)

#' @param columns an integer vector with the columns that should be read in.
#' @param nrows the (maximum) number of rows to read in one block
#' @rdname next_block
#' @useDynLib LaF
#' @export
setMethod(
    f = "next_block",
    signature = "laf",
    definition = function(x, columns = 1:ncol(x), nrows = 5000, ...) {
        # check nrows
        if (!is.numeric(nrows) | nrows[1] < 1)
            stop("nrows should be a positive numeric vector")
        nrows <- nrows[1]
        # check columns
        if (!is.numeric(columns)) 
            stop("columns should be a numeric vector")
        if (!all(columns %in% 1:ncol(x)))
            stop("column out of range.")
        # initialize data.frame
        types      <- .laf_to_rtype(x@column_types[columns])
        df         <- lapply(types, do.call, list(nrows))
        names(df)  <- x@column_names[columns]
        df         <- as.data.frame(df, stringsAsFactors=FALSE)
        # read
        lines_read <- .Call("laf_next_block", PACKAGE="LaF", 
          as.integer(x@file_id), as.integer(nrows), as.integer(columns-1), df)
        if (lines_read < nrows) {
            if (lines_read == 0) {
                df <- df[FALSE, , drop=FALSE]
            } else {
                df <- df[1:lines_read, , drop=FALSE]
            }
        } 
        # convert factor columns to factor columns
        for (i in seq_along(df)) {
            levels <- levels(x[[columns[i]]])
            if (nrow(levels) > 0) {
                df[[i]] <- factor(df[[i]], levels=levels$levels,
                    labels=levels$labels)
            }
        }
        return(df)
    }
)

#' @param rows a numeric vector with the rows that should be read from the
#'   file. 
#' @param columns an integer vector with the columns that should be read in.
#' @rdname read_lines
#' @useDynLib LaF
#' @export
setMethod(
    f = "read_lines",
    signature = "laf",
    definition = function(x, rows, columns = 1:ncol(x), ...) {
        # check rows
        if (!is.numeric(rows))
            stop("rows should be a numeric vector")
        if (any(rows < 1))
            stop("rows contains values < 1")
        rows       <- rows-1
        # check columns
        if (!is.numeric(columns)) 
            stop("columns should be a numeric vector")
        if (!all(columns %in% 1:ncol(x)))
            stop("column out of range.")
        types      <- .laf_to_rtype(x@column_types[columns])
        # initialize data.frame
        df         <- lapply(types, do.call, list(length(rows)))
        names(df)  <- x@column_names[columns]
        df         <- as.data.frame(df, stringsAsFactors=FALSE)
        # read
        lines_read <- .Call("laf_read_lines", PACKAGE="LaF", 
          as.integer(x@file_id), as.integer(rows), as.integer(columns-1), df)
        if (lines_read < length(rows)) {
            warning("Number of rows read is smaller than the ",
                "number of rows specified.")
            if (lines_read == 0) {
                df <- df[FALSE, , drop=FALSE]
            } else {
                df <- df[1:lines_read, , drop=FALSE]
            }
        } 
        # convert factor columns to factor columns
        for (i in seq_along(df)) {
            levels <- levels(x[[columns[i]]])
            if (nrow(levels) > 0) {
                df[[i]] <- factor(df[[i]], levels=levels$levels,
                    labels=levels$labels)
            }
        }
        return(df)
    }
)

#' @param columns an integer vector with the columns that should be read in.
#' @param nrows the (maximum) number of rows to read in one block
#' @param allow_interupt when TRUE the function \code{fun} is expected to 
#'   return a list. The second element is the result of the function. The first
#'   element should be a logical value indication whether \code{process_blocks}
#'   should continue (FALSE) or stop (TRUE). When interupted the function is 
#'   not called a last time with an empty \code{data.frame} to finalize the 
#'   result.
#' @param progress show a progress bar. Note that this triggers a calculation
#'   of the number of lines in the file which for CSV files can take some time. 
#'   When numeric \code{code} is used as the style of the progress bar (see
#'   \code{\link[utils]{txtProgressBar}}). 
#' @rdname process_blocks
#' @export
setMethod(
  f = "process_blocks",
  signature = "laf",
  definition = function(x, fun, columns = 1:ncol(x), nrows = 5000, 
        allow_interupt = FALSE, progress = FALSE, ...) {
    if (!all(columns %in% 1:ncol(x)))
      stop("column out of range.")
    
    if (progress) {
      nmax <- nrow(x)  
      nprocessed <- 0
      style <- if (is.numeric(progress)) progress else 3
      pb <- txtProgressBar(max = nmax, style = style)
    }
  
    result <- NULL
    begin(x)
    while (TRUE) {
      df     <- next_block(x, columns = columns, nrows = nrows);
      result <- fun(df, result, ...)
      
      if (progress) { 
        nprocessed <- nprocessed + nrow(df)
        setTxtProgressBar(pb, nprocessed)
      }
      
      if (allow_interupt) {
        stop <- result[[1]]
        result <- result[[2]]
        if (stop) break;
      }

      if (nrow(df) == 0) break
    }
    if (progress) close(pb)
    return(result)
  }
)

#' Read records from a large file object into R
#'
#' When a connection is opened to a \code{"\link[=laf-class]{laf}"} object; this
#' object can then be indexed roughly as one would a \code{data.frame}. 
#'
#' @param x an object of type \code{"\link[=laf-class]{laf}"} or
#'   \code{"\link[=laf_column-class]{laf_column}"}. 
#' @param i an logical or numeric vector with indices. The rows which should be
#'   selected. 
#' @param j a numeric vector with the columns to select. 
#' @param drop a logical indicating whether or not to convert the result to a
#'   vector when only one column is selected. As in when indexing a
#'   \code{data.frame}.
#'
#' @rdname indexing
#' @export
setMethod(
    f = "[",
    signature = "laf",
    definition = function(x, i, j, drop) {
        # process and check i
        if (missing(i)) {
            rows <- NULL
        } else if (is.logical(i)) {
            rows <- which(i)
        } else if (is.numeric(i)) {
            rows <- i
        }
        # process and check j
        if (missing(j)) {
            columns <- seq_len(ncol(x))
        } else if (is.logical(j)) {
            columns <- which(j)
        } else if (is.numeric(j)) {
            columns <- j
        } else if (is.character(j)) {
            columns <- match(j, names(x))
            if (any(is.na(columns)))
                stop("Invalid columns selected: ", 
                    paste(j[is.na(columns)], collapse=", "), ".")
        }
        # read data
        if (is.null(rows)) {
            begin(x)
            result <- next_block(x, nrows=nrow(x), columns=columns)
        } else {
            result <- read_lines(x, rows=rows, columns=columns)
        }
        return(result)
    }
)

#' Get and change the levels of the column in a Large File object 
#' @param x a \code{"\link[=laf-class]{laf}"} object. 
#' @param value a list with the levels for each column. 
#' @rdname levels
#' @export
setMethod(
    f = "levels",
    signature = "laf",
    definition = function(x) {
        levels <- list()
        for (i in 1:ncol(x)) {
            levels[[i]] <- levels(x[[i]]) 
        }
        names(levels) <- names(x)
        return(levels)
    }
)

#' @rdname levels
#' @export
setMethod(
    f = "levels<-",
    signature = "laf",
    definition = function(x, value) {
        old_levels <- levels(x)
        for (i in names(value)) {
          if (!identical(old_levels[[i]], value[[i]]))
              x@levels[[i]] <- value[[i]]
        }
        return(x)
    }
)


#' Close the connection to the Large File
#' @param con a \code{"\link[=laf-class]{laf}"} object that can be closed.
#' @param ... unused.
#' @rdname close
#' @useDynLib LaF
#' @export
setMethod(
    f = "close",
    signature = "laf",
    definition = function(con, ...) {
        .Call("laf_close", PACKAGE="LaF", as.integer(con@file_id))
        return(invisible(NULL))
    }
)

