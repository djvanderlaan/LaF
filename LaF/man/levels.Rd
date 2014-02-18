\docType{methods}
\name{levels,laf-method}
\alias{levels,laf-method}
\alias{levels<-,laf-method}
\title{Get and change the levels of the column in a Large File object}
\usage{
\S4method{levels}{laf}(x)

\S4method{levels}{laf}(x) <- value
}
\arguments{
  \item{x}{an object, for example a factor.}

  \item{value}{A valid value for \code{levels(x)}.  For the
  default method, \code{NULL} or a character vector.  For
  the \code{factor} method, a vector of character strings
  with length at least the number of levels of \code{x}, or
  a named list specifying how to rename the levels.}
}
\description{
Get and change the levels of the column in a Large File
object
}

