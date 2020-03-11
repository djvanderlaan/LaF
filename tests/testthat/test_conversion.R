
lines <- c(
  "     1",
  "1.    ",
  "  1   ",
  "1.12  ",
  ".123  ",
  "   0.1",
  "1E3   ",
  "1E-4  ",
  "1.12E2",
  " 1E-4 ",
  ".1E+3 ")
 
data <- c(1, 1, 1, 1.12, 0.123, 0.1, 1000, 0.0001, 112, 0.0001, 100)

context("Test conversion of various numeric formats")

test_that("conversion of numeric formats works", {
  fn <- tempfile()
  writeLines(lines, con=fn, sep="\n")
  laf <- laf_open_fwf(filename=fn, 
      column_types=c("double"),
      column_widths=c(6)
    )
  testdata <- laf$V1[]
  expect_equal(testdata, data)
  file.remove(fn)
})


