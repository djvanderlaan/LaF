# Copyright 2011, 2014 Jan van der Laan
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


#' Go to the beginning of the file
#' 
#' Sets the filepointer to the beginning of the file. The next call to 
#' \code{\link{next_block}} returns the first lines of the file. This method is 
#' usually used in combination with \code{\link{next_block}}.
#'
#' @param x an object the supports the \code{begin} method, such as an
#'   \code{laf} object.
#' @param ... passed to other methods.
#' 
#' @rdname begin
#' @export
setGeneric(
    name = "begin",
    def = function(x, ...) {
        standardGeneric("begin")
    }
)

#' Go to specified line in the file
#'
#' Sets the current line to the line number specified. The next call to 
#' \code{\link{next_block}} will return the data on the specified line in the 
#' first row. The number of the current line can be obtained using 
#' \code{\link{current_line}}.
#'
#' @param x an object the supports the \code{goto} method, such as an \code{laf}
#'   object.
#' @param i the line number .
#' @param ... additional parameters passed to other methods.
#
#' @rdname goto
#' @export
setGeneric(
    name = "goto",
    def = function(x, i, ...) {
        standardGeneric("goto")
    }
)

#' Get the current line in the file
#'
#' @param x an object the supports the \code{current_line} method, such as an
#'   \code{laf} object.
#'
#' Returns the next line that will be read by \code{\link{next_block}}. The
#' current line can be set by the method \code{\link{goto}}.
#'
#' @rdname current_line
#' @export
setGeneric(
    name = "current_line",
    def = function(x) {
        standardGeneric("current_line")
    }
)

#' Read the next block of data from a file.
#'
#' @param x an object the supports the \code{next_block} method, such as an
#'   \code{laf} object.
#' @param ... passed to other methods.
#'
#' Reads the next block of lines from a file. The method returns a
#' \code{data.frame}. The first line in the \code{data.frame} is the line
#' corresponding to the current line in the file. When the end of the file is
#' reached a \code{data.frame} with zero rows is returned. This can be used to
#' check whether the end of the file is reached. 
#'
#' @rdname next_block
#' @export
setGeneric(
    name = "next_block",
    def = function(x, ...) {
        standardGeneric("next_block")
    }
)

#' Blockwise processing of file
#'
#' Reads the specified file block by block and feeds each block to the 
#' specified function.
#'
#' @param x an object the supports the \code{process_blocks} method, such as an
#'   \code{laf} object.
#' @param fun a function to apply to each block (see details).
#' @param ... additional parameters are passed on to \code{fun}.
#'
#' @details
#' The function should accept as the first argument the next block of data. When
#' the end of the file is reached this is an empty (zero row) \code{data.frame}.
#' As the second argument the function should accept the output of the previous
#' call to the function. The first time the function is callen the second
#' argument has the value \code{NULL}.
#'
#' @rdname process_blocks
#' @export
setGeneric(
    name = "process_blocks",
    def = function(x, fun, ...) {
        standardGeneric("process_blocks")
    }
)

#' Read lines from the file
#' 
#' Reads the specified lines and columns from the data file. 
#'
#' @param x an object the supports the \code{read_lines} method, such as an
#'   \code{laf} object.
#' @param ... passed on to other methods.
#'
#' @details
#' Note that when scanning through the complete file next_block is much faster. 
#' Also note that random file access can be slow (and is always much slower 
#' than sequential file access), especially for certain file types such as 
#' comma separated. Reading is generally faster when the lines that should be
#' read are sorted. 
#'
#' @rdname read_lines
#' @export
setGeneric(
    name = "read_lines",
    def = function(x, ...) {
        standardGeneric("read_lines")
    }
)

