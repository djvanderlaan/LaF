

p <- laf_open_fwf("data/data.dat", 
    column_widths = c(10, 1, 2, rep(2, 5), rep(6,5), rep(6,5)),
    column_names = c("id", "gender", "age", paste("int", 1:5, sep=""),
        paste("norm", 1:5, sep=""), paste("lognorm", 1:5, sep="")),
    column_types = c("integer", "categorical", "integer",
        rep("integer", 5), rep("double", 5), rep("double", 5)))



