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
# New generic: go to the beginning of the file
#
setGeneric(
    name = "begin",
    def = function(x, ...) {
        standardGeneric("begin")
    }
)

# =============================================================================
# New generic: go to the specified line in the file
#
setGeneric(
    name = "goto",
    def = function(x, i, ...) {
        standardGeneric("goto")
    }
)

# =============================================================================
# New generic: get the current line in the file
#
setGeneric(
    name = "current_line",
    def = function(x) {
        standardGeneric("current_line")
    }
)

# =============================================================================
# New generic: read the next block of data from the file
#
setGeneric(
    name = "next_block",
    def = function(x, ...) {
        standardGeneric("next_block")
    }
)

# =============================================================================
# New generic: blockwise processing of the file
#
setGeneric(
    name = "process_blocks",
    def = function(x, fun, ...) {
        standardGeneric("process_blocks")
    }
)

# =============================================================================
# New generic: read lines from the file
#
setGeneric(
    name = "read_lines",
    def = function(x, ...) {
        standardGeneric("read_lines")
    }
)

