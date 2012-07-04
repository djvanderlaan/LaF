\name{determine_nlines}
\title{
  Determine number of lines in a text file
}
\description{
  Determine number of lines in a text file
}
\usage{
  determine_nlines(filename)
}
\arguments{
  \item{filename}{character containing the filename of the file of which the
  lines are to be counted.}
}
\details{
  The routine counts the number of line endings. If the last line does not
  end in a line ending, but does contain character, this line is also counted.

  The file size is not limited by the amount of memory in the computer. 
}
\value{
  Returns the number of lines in the file.
}
\author{
  D.J. van der Laan \email{djvanderlaan@unrealizedtime.nl}
}
\seealso{
  See \code{\line{readLines}} to read in all lines a text file;
  \code{\link{get_lines}} and \code{\link{sample_lines}} can be used to read in
  spcified, or random lines.
}
\examples{
  # Generate file
  writeLines(letters[1:20], con="tmp.csv")

  # Count the lines
  determine_nlines("tmp.csv")
}

