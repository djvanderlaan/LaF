\name{sample_lines}
\alias{sample_lines}
\title{Read in random lines from a text file}
\usage{
sample_lines(filename, n, nlines = NULL)
}
\arguments{
  \item{filename}{character containing the filename of the
  file from which the lines should be read.}

  \item{n}{The number of lines that should be sampled from
  the file.}

  \item{nlines}{The total number of lines in the file. If
  not specified or \code{NULL} the number of lines is first
  determined using \code{\link{determine_nlines}}.}
}
\value{
Returns a character vector with the sampled lines.
}
\description{
Read in random lines from a text file
}
\details{
When \code{nlines} is not specified, the total number of
lines is first determined. This can take quite some time.
Therefore, specifying the number of lines can cause a
significant speed up. It can also be used to sample lines
from the first \code{nlines} line by specifying a value for
\code{nlines} that is smaller than the number of lines in
the file.
}
\examples{
writeLines(letters[1:20], con="tmp.csv")
sample_lines("tmp.csv", 10)
}
\seealso{
See \code{\link{readLines}} to read in all lines a text
file; \code{\link{get_lines}} can be used to read in
specified lines.
}

