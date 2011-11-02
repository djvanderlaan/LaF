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

# =============================================================================
# Class definition of laf_column
# Methods are defined below
#
setClass(
    Class = "laf_column",
    contains = "laf",
    representation = representation(
        column = "integer"
    )
)

# =============================================================================
# Print the laf_column object
#
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
        print(object[1:10])
    }
)

# =============================================================================
# Get a column in the data file.
#
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
            column = as.integer(column)
        )
        return(result)
    }
)

# =============================================================================
# Get a reference object to a column in the data file.
# 
setMethod(
    f = "$",
    signature = "laf",
    definition = function(x, name) {
        return(x[[name]])
    }
)

# =============================================================================
# Reads the next block of lines from the file connection
#
setMethod(
    f = "next_block",
    signature = "laf_column",
    definition = function(x, nrows = 5000, ...) {
        result <- callNextMethod(x, columns=x@column, nrows=nrows, ...)
        return(result[,1])
    }
)

# =============================================================================
# Reads the specified lines from the column in the data file. 
#
setMethod(
    f = "read_lines",
    signature = "laf_column",
    definition = function(x, rows, columns = 1:ncol(x), ...) {
        result <- callNextMethod(x, rows=rows, columns=x@column, ...)
        return(result[,1])
    }
)

# =============================================================================
# Extract elements from the data file
#
setMethod(
    f = "[",
    signature = "laf_column",
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

# =============================================================================
# Return the levels of the colum
# 
setMethod(
    f = "levels",
    signature = "laf_column",
    definition = function(x) {
        levels <- .Call("laf_levels", as.integer(x@file_id), 
                as.integer(x@column-1))
        levels <- names(levels)[order(levels)]
        return(levels)
    }
)

