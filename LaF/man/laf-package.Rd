\name{laf-package}
\alias{laf-package}
\alias{laf}
\docType{package}
\title{
  Fast access to large ASCII files
}
\description{
  The package provides methods for fast and efficient access of large ASCII
  files (fixed width and csv files). It is assumed that the files are too large
  to be read into memory completely. The package therefore contains methods for
  blockwise processing of these files and methods for reading subsets of data
  (rows and/or columns) from these files. 
}
\details{
  The basis of the package is the \code{laf} class. Objects of type \code{laf}
  contain a reference to a file together with information such as column types,
  columns widths etc. These objects can be ceated with the functions:
  \code{laf_open_fwf} and \code{laf_open_csv}. After the objects
  are created they can be used in two ways. First, the objects can be indexed as
  one would a \code{data.frame}. Second, the file can be processed in a
  blockwise fashion. Block after block is read in and processed. This can be
  done using the following methods:
  \describe{
    \item{begin}{\code{signature(x = "laf")}: go to the beginning of the file.
    The next call to \code{next_block} will return the first line.}
    \item{goto}{\code{signature(x = "laf", i = "numeric")}: go to a specific
    line in the file.}
    \item{next_block}{\code{signature(x = "laf")}: Read the next block from 
    the file. By default all columns are read and 5000 lines are read. These can
    be specified by the options \code{columns} and \code{nrows} respectively.}
    \item{process_blocks}{\code{signature(x = "laf")}: blockwise processing
    of the file.}
  }
}
\author{
  D.J. van der Laan <djvanderlaan@unrealizedtime.nl>
}
\keyword{ package }

