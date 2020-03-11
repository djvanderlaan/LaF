
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

tmpfwf <- tempfile()
writeLines(lines, con=tmpfwf, sep="\n")
 
context("Test trimming of strings")

test_that(
    "the trim=TRUE option works",
    {
        laf <- laf_open_fwf(filename=tmpfwf, 
            column_types=c("categorical", "string"),
            column_widths=c(2,10), trim=TRUE
            )
        expect_equal(as.character(laf$V1[]), col1trimmed)
        expect_equal(laf$V2[], col2trimmed)
    })

test_that(
    "the trim=FALSE option works",
    {
        laf <- laf_open_fwf(filename=tmpfwf, 
            column_types=c("categorical", "string"),
            column_widths=c(2,10), trim=FALSE
            )
        expect_equal(as.character(laf$V1[]), col1)
        expect_equal(laf$V2[], col2)
    })


file.remove(tmpfwf)

