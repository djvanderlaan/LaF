# Copyright 2012 Jan van der Laan
#
# This file is part of LaF.
#
# LaF is free software: you can redistribute it and/or modify it under the terms
# of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# LaF is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# LaF.  If not, see <http://www.gnu.org/licenses/>.

#' Read in Blaise data models
#'
#' @param filename the filename of the file containing the data model.
#' @param datafilename the filename of the data file to which the data model
#' belongs.
#'
#' @details
#' The function reads the data model from file and returns a list that can be
#' used by \code{\link{laf_open}} to open the file for reading. Only a subset of
#' the most common features found in Blaise files are supported. If part of the
#' data model can not be parsed a warning is given.
#'
#' @return
#' Returns a data model (which is a list containing all the relevant information
#' to open a file using \code{\link{laf_open}}. When the file contains more than
#' one data model a list of data models is returned and a warning issued. 
#'
#' @seealso
#' See \code{\link{write_dm}} to write the data model to file.  The data models
#' can be used to open a file using \code{\link{laf_open}}.
#'
#' @examples
#' # Generate test data
#' lines <- c(
#'     " 1M 1.45Rotterdam ",
#'     " 2F12.00Amsterdam ",
#'     " 3  .22 Berlin    ",
#'     "  M22   Paris     ",
#'     " 4F12345London    ",
#'     " 5M     Copenhagen",
#'     " 6M-12.1          ",
#'     " 7F   -1Oslo      ")
#' writeLines(lines, con="tmp.dat")
#' 
#' # Create a file containing the data model
#' writeLines(c( 
#'     "DATAMODEL test", 
#'     "FIELDS", 
#'     "  id     : INTEGER[2]", 
#'     "  gender : STRING[1]", 
#'     "  x      : REAL[5] {comment}", 
#'     "  city   : STRING[10]", 
#'     "ENDMODEL"), con="tmp.bla")
#' model <- read_dm_blaise("tmp.bla", datafilename="tmp.dat")
#' laf <- laf_open(model)
#'
#' @export
read_dm_blaise <- function(filename, datafilename=NA) {

    # Read complete all lines in file
    lines <- readLines(filename, warn=FALSE)

    # remove comments 
    # these are between { and } (we will assume that comments start and end on
    # the same line although comments can span multiple lines)
    lines <- gsub("\\{.*\\}", "", lines)
    
    # remove labels 
    # these are between " and " 
    lines <- gsub("\".*\"", "", lines)

    # Look for datamodel(s)
    # these start with 'datamodel' and end with 'endmodel'
    datamodels_start <- grep("datamodel", lines, ignore.case=TRUE)
    datamodels_names <- sapply(strsplit(lines[datamodels_start], split=' '), 
        function(d) d[2])
    datamodels_end   <- grep("endmodel", lines, ignore.case=TRUE)
    
    if (length(datamodels_start) == 0)
        stop("No datamodels found")
    if (length(datamodels_end) != length(datamodels_start))
        stop("Could not determine end of datamodel.")

    # Process each of the datamodels
    models <- list()
    for (i in seq_along(datamodels_start)) {

        # Select the lines belonging to one datamodel
        model_lines <- lines[(datamodels_start[i]+2):(datamodels_end[i]-1)]
        
        model <- data.frame(name=character(), type=character(), 
                    width=integer(), stringsAsFactors=FALSE)
        for (line in model_lines) {
        
            # Skip the following lines
            if (length(grep("^[[:blank:]]*$", line))) next; # blank lines
            if (length(grep("^[[:blank:]]*fields[[:blank:]]*$", line, 
                ignore.case=TRUE))) next; # lines with the term Fields
        
            # Process the first type expressions
            # These have the form '  dummy[1] '
            expr <- paste(c(
                    "^[[:blank:]]*",        # (optional) number of spaces at beginning line
                    "([[:alpha:]]+)",       # 2: column type
                    "[[:blank:]]*",         # optional space
                    "\\[([[:digit:]]+)\\]", # 3: column width between []
                    "[[:blank:]]*$"         # optional space at the end
                ), collapse="")
            if (length(grep(expr, line))) {
                parsed_line <- gsub(expr, ",\\1,\\2", line)
                parsed_line <- strsplit(parsed_line, ",")[[1]]
                model <- rbind(model, data.frame(
                        name  = parsed_line[1],
                        type  = parsed_line[2],
                        width = as.integer(parsed_line[3])
                    , stringsAsFactors=FALSE))
                next
            }
            
            # Process the second type of expressions
            # These have the form '  gender "label" : integer[1] '
            expr <- paste(c(
                "^[[:blank:]]*",        # (optional) number of spaces at beginning line
                "([[:alnum:]_]+)",      # 1: (required?) variable name 
                "[[:blank:]]*",         # optional spaces after variable name
                ":",                    # colon
                "[[:blank:]]*",         # optional spaces after colon
                "([[:alpha:]]+)",       # 2: column type
                "[[:blank:]]*",         # optional space
                "\\[[[:blank:]]*",      # opening [
                "([[:digit:]]+)[[:blank:]]*", # 3: column width with optional space
                "[,]*[[:blank:]]*[[:digit:]]*[[:blank:]]*", # optional , num
                "\\]",                  # closing ]
                "[[:blank:]]*$"         # optional space at the end
            ), collapse="")
            if (length(grep(expr, line))) {
                parsed_line <- gsub(expr, "\\1,\\2,\\3", line)
                parsed_line <- strsplit(parsed_line, ",")[[1]]
                model <- rbind(model, data.frame(
                        name  = parsed_line[1],
                        type  = parsed_line[2],
                        width = as.integer(parsed_line[3])
                    , stringsAsFactors=FALSE))
                next
            }
            
            expr <- paste(c(
                "^[[:blank:]]*",        # (optional) number of spaces at beginning line
                "([[:alnum:]_]+)",      # 1: (required?) variable name 
                "[[:blank:]]*",         # optional spaces after variable name
                ":",                    # colon
                "[[:blank:]]*",         # optional spaces after colon
                "(array|ARRAY)",        # 2: required array
                "[[:blank:]]*",         # optional space
                "\\[[[:blank:]]*",      # opening [ of array
                "([[:digit:]]+)[[:blank:]]*\\.\\.[[:blank:]]*", # 3: begin index of array 
                "([[:digit:]]+)[[:blank:]]*", # 4: end index of array
                "\\]",                  # closing ] of array
                "[[:blank:]]*",         # optional space
                "(of|OF)",              # 5: "of" / "OF"
                "[[:blank:]]*",         # optional space
                "([[:alpha:]]+)",       # 6: column type
                "[[:blank:]]*",         # optional space
                "\\[[[:blank:]]*",      # opening [
                "([[:digit:]]+)[[:blank:]]*", # 7: column width with optional space
                "[,]*[[:blank:]]*[[:digit:]]*[[:blank:]]*", # optional , num
                "\\]",                  # closing ]
                "[[:blank:]]*$"         # optional space at the end
            ), collapse="")
            
            if (length(grep(expr, line))) {
                parsed_line <- gsub(expr, "\\1,\\3,\\4,\\6,\\7", line)
                parsed_line <- strsplit(parsed_line, ",")[[1]]
                
                array_indices <- as.integer(parsed_line[2]):as.integer(parsed_line[3])
                for (index in array_indices) {
                
                    model <- rbind(model, data.frame(
                            name  = paste(parsed_line[1], index, sep=""),
                            type  = parsed_line[4],
                            width = as.integer(parsed_line[5])
                        , stringsAsFactors=FALSE))
                }
                next
            }

            # Handle unparsed lines
            warning("The following line could not be converted: '", line, "'")
   
        }

        # Convert type to lower case
        model$type <- tolower(model$type)

        # Generate column names for columns without a column name
        sel <- model$name == ""
        model$name[sel] <- paste(model$type[sel], 1:sum(sel), sep="")

        # Translate the blaise data types to LaF data types
        model$type[model$type == "dummy"] <- "string"
        model$type[model$type == "real"] <- "double"
        
        # Create meta model as needed by LaF 
        models[[i]] <- list(
            type = "fwf",
            filename = datafilename,
            dec = ".",
            columns = model
          )
    }

    # Set the names of the models
    names(models) <- datamodels_names
    
    # Return
    if (length(models) == 0) {
        stop("No datamodels found")
    } else if (length(models) > 1) {
        warning("More than one data model. Returning them as a list.")
        return(models)
    } else {
        return(models[[1]])
    }
}

