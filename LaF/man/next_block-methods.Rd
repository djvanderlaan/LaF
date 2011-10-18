\name{next_block-methods}
\docType{methods}
\alias{next_block-methods}
\alias{next_block}
\title{Read the next block of data from a file.}
\description{
  Reads the next block of lines from a file. The method returns a
  \code{data.frame}. The first line in the \code{data.frame} is the line
  corresponding to the current line in the file. When the end of the file is
  reached a \code{data.frame} with zero rows is returned. This can be used to
  check whether the end of the file is reached. 
}
\section{Methods}{
  \describe{
    \item{\code{signature(x = "laf")}}{
      See \code{\linkS4class{laf}}. 
    }
    \item{\code{signature(x = "laf_column")}}{
      See \code{\linkS4class{laf_column}}. 
    }
  }
}
\keyword{methods}

