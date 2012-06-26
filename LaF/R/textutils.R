# Copyright 2012 Jan van der Laan
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

determine_nlines <- function(filename) {
    if (!is.character(filename)) stop("filename should be a character vector")
    result <- .Call("nlines", as.character(filename))
    return(result)
}

get_lines <- function(filename, line_numbers) {
    if (!is.character(filename)) 
        stop("filename should be a character vector")
    if (!is.numeric(lines_numbers))
        stop("line_numbers should be a numeric vector")
    line_order  <- order(line_numbers)
    line_numbers <- line_number[line_order]
    result <- .Call("r_get_line", as.character(filename), 
        as.integer(line_numbers)-1)
    result <- result[order(seq_along(line_numbers)[line_order])]
    return(result)
}

sample_lines <- function(filename, n, nlines = NULL) {
    if (!is.character(filename)) stop("filename should be a character vector")
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
    lines <- sample(nlines, n, replace=FALSE)
    return(read_lines(filename, lines))
}

