\name{laf_open_fwf}
\alias{laf_open_fwf}
\title{
  Create a connection to a fixed width file.
}
\description{
  A connection to the file filename is created. Column types have to be 
  specified. These are not determined automatically as for example 
  read.fwf does. This has been done to increase speed. 

  After the connection is created data can be extracted using indexing (as in a
  normal data.frame) or methods such as read_lines and next_block can be used 
  to read in blocks. For processing the file in blocks the (faster) convenience
  function process_blocks can be used. 
}
\usage{
laf_open_fwf(filename, column_types, column_widths, column_names = paste("V", seq_len(length(column_types)), sep = ""), dec = ".")
}
\arguments{
  \item{filename}{character containing the filename of the CSV-file.}
  \item{column_types}{character vector containing the types of data in each of 
    the columns. Valid types are: double, integer, categorical and string.}
  \item{column_widths}{numeric vector containing the width in number of character
    of each of the columns.}
  \item{column_names}{optional character vector containing the names of the 
    columns.}
  \item{dec}{optional character specifying the decimal mark.}
}
\value{
  Object of type \code{\linkS4class{laf}}. Values can be extracted from this object 
  using indexing, and methods such as \code{\link{read_lines}}, \code{\link{next_block}}. 
}
\author{
  D.J. van der Laan \email{djvanderlaan@unrealizedtime.nl}
}
\seealso{
  See \code{\link{read.fwf}} for conventional access of fixed width files. 
}
\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as
function(filename, column_types, column_widths,
        column_names = paste("V", seq_len(length(column_types)), sep=""),
        dec = ".") {
    # check filename
    if (!is.character(filename))
        stop("filename should be of type character.")
    filename <- as.character(filename[1])
    if (!file_access(filename))
	stop("Can not access file '", filename, "'.")
    # check column_types
    types <- laf_to_typecode(column_types)
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
    # open file
    p <- .Call("laf_open_fwf", filename, types, column_widths, dec)
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
}

