
detect_datamodel_csv <- function(filename, sep=",", dec=".", header=FALSE, 
        nlines=1000, sample=FALSE, factor_fraction=0.2, ...) {
    if (sample) {
        lines <- sample_lines(filename, n=nlines)
        con <- textConnection(lines)
    } else con <- file(filename, "rt")
    data  <- read.table(con, nrow=nlines, sep=sep, dec=dec, header=header, ...)
    close(con)
    name <- names(data)
    type <- sapply(data, function(d) {
        type <- class(d)
        if (identical(type, "factor")) {
            f <- nlevels(d)/length(d)
            if (f > factor_fraction) {
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
        columns = data.frame(name=name, type=type, stringsAsFactors=FALSE),
        dec = dec,
        sep = sep,
        skip = ifelse(header, 1, 0)
    ))
}

read_dm <- function(filename, ...) {
    if (!require("yaml")) 
        stop("The library yaml is required to read and write data models.")
    model <- yaml.load_file(filename)
    # columns are stored rowwise in file convert to column wise
    columns <- model$columns
    model$columns <- list()
    if (length(columns)) {
        for (col in names(columns[[1]])) {
            model$columns[[col]] <- sapply(columns, function(d) d[[col]])
        }
    }
    model$columns <- as.data.frame(model$columns, stringsAsFactors=FALSE)
    # overwrite options in file by extra options given in call
    model[names(list(...))] <- list(...)
    return(model)
}

write_dm <- function(model, filename) {
    if (!require("yaml")) 
        stop("The library yaml is required to read and write data models.")
    # if model is a laf object, build data model from laf object
    if (inherits(p, "laf")) {
        laf <- model
        model <- list()
        model$type <- laf@file_type
        model$filename <- laf@filename
        model[names(laf@options)] <- laf@options
        model$columns <- data.frame(name=laf@column_names,
            type=.laf_to_type(laf@column_types))
        if (length(laf@column_widths)) 
            model$columns$width <- laf@column_widths
    }
    # write model to file in yaml format
    writeLines(as.yaml(model, column.major=F), con=filename)
}

laf_open <- function(model, ...) {
    model[names(list(...))] <- list(...)
    model$column_names  <- model$columns$name
    model$column_types <- model$columns$type
    if (identical(model$type, "csv")) {
        open <- "laf_open_csv"
    } else if (identical(model$type, "fwf")) {
        model$column_widths <- model$columns$width
        open <- "laf_open_fwf"
    }
    model$type    <- NULL
    model$columns <- NULL
    laf <- do.call(open, model)
    return (laf)
}

