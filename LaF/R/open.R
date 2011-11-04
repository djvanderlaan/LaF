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
# Create a connection to a comma seperated value (CSV) file.
#
laf_open_csv <-function(filename, column_types, 
        column_names = paste("V", seq_len(length(column_types)), sep=""),
        sep=",", dec='.', trim=FALSE, skip=0) {
    # check filename
    if (!is.character(filename))
        stop("filename should be of type character.")
    filename <- as.character(filename[1])
    if (file.access(filename, 4) != 0)
        stop("Can not access file '", filename, "'.")
    # check column_types
    types <- .laf_to_typecode(column_types)
    # check column_names
    if (!is.character(column_names))
        stop("column_names should be of type character.")
    if (length(column_names) != length(column_types))
        stop("Lengths of column_names and column_types do not match.")
    column_names <- make.names(column_names, unique=TRUE)
    # check sep
    if (!is.character(sep))
        stop("sep should be of type character")
    sep <- sep[1]
    if (nchar(sep) != 1)
        stop("The number of characters in sep is not equal to one.")
    # check dec
    if (!is.character(dec))
        stop("dec should be of type character")
    dec <- dec[1]
    if (nchar(dec) != 1)
        stop("The number of characters in dec is not equal to one.")
    # check trim
    if (!is.logical(trim))
        stop("trim should be of type logical")
    trim <- trim[1]
    # check skip
    if (!is.numeric(skip))
        stop("skip should be of type numeric")
    skip <- as.integer(skip[1])
    # open file
    p <- .Call("laf_open_csv", filename, types, sep, dec, trim, skip)
    # create laf-object
    result <- new(Class="laf", 
        file_id = as.integer(p),
        filename = filename, 
        file_type = "csv",
        column_types = types,
        column_names = column_names,
        column_widths = integer(0)
    )
    return(result)
}

# =============================================================================
# Create a connection to a fixed width file.
#
laf_open_fwf <-function(filename, column_types, column_widths,
        column_names = paste("V", seq_len(length(column_types)), sep=""),
        dec = ".", trim=TRUE) {
    # check filename
    if (!is.character(filename))
        stop("filename should be of type character.")
    filename <- as.character(filename[1])
    if (file.access(filename, 4) != 0)
	stop("Can not access file '", filename, "'.")
    # check column_types
    types <- .laf_to_typecode(column_types)
    # check column widths
    if (!is.numeric(column_widths))
        stop("column_widths should be of type numeric.")
    if (length(column_widths) != length(column_types))      
        stop("Lengths of column_widths and column_types do not match.")
    column_widths <- as.integer(column_widths)
    # check column_names
    if (!is.character(column_names))
        stop("column_names should be of type character.")
    if (length(column_names) != length(column_types))
        stop("Lengths of column_names and column_types do not match.")
    column_names <- make.names(column_names, unique=TRUE)
    # check dec
    if (!is.character(dec))
        stop("dec should be of type character")
    dec <- dec[1]
    if (nchar(dec) != 1)
        stop("The number of characters in dec is not equal to one.")
    # check trim
    if (!is.logical(trim))
        stop("trim should be of type logical")
    trim <- trim[1]
    # open file
    p <- .Call("laf_open_fwf", filename, types, column_widths, dec, trim)
    # create laf-object
    result <- new(Class="laf", 
        file_id = as.integer(p),
        filename = filename, 
        file_type = "fwf",
        column_types = types,
        column_names = column_names,
        column_widths = column_widths
    )
    return(result)
}

