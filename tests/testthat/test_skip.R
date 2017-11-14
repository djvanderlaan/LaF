
lines <- c(
  "1,M,1.45,Rotterdam",
  "2,F,12.00,Amsterdam",
  "3,,.22 ,Berlin",
  ",M,22,Paris",
  "4,F,12345,London",
  "5,M,,Copenhagen",
  "6,M,-12.1,",
  "7,F,-1,Oslo")
 
data <- data.frame(
      id=c(1,2,3,NA,4,5,6,7),
      gender=as.factor(c("M", "F", NA, "M", "F", "M", "M", "F")),
      x=c(1.45, 12, 0.22, 22, 12345, NA, -12.1, -1),
      city=c("Rotterdam", "Amsterdam", "Berlin", "Paris", 
          "London", "Copenhagen", "", "Oslo"),
      stringsAsFactors=FALSE
    )

context("Skip option")

test_that("Skip works for CSV (\\n end-of-line)", {
  tmpcsv <- tempfile()
  writeLines(c("foobar", lines), con=tmpcsv, sep="\n")
  laf <- laf_open_csv(filename=tmpcsv, 
      column_types=c("integer", "categorical", "double", "string"), 
      skip=1)
  expect_that(nrow(laf), equals(nrow(data)))
  testdata <- laf[]
  expect_that(testdata[,1], equals(data[,1]))
  expect_that(sort(levels(testdata[[2]])), equals(c("F", "M")))
  expect_that(as.character(testdata[,2]), equals(as.character(data[,2])))
  expect_that(testdata[,3], equals(data[,3]))
  expect_that(testdata[,4], equals(data[,4]))
  expect_that(is.na(testdata[4,1]), is_true())
  expect_that(is.na(testdata[3,2]), is_true())
  expect_that(is.na(testdata[6,3]), is_true())
  file.remove(tmpcsv)
})

test_that("Skip works for CSV (\\r\\n end-of-line)", {
  tmpcsv <- tempfile()
  writeLines(c("foobar", lines), con=tmpcsv, sep="\r\n")
  laf <- laf_open_csv(filename=tmpcsv, 
      column_types=c("integer", "categorical", "double", "string"), 
      skip=1)
  expect_that(nrow(laf), equals(nrow(data)))
  testdata <- laf[]
  expect_that(testdata[,1], equals(data[,1]))
  expect_that(sort(levels(testdata[[2]])), equals(c("F", "M")))
  expect_that(as.character(testdata[,2]), equals(as.character(data[,2])))
  expect_that(testdata[,3], equals(data[,3]))
  expect_that(testdata[,4], equals(data[,4]))
  expect_that(is.na(testdata[4,1]), is_true())
  expect_that(is.na(testdata[3,2]), is_true())
  expect_that(is.na(testdata[6,3]), is_true())
  file.remove(tmpcsv)
})

