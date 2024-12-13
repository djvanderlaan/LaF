


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



# The bug above also lead to discovery that an incomplete line lead to 
# incomplete reading of file
test_that("Handle imcomplete line", {

  tmpcsv  <- tempfile(fileext = "csv")
  writeLines("1,2,3\n4,5\n6,7,8", tmpcsv)
  laf <- LaF::laf_open_csv(tmpcsv, column_types = rep("integer", 3))
  expect_warning(res <- laf[,])

  expect_equal(res[[1]], c(1,4,6))
  expect_equal(res[[2]], c(2,5,7))
  expect_equal(res[[3]], c(3,NA,8))
})
