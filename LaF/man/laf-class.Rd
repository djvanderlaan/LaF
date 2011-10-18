\name{laf-class}
\Rdversion{1.1}
\docType{class}
\alias{laf-class}
\alias{[,laf-method}
\alias{[[,laf-method}
\alias{$,laf-method}
\alias{begin,laf-method}
\alias{current_line,laf-method}
\alias{goto,laf,numeric-method}
\alias{levels,laf-method}
\alias{names<-,laf-method}
\alias{names,laf-method}
\alias{ncol,laf-method}
\alias{next_block,laf-method}
\alias{nrow,laf-method}
\alias{process_blocks,laf-method}
\alias{read_lines,laf-method}
\alias{show,laf-method}
\alias{close,laf-method}

\title{Class "laf"}
\description{
  A Large File object. This is a reference to a dataset on disk. The data
  itself is not read into memory (yet). This can be done by the methods for
  blockwise processing or by indexing the object as a data.frame. The code has
  been optimised for fast access.
}
\section{Objects from the Class}{
  Objects can be created by opening a file using one of the methods 
  \code{\link{laf_open_csv}} or \code{\link{laf_open_fwf}}. These create a 
  reference to either a CSV file or a fixed width file. The data in these
  files can either be accessed using blockwise operations using the methods
  \code{begin}, \code{next_block} and \code{goto}. Or by indexing the laf 
  object as you would a data.frame. In the following example a CSV file
  is opened and its first column (of type integer) is read into memory:
  \preformatted{
    laf <- laf_open_csv("file.csv", column_types=c("integer", "double"))
    data <- laf[ , 1]
  }
}
\section{Slots}{
  The slots of the class are described below. Do not change these slots! Use the
  methods that have been supplied for this.
  \describe{
    \item{\code{file_id}:}{Object of class \code{"integer"}. This is the internal
    number of the file. Do not change this or bad things will happen.}
    \item{\code{filename}:}{Object of class \code{"character"}. The name of the
    file that is opened. Changing this does not cause the code to open a new file.}
    \item{\code{file_type}:}{Object of class \code{"character"}. The type of file
    that is opened. Do not change this.}
    \item{\code{column_names}:}{Object of class \code{"character"}. The names of
    the columns in the file. When reading from the file usually a data.frame is 
    returned with these names.}
    \item{\code{column_types}:}{Object of class \code{"integer"}. The types of
    the columns. Do not change this of bad things will happen.}
    \item{\code{column_widths}:}{Object of class \code{"integer"}. Contains the 
    width of the columns for fixed width files.}
  }
}
\section{Methods}{
  \describe{
    \item{[}{\code{signature(x = "laf")}: a laf-object can de indexed as one 
    would an ordinary \code{data.frame}.}
    \item{[[}{\code{signature(x = "laf")}: retrieves a column from the 
    laf-object. An object of type \code{\linkS4class{laf_column}} is returned.}
    \item{$}{\code{signature(x = "laf")}: retrieves a column from the 
    laf-object. An object of type \code{\linkS4class{laf_column}} is returned.}
    \item{begin}{\code{signature(x = "laf")}: go to the beginning of the file.
    The next call to \code{next_block} will return the first line.}
    \item{current_line}{\code{signature(x = "laf")}: get the current_line. This
    is the first line the next call to \code{next_block} will return.}
    \item{goto}{\code{signature(x = "laf", i = "numeric")}: go to a specific
    line in the file.}
    \item{levels}{\code{signature(x = "laf")}: Return a list of character 
    vectors containing the levels of each of the columns. Empty vectors are
    returned for non-categorical columns. Please note that the levels are only
    filled completely for a column when the column had been read completely once.}
    \item{names<-}{\code{signature(x = "laf")}: Set the names of the columns.}
    \item{names}{\code{signature(x = "laf")}: Get the names of the columns. }
    \item{ncol}{\code{signature(x = "laf")}: Get the number of columns.}
    \item{next_block}{\code{signature(x = "laf")}: Read the next block from 
    the file. By default all columns are read and 5000 lines are read. These can
    be specified by the options \code{columns} and \code{nrows} respectively.}
    \item{nrow}{\code{signature(x = "laf")}: get the number of rows.}
    \item{process_blocks}{\code{signature(x = "laf")}: blockwise processing
    of the file.}
    \item{read_lines}{\code{signature(x = "laf")}: read specific lines and/or
    column from the file. }
    \item{show}{\code{signature(object = "laf")}: print the object. }
    \item{close}{\code{signature(object = "laf")}: close the object. }
  }
}
\author{
  D.J. van der Laan \email{djvanderlaan@unrealizedtime.nl}
}
\seealso{
  TODO
}
\examples{
showClass("laf")
}
\keyword{classes}

