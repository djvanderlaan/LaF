


# Generate test data
column_types <- c("integer", "string")
testdata <- data.frame(
  a = 1:2,
  b = c("ABC,DEF",  "ABCDEF")
)
testdata2 <- data.frame(
  a = 1:2,
  b = c("ABCDEF",  "ABC,DEF")
)

context("Regression test for bug with separator within quotes on first line")

test_that("Separator in first row in quote", {
  tmpcsv  <- tempfile(fileext = "csv")
  write.table(testdata, file = tmpcsv, row.names = FALSE, 
    col.names = FALSE, sep = ',')

  laf <- LaF::laf_open_csv(tmpcsv, column_types = column_types, 
    column_name = names(testdata))
  res <- laf[,]

  expect_equal(testdata, res)

  file.remove(tmpcsv)
})

test_that("Separator in second row in quote", {
  tmpcsv  <- tempfile(fileext = "csv")
  write.table(testdata2, file = tmpcsv, row.names = FALSE, 
    col.names = FALSE, sep = ',')

  laf <- LaF::laf_open_csv(tmpcsv, column_types = column_types, 
    column_name = names(testdata2))
  res <- laf[,]

  expect_equal(testdata2, res)

  file.remove(tmpcsv)
})


