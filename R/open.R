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

#' Create a connection to a comma separated value (CSV) file.
#'
#' A connection to the file filename is created. Column types have to be
#' specified. These are not determined automatically as for example read.csv
#' does.  This has been done to increase speed. 
#'
#' After the connection is created data can be extracted using indexing (as in a
#' normal data.frame) or methods such as \code{\link{read_lines}} and 
#' \code{\link{next_block}} can be used to read in blocks. For processing the 
#' file in blocks the convenience function \code{\link{process_blocks}} can be 
#' used. 
#'
#' @param filename character containing the filename of the CSV-file
#' @param column_types character vector containing the types of data in each of
#'   the columns. Valid types are: double, integer, categorical and string.
#' @param column_names optional character vector containing the names of the
#'   columns.
#' @param sep optional character specifying the field separator used in the
#'   file.
#' @param dec optional character specifying the decimal mark.
#' @param trim optional logical specifying whether or not white space at the end
#'   of factor levels or character strings should be trimmed.
#' @param skip optional numeric specifying the number of lines at the beginning 
#'   of the file that should be skipped.
#' @param ignore_failed_conversion ignore (set to \code{NA}) fields that could 
#'   not be converted. 
#'
#' @details
#' The CSV-file should not contain headers. Use the \code{skip} option to skip 
#' any headers.
#'
#' In case of an incomplete line (at line with less columns than it should
#' have): when the line is completely empty the reader stops at that point and
#' considers that as the end of the file. In other cases a warning is issued
#' and the remaining columns are considered empty. For character columns this
#' results in an empty string for numeric columns a \code{NA}.
#'
#' @return
#' Object of type \code{\linkS4class{laf}}. Values can be extracted from this
#' object using indexing, and methods such as \code{\link{read_lines}},
#' \code{\link{next_block}}. 
#'
#' @seealso
#' See \code{\link{read.csv}} for conventional access of CSV files. And 
#' \code{\link{detect_dm_csv}} to automatically determine the column types. 
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
#'     d = sample(c("jan", "pier", "tjores", "corneel"), ntest, replace=TRUE)
#'     )
#' # Write test data to csv file
#' write.table(testdata, file=tmpcsv, row.names=FALSE, col.names=FALSE, sep=',')
#' 
#' # Create LaF-object
#' laf <- laf_open_csv(tmpcsv, column_types=column_types)
#' 
#' # Read from file using indexing
#' first_column <- laf[ , 1]
#' first_row    <- laf[1, ]
#' 
#' # Read from file using blockwise operators
#' begin(laf)
#' first_block <- next_block(laf, nrows=2)
#' second_block <- next_block(laf, nrows=2)
#'
#' # Cleanup
#' file.remove(tmpcsv)
#'
#' @export
laf_open_csv <-function(filename, column_types, 
        column_names = paste("V", seq_len(length(column_types)), sep=""),
        sep = ",", dec = '.', trim = FALSE, skip = 0, 
        ignore_failed_conversion = FALSE) {
    # check filename
    if (!is.character(filename))
        stop("filename should be of type character.")
    filename <- path.expand(filename[1])
    if (!.file_readable(filename))
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
    # check ignore_failed_conversion
    if (!is.logical(ignore_failed_conversion))
        stop("ignore_failed_conversion should be of type logical")
    ignore_failed_conversion <- ignore_failed_conversion[1]
    # open file
    p <- .Call("laf_open_csv", PACKAGE="LaF", filename, types, sep, dec, 
      trim, skip, ignore_failed_conversion)
    # create laf-object
    result <- new(Class="laf", 
        file_id = as.integer(p),
        filename = filename, 
        file_type = "csv",
        column_types = types,
        column_names = column_names,
        column_widths = integer(0),
        options = list(
            sep=sep,
            dec=dec,
            skip=skip,
            trim=trim)
    )
    return(result)
}

#' Create a connection to a fixed width file.
#'
#' A connection to the file filename is created. Column types have to be 
#' specified. These are not determined automatically as for example 
#' read.fwf does. This has been done to increase speed. 
#'
#' After the connection is created data can be extracted using indexing (as in a
#' normal data.frame) or methods such as read_lines and next_block can be used 
#' to read in blocks. For processing the file in blocks the (faster) convenience
#' function process_blocks can be used. 
#'
#' @param filename character containing the filename of the fixed width file.
#' @param column_types character vector containing the types of data in each of 
#'   the columns. Valid types are: double, integer, categorical and string.
#' @param column_widths numeric vector containing the width in number of character
#'   of each of the columns.
#' @param column_names optional character vector containing the names of the 
#'   columns.
#' @param dec optional character specifying the decimal mark.
#' @param trim optional logical specifying whether or not whitespace at the end
#'   of factor levels or character strings should be trimmed.
#' @param ignore_failed_conversion ignore (set to \code{NA}) fields that could 
#'   not be converted. 
#'   
#' @details 
#' Only use \code{ignore_failed_conversion } when you are sure that the column
#' specification is correct. Otherwise, this option can hide an incorrect 
#' specification. 
#'
#' @return
#' Object of type \code{\linkS4class{laf}}. Values can be extracted from this object 
#' using indexing, and methods such as \code{\link{read_lines}}, \code{\link{next_block}}. 
#'
#' @seealso
#' See \code{\link{read.fwf}} for conventional access of fixed width files. 
#'
#' @export
laf_open_fwf <-function(filename, column_types, column_widths,
        column_names = paste("V", seq_len(length(column_types)), sep=""),
        dec = ".", trim = TRUE, ignore_failed_conversion = FALSE) {
    # check filename
    if (!is.character(filename))
        stop("filename should be of type character.")
    filename <- path.expand(filename[1])
    if (!.file_readable(filename))
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
    # check ignore_failed_conversion
    if (!is.logical(ignore_failed_conversion))
        stop("ignore_failed_conversion should be of type logical")
    ignore_failed_conversion <- ignore_failed_conversion[1]
    # open file
    p <- .Call("laf_open_fwf", PACKAGE="LaF", filename, types, column_widths, 
      dec, trim, ignore_failed_conversion)
    # create laf-object
    result <- new(Class="laf", 
        file_id = as.integer(p),
        filename = filename, 
        file_type = "fwf",
        column_types = types,
        column_names = column_names,
        column_widths = column_widths,
        options = list(
            dec=dec,
            trim=trim)
    )
    return(result)
}

