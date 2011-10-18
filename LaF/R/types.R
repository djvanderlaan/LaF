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
# Convert column types to R-types (this is the type used to store the data in
# R. For example, a column of type categorical is stored in R as a column of
# type integer)
#
.laf_to_rtype <- function(type) {
    BFTYPES     <- c("double", "integer", "categorical", "string", "integer_categorical")
    BFRTYPES    <- c("numeric", "integer", "integer", "character", "integer")
    BFTYPECODES <- 0:4
    if (is.character(type)) {
        type <- match(type, BFTYPES)
        if (any(is.na(type))) 
            stop("Invalid type. Type can be any of: '", 
                paste(BFTYPES, collapse="', '"), "'.")
    }
    if (is.numeric(type)) {
        type <- BFRTYPES[match(type, BFTYPECODES)]
        if (any(is.na(type))) 
            stop("Invalid type. Type can be any of: ", 
                paste(BFTYPECODES, collapse=", "), ".")
    } else {
        stop("type should be a numeric or character vector.")
    }
    return(type)
}

# =============================================================================
# Convert column types to the type code (this is an integer value that is used
# in the C++-code to determine the column type)
#
.laf_to_typecode <- function(type) {
    BFTYPES     <- c("double", "integer", "categorical", "string", "integer_categorical")
    BFRTYPES    <- c("numeric", "integer", "integer", "character", "integer")
    BFTYPECODES <- 0:4
    if (!is.character(type))
        stop("type should be a character vector.")
    type <- match(type, BFTYPES)
    if (any(is.na(type))) 
        stop("Invalid type. Type can be any of: '", 
            paste(BFTYPES, collapse="', '"), "'.")
    type <- as.integer(BFTYPECODES[type])
    return(type)
}

# =============================================================================
# Convert the column types to the column types used by LaF. 
# 
.laf_to_type <- function(type) {
    BFTYPES     <- c("double", "integer", "categorical", "string", "integer_categorical")
    BFRTYPES    <- c("numeric", "integer", "integer", "character", "integer")
    BFTYPECODES <- 0:4
    if (is.character(type)) {
        type <- match(type, BFRTYPES)
        if (any(is.na(type))) 
            stop("Invalid type. Type can be any of: '", 
                paste(BFRTYPES, collapse="', '"), "'.")
    }
    if (is.numeric(type)) {
        type <- BFTYPES[match(type, BFTYPECODES)]
        if (any(is.na(type))) 
            stop("Invalid type. Type can be any of: ", 
                paste(BFTYPECODES, collapse=", "), ".")
    } else {
        stop("type should be a numeric or character vector.")
    }
    return(type)
}

