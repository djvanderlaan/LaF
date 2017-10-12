# Copyright 2011-2012, 2014 Jan van der Laan
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


#' Calculate simple statistics of column
#'
#' Methods for calculating simple statistics of columns of a file: mean, sum,
#' standard deviation, range (min and max), and number of missing values. 
#'
#' @param x an object of type laf or laf_column.
#' @param columns a numeric vector with the columns for which the statistics
#'     should be calculated.
#' @param na.rm whether or not to ignore missing values. By default missing
#'     values are ignored.
#' @param useNA method with which to treat missing values: "ifany" adds a field
#'     containing the number of missing values if there are any; "always" will always
#'     add a field with the number of missing values even when there are none; "none"
#'     will never add a field containing the number of missing values.
#' @param ... Currently ignored.
#'
#' @rdname stats
#' @export
setGeneric(
    name = "colsum",
    def = function(x, ...) {
        standardGeneric("colsum")
    }
)

#' @rdname stats
#' @export
setMethod(
    f = "colsum",
    signature = "laf",
    definition = function(x, columns, na.rm=TRUE, ...) {
        # check columns
        if (!is.numeric(columns)) 
            stop("columns should be a numeric vector")
        if (!all(columns %in% 1:ncol(x)))
            stop("column out of range.")
        # check na.rm
        if (!is.logical(na.rm)) 
            stop("na.rm should be a logical vector")
        na.rm <- na.rm[1]
        # compute
        result <- .Call("colsum", PACKAGE="LaF", as.integer(x@file_id), 
          as.integer(columns-1))
        # contruct end result
        result <- sapply(result, function(a) {
            r <- a$sum
            if (!na.rm & a$missing) r <- NA
            return(r)
        })
        names(result) <- names(x)[columns]
        return(result)
    }
)

#' @rdname stats
#' @export
setMethod(
    f = "colsum",
    signature = "laf_column",
    definition = function(x, na.rm = TRUE, ...) {
      result <- callNextMethod(x, columns=x@column, na.rm=na.rm, ...)
      return(result)
    }
)

#' @rdname stats
#' @export
setGeneric(
    name = "colmean",
    def = function(x, ...) {
        standardGeneric("colmean")
    }
)

#' @rdname stats
#' @export
setMethod(
    f = "colmean",
    signature = "laf",
    definition = function(x, columns, na.rm=TRUE, ...) {
        # check columns
        if (!is.numeric(columns)) 
            stop("columns should be a numeric vector")
        if (!all(columns %in% 1:ncol(x)))
            stop("column out of range.")
        # check na.rm
        if (!is.logical(na.rm)) 
            stop("na.rm should be a logical vector")
        na.rm <- na.rm[1]
        # compute
        result <- .Call("colsum", PACKAGE="LaF", as.integer(x@file_id), 
          as.integer(columns-1))
        # contruct end result
        result <- sapply(result, function(a) {
            r <- a$sum/a$n
            if (!na.rm & a$missing) r <- NA
            return(r)
        })
        names(result) <- names(x)[columns]
        return(result)
    }
)

#' @rdname stats
#' @export
setMethod(
    f = "colmean",
    signature = "laf_column",
    definition = function(x, na.rm = TRUE, ...) {
      result <- callNextMethod(x, columns=x@column, na.rm=na.rm, ...)
      return(result)
    }
)

#' @rdname stats
#' @export
setGeneric(
    name = "colfreq",
    def = function(x, ...) {
        standardGeneric("colfreq")
    }
)

#' @rdname stats
#' @export
setMethod(
    f = "colfreq",
    signature = "laf",
    definition = function(x, columns, useNA=c("ifany", "always", "no"), ...) {
        # check columns
        if (!is.numeric(columns)) 
            stop("columns should be a numeric vector")
        if (!all(columns %in% 1:ncol(x)))
            stop("column out of range.")
        # check useNA
        if (!is.character(useNA) | !(useNA[1] %in% c("ifany", "always", "no") ))
            stop("useNA should be a character vector")
        useNA <- useNA[1]
        # perform calculation
        result <- .Call("colfreq", PACKAGE="LaF", as.integer(x@file_id), 
          as.integer(columns-1))
        # contruct end result
        for (i in seq_along(result)) {
            r <- result[[i]]$count
            n <- result[[i]]$value
            if (x@column_types[columns[i]] == 2) 
                n <- levels(x[[columns[i]]])
            if (useNA == "always" | (useNA == "ifany" & result[[i]]$missing)) {
                r <- c(r, result[[i]]$missing)
                n <- c(n, NA)
            }
            r <- array(r, dim=length(r), 
                    dimnames=list(n))
            class(r) <- "table"
            result[[i]] <- r
        }
        names(result) <- names(x)[columns]
        if (length(result) == 1) {
            return(result[[1]])
        } else {
            return(result)
        }
    }
)

#' @rdname stats
#' @export
setMethod(
    f = "colfreq",
    signature = "laf_column",
    definition = function(x, na.rm = TRUE, ...) {
      result <- callNextMethod(x, columns=x@column, na.rm=na.rm, ...)
      return(result)
    }
)

#' @rdname stats
#' @export
setGeneric(
    name = "colrange",
    def = function(x, ...) {
        standardGeneric("colrange")
    }
)

#' @rdname stats
#' @export
setMethod(
    f = "colrange",
    signature = "laf",
    definition = function(x, columns, na.rm=TRUE, ...) {
        # check columns
        if (!is.numeric(columns)) 
            stop("columns should be a numeric vector")
        if (!all(columns %in% 1:ncol(x)))
            stop("column out of range.")
        # check na.rm
        if (!is.logical(na.rm)) 
            stop("na.rm should be a logical vector")
        na.rm <- na.rm[1]
        # compute
        result <- .Call("colrange", PACKAGE="LaF", as.integer(x@file_id), 
          as.integer(columns-1))
        # contruct end result
        result <- sapply(result, function(a) {
            r <- c(min=a$min, max=a$max)
            if (!na.rm & a$missing) r[] <- NA
            return(r)
        })
        colnames(result) <- names(x)[columns]
        return(result)
    }
)

#' @rdname stats
#' @export
setMethod(
    f = "colrange",
    signature = "laf_column",
    definition = function(x, na.rm = TRUE, ...) {
      result <- callNextMethod(x, columns=x@column, na.rm=na.rm, ...)
      return(result)
    }
)

#' @rdname stats
#' @export
setGeneric(
    name = "colnmissing",
    def = function(x, ...) {
        standardGeneric("colnmissing")
    }
)

#' @rdname stats
#' @export
setMethod(
    f = "colnmissing",
    signature = "laf",
    definition = function(x, columns, na.rm=TRUE, ...) {
        # check columns
        if (!is.numeric(columns)) 
            stop("columns should be a numeric vector")
        if (!all(columns %in% 1:ncol(x)))
            stop("column out of range.")
        # check na.rm
        if (!is.logical(na.rm)) 
            stop("na.rm should be a logical vector")
        na.rm <- na.rm[1]
        # compute
        result <- .Call("colnmissing", PACKAGE="LaF", as.integer(x@file_id), 
          as.integer(columns-1))
        # contruct end result
        result <- sapply(result, function(a) {
            return(a$missing)
        })
        names(result) <- names(x)[columns]
        return(result)
    }
)

#' @rdname stats
#' @export
setMethod(
    f = "colnmissing",
    signature = "laf_column",
    definition = function(x, na.rm = TRUE, ...) {
      result <- callNextMethod(x, columns=x@column, na.rm=na.rm, ...)
      return(result)
    }
)


