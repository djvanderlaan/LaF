

determine_nlines <- function(filename) {
    if (!is.character(filename)) stop("filename should be a character vector")
    result <- .Call("nlines", as.character(filename))
    return(result)
}

get_lines <- function(filename, line_number) {
    if (!is.character(filename)) stop("filename should be a character vector")
    line_order  <- order(line_number)
    line_number <- line_number[line_order]
    result <- .Call("r_get_line", as.character(filename), as.integer(line_number)-1)
    result <- result[order(seq_along(line_number)[line_order])]
    return(result)
}

sample_lines <- function(filename, n, nlines = NULL) {
    if (!is.character(filename)) stop("filename should be a character vector")
    if (!is.numeric(n)) stop("n should be a number")
    if (!is.null(nlines) && !is.numeric(nlines))
        stop("nlines should be a number")
    if (is.null(nlines)) {
        nlines <- determine_nlines(filename)
    }
    n <- n[1]
    if (n < 0) stop("n is negative; you can't sample a negative number of lines")
    if (n < 1) n <- round(n * nlines)
    lines <- sample(nlines, n, replace=FALSE)
    return(read_lines(filename, lines))
}

detect_datamodel_csv <- function(filename, sep=",", dec=".", header=FALSE, 
        nlines=1000, sample=FALSE, ...) {
    if (sample) {
        lines <- sample_lines(filename, n=nlines)
        con <- textConnection(lines)
    } else con <- file(filename, "rt")
    data  <- read.table(con, nrow=nlines, sep=sep, dec=dec, header=header, ...)
    close(con)
    names <- names(data)
    types <- sapply(data, function(d) {
        type <- class(d)
        if (identical(type, "factor")) {
            f <- nlevels(d)/length(d)
            if (f > 0.2) {
                type <- "string"
            } else {
                type <- "categorical"
            }
        }
        if (identical(type, "numeric"))   type <- "double"
        if (identical(type, "character")) type <- "string"
        return(type)
    })
    return(list(
        type = "csv",
        filename = filename,
        columns = data.frame(names=names, types=types, stringsAsFactors=FALSE),
        dec = dec,
        sep = sep,
        skip = ifelse(header, 1, 0)
    ))
}

read_data_model <- function(model, ...) {
    lines <- readLines(model)
    lines <- lines[grep("^#", lines)]
    lines <- gsub("^#", "", lines)
    con <- textConnection(lines)
    lines <- read.table(con, sep=",", header=FALSE, stringsAsFactors=FALSE)
    close(con)
    result <- list()
    for (i in seq_len(nrow(lines))) {
        # try to convert to numeric
        val <- suppressWarnings(as.numeric(lines[i,2]))
        if (is.na(val)) val <- lines[i,2]
        result[[lines[i,1]]] <- val
    }
    result$columns <- read.table(model, sep=',', header=TRUE, 
        stringsAsFactors=FALSE)
    result[names(list(...))] <- list(...)
    return(result)
}

write_data_model <- function(model, filename) {
    con <- file(filename, "wt")
    # write first part (the part containing all information except the columns)
    for (name in names(model)) {
        if (name == "columns") next;
        if (is.character(model[[name]])) {
          # TODO escape quotes?
          val <- paste("'", model[[name]], "'", sep="")
        } else {
          val <- as.character(model[[name]])
        }
        writeLines(paste("#", name, ",", val, sep=""), con=con)
    }
    # write second part (the part containing the information on the columns
    write.table(model$columns, file=con, sep=",", row.names=FALSE, 
        col.names=TRUE, dec=".")
    close(con)
}

laf_open <- function(model, ...) {
    model[names(list(...))] <- list(...)
    model$column_names  <- model$columns$names
    model$column_types <- model$columns$types
    if (identical(model$type, "csv")) {
        open <- "laf_open_csv"
    } else if (identical(model$type, "fwf")) {
        model$column_widths <- model$columns$widths
        open <- "laf_open_fwf"
    }
    model$type    <- NULL
    model$columns <- NULL
    laf <- do.call(open, model)
    return (laf)
}

