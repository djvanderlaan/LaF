\name{stats}
\Rdversion{1.1}
\docType{methods}
\alias{stats}
\alias{colmean}
\alias{colmean,laf-method}
\alias{colmean,laf_column-method}
\alias{colsum}
\alias{colsum,laf-method}
\alias{colsum,laf_column-method}
\alias{colrange}
\alias{colrange,laf-method}
\alias{colrange,laf_column-method}
\alias{colfreq}
\alias{colfreq,laf-method}
\alias{colfreq,laf_column-method}
\alias{colnmissing}
\alias{colnmissing,laf-method}
\alias{colnmissing,laf_column-method}

\title{Calculate simple statistics of columns}
\description{
  Methods for calculating simple statistics of columns of a file: mean, sum,
  standard deviation, range (min and max), and number of missing values. 
}
\section{Usage for objects of type \code{laf}}{
  \code{
    colmean(x, columns, na.rm = TRUE, ...)
    colsum(x, columns, na.rm = TRUE, ...)
    colfreq(x, columns, useNA = c("ifany", "always", "none"), ...)
    colrange(x, columns, na.rm = TRUE, ...)
    colnmissing(x, columns, ...)
  }
  \describe{
    \item{x}{an object of type laf or laf_column.}
    \item{columns}{a numeric vector with the columns for which the statistics
    should be calculated.}
    \item{na.rm}{whether or not to ignore missing values. By default missing
    values are ignored.}
    \item{useNA}{method with which to treat missing values: ifany adds a field
    containing the number of missing values if there are any; always will always
    add a field with the number of missing values even when there are none; none
    will never add a field containing the number of missing values.}
    \item{...}{Currently ignored.}
  }
}
\section{Usage for objects of type \code{laf_column}}{
  \code{
    colmean(x, na.rm = TRUE, ...)
    colsum(x, na.rm = TRUE, ...)
    colfreq(x, useNA = c("ifany", "always", "none"), ...)
    colrange(x, na.rm = TRUE, ...)
    colnmissing(x, ...)
  }
  \describe{
    \item{x}{an object of type \code{laf_column}.}
    \item{columns}{a numeric vector with the columns for which the statistics
    should be calculated.}
    \item{na.rm}{whether or not to ignore missing values. By default missing
    values are ignored.}
    \item{useNA}{method with which to treat missing values: ifany adds a field
    containing the number of missing values if there are any; always will always
    add a field with the number of missing values even when there are none; none
    will never add a field containing the number of missing values.}
    \item{...}{Currently ignored.}
  }
}
\keyword{methods}


