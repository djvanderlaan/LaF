\name{process_blocks-methods}
\docType{methods}
\alias{process_blocks-methods}
\alias{process_blocks}
\title{Blockwise processing of blocks.}
\description{
  Reads the specified file block by block and feeds each block to the 
  specified function.
}
\section{Methods}{
  \describe{
    \item{\code{signature(x = "laf")}}{
      See \code{\linkS4class{laf}}. 
    }
  }
}
\details{
  The function should accept as the first argument the next block of data. When
  the end of the file is reached this is an empty (zero row) \code{data.frame}.
  As the second argument the function should accept the output of the previous
  call to the function. The first time the function is callen the second
  argument has the value \code{NULL}.
}
\keyword{methods}
