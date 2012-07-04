\name{get_lines}
\alias{get_lines}
\title{
  Read in specified lines from a text file
}
\description{
  Read in specified lines from a text file
}
\usage{
  get_lines(filename, line_numbers)
}
\arguments{
  \item{filename}{character containing the filename of the file from which the
  lines should be read.}
  \item{line_numbers}{A vector containing the lines that should be read.}
}
\details{
  Line numbers larger than the number of lines in the file are ignored. Missing
  values are returned for these.
}
\value{
  Returns a character vector with the specified lines.
}
\author{
  D.J. van der Laan \email{djvanderlaan@unrealizedtime.nl}
}
\seealso{
  See \code{\link{readLines}} to read in all lines a text file;
  \code{\link{sample_lines}} can be used to read in random lines.
}
\examples{
  writeLines(letters[1:20], con="tmp.csv")
  get_lines("tmp.csv", c(1, 10))
}

