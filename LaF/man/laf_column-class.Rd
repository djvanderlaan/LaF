\name{laf_column-class}
\Rdversion{1.1}
\docType{class}
\alias{laf_column-class}
\alias{[,laf_column-method}
\alias{levels,laf_column-method}
\alias{levels<-,laf_column-method}
\alias{next_block,laf_column-method}
\alias{read_lines,laf_column-method}
\alias{show,laf_column-method}

\title{Class "laf_column"}
\description{
  Representation of a column in a Large File object. This class itself is a
  subclass of the class \code{laf}. In principle all methods that can be used
  with a \code{laf} object can also be used with a \code{laf_column} object
  except the the \code{column} or \code{columns} arguments of these methods are
  not needed. 
}
\section{Objects from the Class}{
  Object of this class are usually created by using the \code{$} operator on
  \code{laf} objects. 
}
\section{Slots}{
  A \code{laf_column} contains all slots of a \code{laf} object. Besides these,
  the class also contains the following slots:
  \describe{
    \item{\code{column}:}{Object of class \code{"integer"}. The corresponding
    column in the \code{laf} object.}
  }
}
\section{Extends}{
  Class \code{"\linkS4class{laf}"}, directly.
}
\section{Methods}{
  \describe{
    \item{[}{\code{signature(x = "laf_column")}: a \code{laf_column} can be
    indexed as an ordinary vector. }
    \item{levels<-}{\code{signature(x = "laf_column")}: set the levels of a laf
    column. }
    \item{levels}{\code{signature(x = "laf_column")}: return the levels of the
    column. A data.frame with the levels and correcsponding labels. An empty
    data.frame is returned for non-categorical columns.}
    \item{next_block}{\code{signature(x = "laf_column")}: read the next block of
    lines from the column. Returns a vector.}
    \item{read_lines}{\code{signature(x = "laf_column")}: reads the specified
    rows from the columns.}
    \item{show}{\code{signature(object = "laf_column")}: print the columns.}
  }
}
\author{
  D.J. van der Laan \email{djvanderlaan@unrealizedtime.nl}
}
\examples{
showClass("laf_column")
}
\keyword{classes}
