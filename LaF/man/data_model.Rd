\name{data_model}
\alias{data_model}
\alias{read_dm}
\alias{write_dm}
\title{
  Read and write data models for LaF
}
\description{
  Using these routines data models can be written and read. These data models
  can be used to create LaF object without the need to specify all arguments
  (column names, column types etc.). Opening of files using the data models can
  be done using \code{\link{laf_open}}.
}
\usage{
  read_dm(modelfile, ...)
  write_dm(model, modelfile)
}
\arguments{
  \item{modelfile}{character containing the filename of the file the model is to
  be written to/read from.}
  \item{model}{a data model or an object of type \code{\linkS4class{laf}}. See
  details for more information.}
  \item{...}{additional arguments are added to the data model or, when they are
  also present in the file are used to overwrite the values specified in the
  file.}
}
\details{
  A data model is a list containing information which open routine should be
  used (e.g. \code{\link{laf_open_csv}} or \code{\link{laf_open_fwf}}), and the
  arguments needed for these routines. Required elements are `type', which can
  (currently) be `csv', or `fwf', and `columns', which should be a
  \code{data.frame} containing at least the columns `name' and `type', and for
  fwf `width'. These columns correspond to the arguments \code{column_names},
  \code{column_types} and \code{column_widths} respectively. Other arguments of
  the \code{laf_open_*} routines can be specified as additional elements of the
  list. 

  \code{write_dm} can also be used to write a data model that is created
  from an object of type \code{\linkS4class{laf}}. This is probably one of the
  easiest ways to create a data model.

  The data model is stored in a text file in YAML format which is a format in
  which data structures can be stored in a readable and editable format. 
}
\value{
  \code{read_dm} returns a data model which can be used by
  \code{\link{laf_open}}. 
}
\author{
  D.J. van der Laan \email{djvanderlaan@unrealizedtime.nl}
}
\seealso{
  See \code{\link{detect_dm_csv}} for a routine which can automatically
  create a data model from a CSV-file. The data models can be used to open a
  file using \code{\link{laf_open}}.
}
\examples{
# Generate test data
ntest <- 10
column_types <- c("integer", "integer", "double", "string")
testdata <- data.frame(
    a = 1:ntest,
    b = sample(1:2, ntest, replace=TRUE),
    c = round(runif(ntest), 13),
    d = sample(c("jan", "pier", "tjores", "corneel"), ntest, replace=TRUE)
    )
# Write test data to csv file
write.table(testdata, file="tmp.csv", row.names=FALSE, col.names=FALSE, sep=',')

# Create LaF-object
laf <- laf_open_csv("tmp.csv", column_types=column_types)

# Write data model to stdout() (screen)
write_dm(laf, stdout())

# Write data model to file
write_dm(laf, "tmp.yaml")

# Read data model and open file
laf2 <- laf_open(read_dm("tmp.yaml"))

# Write test data to second csv file
write.table(testdata, file="tmp2.csv", row.names=FALSE, col.names=FALSE, sep=',')

# Read data model and open seconde file, demonstrating the use of the optional
# arguments to read_dm
laf2 <- laf_open(read_dm("tmp.yaml", filename="tmp2.csv"))

}

