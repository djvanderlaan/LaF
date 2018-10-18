# Copyright 2012, 2014 Jan van der Laan
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

#' Determine number of lines in a text file
#'
#' @param filename character containing the filename of the file of which the
#'   lines are to be counted.
#'
#' @details
#' The routine counts the number of line endings. If the last line does not
#' end in a line ending, but does contain character, this line is also counted.
#'
#' The file size is not limited by the amount of memory in the computer. 
#'
#' @return
#' Returns the number of lines in the file.
#'
#' @seealso
#' See \code{\link{readLines}} to read in all lines a text file;
#' \code{\link{get_lines}} and \code{\link{sample_lines}} can be used to read in
#' specified, or random lines.
#'
#' @examples
#' # Generate file
#' writeLines(letters[1:20], con="tmp.csv")
#'
#' # Count the lines
#' determine_nlines("tmp.csv")
#'
#' @export
determine_nlines <- function(filename) {
    if (!is.character(filename)) stop("filename should be a character vector")
    filename <- path.expand(filename)
    result <- .Call("nlines", PACKAGE="LaF", filename)
    return(result)
}

#' Read in specified lines from a text file
#'
#' @param filename character containing the filename of the file from which the
#'   lines should be read.
#' @param line_numbers A vector containing the lines that should be read.
#'
#' @details
#' Line numbers larger than the number of lines in the file are ignored. Missing
#' values are returned for these.
#'
#' @return
#' Returns a character vector with the specified lines.
#'
#' @seealso
#' See \code{\link{readLines}} to read in all lines a text file;
#' \code{\link{sample_lines}} can be used to read in random lines.
#'
#' @examples
#' writeLines(letters[1:20], con="tmp.csv")
#' get_lines("tmp.csv", c(1, 10))
#'
#' @export
get_lines <- function(filename, line_numbers) {
    if (!is.character(filename)) 
        stop("filename should be a character vector")
    filename <- path.expand(filename)
    if (!is.numeric(line_numbers))
        stop("line_numbers should be a numeric vector")
    line_order  <- order(line_numbers)
    line_numbers <- line_numbers[line_order]
    result <- .Call("r_get_line", PACKAGE="LaF", filename, 
        as.integer(line_numbers)-1)
    result <- result[order(seq_along(line_numbers)[line_order])]
    return(result)
}

#' Read in random lines from a text file
#'
#' @param filename character containing the filename of the file from which the
#'   lines should be read.
#' @param n The number of lines that should be sampled from the file.
#' @param nlines The total number of lines in the file. If not specified or
#'   \code{NULL} the number of lines is first determined using
#'   \code{\link{determine_nlines}}.
#'
#' @details
#' When \code{nlines} is not specified, the total number of lines is first
#' determined. This can take quite some time. Therefore, specifying the number of
#' lines can cause a significant speed up. It can also be used to sample lines
#' from the first \code{nlines} line by specifying a value for \code{nlines} that
#' is smaller than the number of lines in the file.
#'
#' @return
#' Returns a character vector with the sampled lines.
#'
#' @seealso
#' See \code{\link{readLines}} to read in all lines a text file;
#' \code{\link{get_lines}} can be used to read in specified lines.
#'
#' @examples
#' writeLines(letters[1:20], con="tmp.csv")
#' sample_lines("tmp.csv", 10)
#'
#' @export
sample_lines <- function(filename, n, nlines = NULL) {
    if (!is.character(filename)) stop("filename should be a character vector")
    filename <- path.expand(filename)
    if (!is.numeric(n)) stop("n should be a number")
    if (!is.null(nlines) && !is.numeric(nlines))
        stop("nlines should be a number")
    if (is.null(nlines)) {
        nlines <- determine_nlines(filename)
    }
    n <- n[1]
    if (n < 0) 
        stop("n is negative; you can't sample a negative number of lines")
    if (n < 1) n <- round(n * nlines)
    lines <- sample(nlines, min(n, nlines), replace=FALSE)
    return(get_lines(filename, lines))
}

