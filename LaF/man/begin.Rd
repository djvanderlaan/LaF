\docType{methods}
\name{begin}
\alias{begin}
\alias{begin,laf-method}
\title{Go to the beginning of the file}
\usage{
begin(x, ...)

\S4method{begin}{laf}(x, ...)
}
\arguments{
  \item{x}{an object the supports the \code{begin} method,
  such as an \code{laf} object.}

  \item{...}{passed to other methods.}
}
\description{
Sets the filepointer to the beginning of the file. The next
call to \code{\link{next_block}} returns the first lines of
the file. This method is usually used in combination with
\code{\link{next_block}}.
}

