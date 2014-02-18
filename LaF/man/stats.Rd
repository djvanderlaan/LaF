\docType{methods}
\name{colsum}
\alias{colfreq}
\alias{colfreq,laf-method}
\alias{colfreq,laf_column-method}
\alias{colmean}
\alias{colmean,laf-method}
\alias{colmean,laf_column-method}
\alias{colnmissing}
\alias{colnmissing,laf-method}
\alias{colnmissing,laf_column-method}
\alias{colrange}
\alias{colrange,laf-method}
\alias{colrange,laf_column-method}
\alias{colsum}
\alias{colsum,laf-method}
\alias{colsum,laf_column-method}
\title{Calculate simple statistics of column}
\usage{
colsum(x, ...)

\S4method{colsum}{laf}(x, columns, na.rm = TRUE, ...)

\S4method{colsum}{laf_column}(x, na.rm = TRUE, ...)

colmean(x, ...)

\S4method{colmean}{laf}(x, columns, na.rm = TRUE, ...)

\S4method{colmean}{laf_column}(x, na.rm = TRUE, ...)

colfreq(x, ...)

\S4method{colfreq}{laf}(x, columns, useNA = c("ifany", "always", "no"), ...)

\S4method{colfreq}{laf_column}(x, na.rm = TRUE, ...)

colrange(x, ...)

\S4method{colrange}{laf}(x, columns, na.rm = TRUE, ...)

\S4method{colrange}{laf_column}(x, na.rm = TRUE, ...)

colnmissing(x, ...)

\S4method{colnmissing}{laf}(x, columns, na.rm = TRUE, ...)

\S4method{colnmissing}{laf_column}(x, na.rm = TRUE, ...)
}
\arguments{
  \item{x}{an object of type laf or laf_column.}

  \item{columns}{a numeric vector with the columns for
  which the statistics should be calculated.}

  \item{na.rm}{whether or not to ignore missing values. By
  default missing values are ignored.}

  \item{useNA}{method with which to treat missing values:
  ifany adds a field containing the number of missing
  values if there are any; always will always add a field
  with the number of missing values even when there are
  none; none will never add a field containing the number
  of missing values.}

  \item{...}{Currently ignored.}
}
\description{
Methods for calculating simple statistics of columns of a
file: mean, sum, standard deviation, range (min and max),
and number of missing values.
}

