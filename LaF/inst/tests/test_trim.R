
lines <- c(
  " ARotterdam ",
  "AAAmsterdam ",
  " BBerlin    ",
  "    Paris   ",
  "A     London",
  "BBCopenhagen",
  "A           ",
  "  Oslo      ")

col1        <- c(" A", "AA", " B", "  ", "A ", "BB", "A ", "  ")
col1trimmed <- c("A",  "AA", "B",  NA,   "A",  "BB", "A",  NA)
col2 <- c(
  "Rotterdam ",
  "Amsterdam ",
  "Berlin    ",
  "  Paris   ",
  "    London",
  "Copenhagen",
  "          ",
  "Oslo      ")
col2trimmed <- c(
  "Rotterdam",
  "Amsterdam",
  "Berlin",
  "Paris",
  "London",
  "Copenhagen",
  "",
  "Oslo")

writeLines(lines, con="tmp.fwf", sep="\n")
 
context("Test trimming of strings")

test_that(
    "the trim=TRUE option works",
    {
        laf <- laf_open_fwf(filename="tmp.fwf", 
            column_types=c("categorical", "string"),
            column_widths=c(2,10), trim=TRUE
            )
        expect_that(as.character(laf$V1[]), equals(col1trimmed))
        expect_that(laf$V2[], equals(col2trimmed))
    })

test_that(
    "the trim=FALSE option works",
    {
        laf <- laf_open_fwf(filename="tmp.fwf", 
            column_types=c("categorical", "string"),
            column_widths=c(2,10), trim=FALSE
            )
        expect_that(as.character(laf$V1[]), equals(col1))
        expect_that(laf$V2[], equals(col2))
    })


unlink("tmp.fwf")

