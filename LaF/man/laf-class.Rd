\docType{class}
\name{laf-class}
\alias{laf-class}
\title{Large File object}
\description{
A Large File object. This is a reference to a dataset on
disk. The data itself is not read into memory (yet). This
can be done by the methods for blockwise processing or by
indexing the object as a data.frame. The code has been
optimised for fast access.
}
\section{Objects from the Class}{
  Objects can be created by opening a file using one of the
  methods \code{\link{laf_open_csv}} or
  \code{\link{laf_open_fwf}}. These create a reference to
  either a CSV file or a fixed width file. The data in
  these files can either be accessed using blockwise
  operations using the methods \code{begin},
  \code{next_block} and \code{goto}. Or by indexing the laf
  object as you would a data.frame. In the following
  example a CSV file is opened and its first column (of
  type integer) is read into memory: \preformatted{ laf <-
  laf_open_csv("file.csv", column_types=c("integer",
  "double")) data <- laf[ , 1] }
}

