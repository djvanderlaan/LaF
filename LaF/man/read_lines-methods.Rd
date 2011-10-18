\name{read_lines-methods}
\docType{methods}
\alias{read_lines-methods}
\alias{read_lines}
\title{Read lines from the file}
\description{
  Reads the specified lines and columns from the data file. 

  Note that when scanning through the complete file next_block is much faster. 
  Also note that random file access can be slow (and is always much slower 
  than sequential file access), especially for certain file types such as 
  comma separated. Reading is generally faster when the lines that should be
  read are sorted. 
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

