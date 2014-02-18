\name{laf_open_fwf}
\alias{laf_open_fwf}
\title{Create a connection to a fixed width file.}
\usage{
laf_open_fwf(filename, column_types, column_widths, column_names = paste("V",
  seq_len(length(column_types)), sep = ""), dec = ".", trim = TRUE)
}
\arguments{
  \item{filename}{character containing the filename of the
  CSV-file.}

  \item{column_types}{character vector containing the types
  of data in each of the columns. Valid types are: double,
  integer, categorical and string.}

  \item{column_widths}{numeric vector containing the width
  in number of character of each of the columns.}

  \item{column_names}{optional character vector containing
  the names of the columns.}

  \item{dec}{optional character specifying the decimal
  mark.}

  \item{trim}{optional logical specifying whether or not
  whitespace at the end of factor levels or character
  strings should be trimmed.}
}
\value{
Object of type \code{\linkS4class{laf}}. Values can be
extracted from this object using indexing, and methods such
as \code{\link{read_lines}}, \code{\link{next_block}}.
}
\description{
A connection to the file filename is created. Column types
have to be specified. These are not determined
automatically as for example read.fwf does. This has been
done to increase speed.
}
\details{
After the connection is created data can be extracted using
indexing (as in a normal data.frame) or methods such as
read_lines and next_block can be used to read in blocks.
For processing the file in blocks the (faster) convenience
function process_blocks can be used.
}
\seealso{
See \code{\link{read.fwf}} for conventional access of fixed
width files.
}

