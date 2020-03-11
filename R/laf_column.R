# Copyright 2011 Jan van der Laan
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

#' @include laf.R
{}

#' Column of a Large File Object
#' 
#' Representation of a column in a Large File object. This class itself is a
#' subclass of the class \code{laf}. In principle all methods that can be used
#' with a \code{laf} object can also be used with a \code{laf_column} object
#' except the the \code{column} or \code{columns} arguments of these methods are
#' not needed. 
#' 
#' @section Objects from the Class:
#' Object of this class are usually created by using the \code{$} operator on
#' \code{laf} objects. 
#'
#' @export
setClass(
    Class = "laf_column",
    contains = "laf",
    representation = representation(
        column = "integer"
    )
)

#' Print a column of a Large File object to screen
#' @param object the object to print to screen.
#' @rdname show
#' @export
setMethod(
    f = "show", 
    signature = "laf_column", 
    definition = function(object) {
        cat("Column number ", object@column, " of ", sep="")
        if (object@file_type == "fwf") {
            cat("fixed width ASCII file\n")
        } else {
            cat("comma separated ASCII file\n")
        }
        cat("  Filename: ", object@filename, "\n", sep="")
        cat("  Column name = ", object@column_names[object@column], "\n", sep="") 
        cat("  Column type = ", .laf_to_type(object@column_types[object@column]), "\n", sep="") 
        cat("  Internal type = ", .laf_to_rtype(object@column_types[object@column]), "\n", sep="") 
        if (object@file_type == "fwf")
            cat("  Column width = ", object@column_widths[object@column], "\n", sep="")
        cat("Showing first 10 elements:\n")
        begin(object)
        print(next_block(object, nrows=10))
    }
)

#' Select a column from a LaF object
#' 
#' Selecting columns from an \code{laf} object works as it does for a 
#' \code{data.frame}.
#' 
#' @param x an object of type \code{laf}
#' @param i index of column to select. This should be a numeric or character
#'   vector. 
#'
#' @return
#' Returns an object of type \code{laf_column}. This object behaves almost the
#' same as an \code{laf} object except that is it no longer necessary 
#' (or possible) to specify which column should be used for functions that 
#' require this. 
#' 
#' @rdname cindexing
#' @export
setMethod(
    f = "[[",
    signature = "laf",
    definition = function(x, i) {
        if (length(i) != 1) 
            stop("Index should have length 1.")
        column <- i
        if (is.character(i)) {
            column <- match(i, names(x))
            if (is.na(column))
                stop("Column with name '", i, "' does not exist.")
        }
        if (!is.numeric(column)) 
            stop("Column should be numeric.")
        result <- new(Class="laf_column", 
            file_id = x@file_id,
            filename = x@filename, 
            file_type = x@file_type,
            column_types = x@column_types,
            column_names = x@column_names,
            column_widths = x@column_widths,
            column = as.integer(column),
            levels = x@levels,
            options = x@options
        )
        return(result)
    }
)

#' @param name the name of the column to select.
#'
#' @rdname cindexing
#' @export
setMethod(
    f = "$",
    signature = "laf",
    definition = function(x, name) {
        return(x[[name]])
    }
)

#' @rdname next_block
#' @export
setMethod(
    f = "next_block",
    signature = "laf_column",
    definition = function(x, nrows = 5000, ...) {
        result <- callNextMethod(x, columns=x@column, nrows=nrows, ...)
        return(result[,1])
    }
)

#' @rdname read_lines
#' @export
setMethod(
    f = "read_lines",
    signature = "laf_column",
    definition = function(x, rows, columns = 1:ncol(x), ...) {
        result <- callNextMethod(x, rows=rows, columns=x@column, ...)
        return(result[,1])
    }
)


#' @rdname indexing
#' @export
setMethod(
    f = "[",
    signature = c("laf_column", "ANY"),
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
        if (!missing(j))
            stop("Wrong number of dimensions")
        # read data
        if (is.null(rows)) {
            begin(x)
            result <- next_block(x, nrows=nrow(x))
        } else {
            result <- read_lines(x, rows=rows)
        }
        return(result)
    }
)

#' @rdname levels
#' @export
setMethod(
    f = "levels",
    signature = "laf_column",
    definition = function(x) {
        column_name <- x@column_names[x@column]
        levels <- x@levels[[column_name]]
        if (is.null(levels) || !nrow(levels)) {
            levels <- .Call("laf_levels", PACKAGE="LaF", as.integer(x@file_id), 
                    as.integer(x@column-1))
            levels <- data.frame(
                levels = levels$levels[order(levels$levels)],
                labels = levels$labels[order(levels$levels)])
                stringsAsFactors = FALSE
        }
        return(levels)
    }
)

#' @rdname levels
#' @export
setMethod(
    f = "levels<-",
    signature = "laf_column",
    definition = function(x, value) {
        x@levels[[x@column_names[x@column]]] <- value
        return(x)
    }
)


