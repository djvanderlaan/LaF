# Copyright 2011, 2013 Jan van der Laan
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
# Class definition of laf-object
# Methods are defined below
#
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
setMethod(
    f = "begin",
    signature = "laf",
    definition = function(x, ...) {
        .Call("laf_reset", as.integer(x@file_id))
        return(invisible(NULL))
    }
)

# =============================================================================
# Go to a specific line of the file
#
setMethod(
    f = "goto",
    signature = c("laf", "numeric"),
    definition = function(x, i, ...) {
        .Call("laf_goto_line", as.integer(x@file_id), as.integer(i))
        return(invisible(NULL))
    }
)

# =============================================================================
# Get the position in the file
#
setMethod(
    f = "current_line",
    signature = "laf",
    definition = function(x) {
        result <- .Call("laf_current_line", as.integer(x@file_id))
        return(result)
    }
)

# =============================================================================
# Get the number of lines in the file
#
setMethod(
    f = "nrow",
    signature = "laf",
    definition = function(x) {
        nrow <- .Call("laf_nrow", as.integer(x@file_id))
        return(nrow)
    }
)

# =============================================================================
# Get the number of columns in the file
#
setMethod(
    f = "ncol",
    signature = "laf",
    definition = function(x) {
        return(length(x@column_types))
    }
)

# =============================================================================
# Get the names of the columns in the file
#
setMethod(
    f = "names",
    signature = "laf",
    definition = function(x) {
        return(x@column_names)
    }
)

# =============================================================================
# Set the names of the columns in the file
#
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

# =============================================================================
# Print the laf object
#
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

# =============================================================================
# Reads the next block of lines from the file connection
#
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
        lines_read <- .Call("laf_next_block", as.integer(x@file_id), 
            as.integer(nrows), as.integer(columns-1), df)
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

# =============================================================================
# Reads data from the file connection
#
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
        lines_read <- .Call("laf_read_lines", as.integer(x@file_id), 
            as.integer(rows), as.integer(columns-1), df)
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

# =============================================================================
# Blockwise processing of blocks
#
setMethod(
    f = "process_blocks",
    signature = "laf",
    definition = function(x, fun, columns = 1:ncol(x), nrows = 5000, 
            allow_interupt = FALSE, ...) {
        if (!all(columns %in% 1:ncol(x)))
            stop("column out of range.")
        result <- NULL
        begin(x)
        while (TRUE) {
            df     <- next_block(x, columns = columns, nrows = nrows);
            result <- fun(df, result, ...)
            if (allow_interupt) {
                stop <- result[[1]]
                result <- result[[2]]
                if (stop) break;
            }

            if (nrow(df) == 0) break
        }
        return(result)
    }
)

# =============================================================================
# Extract elements from the data file
#
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

# =============================================================================
# Return the levels of the columns of the data.set
# 
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

# =============================================================================
# Change the levels of the columns of the data.set
# 
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


# =============================================================================
# Close file
#
setMethod(
    f = "close",
    signature = "laf",
    definition = function(con, ...) {
        .Call("laf_close", as.integer(con@file_id))
        return(invisible(NULL))
    }
)

