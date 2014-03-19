library(Rcpp)

r_files <- list.files("R/", pattern="*.R")
r_files <- file.path("R", r_files)
r_files <- r_files[order(gsub(".R$", "", r_files))]
for (r_file in r_files) {
    source(r_file)
}

dyn.load("LaF.so")

