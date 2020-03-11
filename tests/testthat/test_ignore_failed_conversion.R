context("Ignore failed conversion option")

dta <- data.frame(
  foo = c(1,2,NA,3,4,NA),
  bar = c(2.3,3.3,4.4,NA,NA,6.6),
  stringsAsFactors = TRUE
)

test_that("ignore_failed_conversion works for CSV", {
  
  test_data <- "foo,bar\n1,2.3\n2,3.3\n-,4.4\n3,---\n4,\n,6.6\n"
  fn <- tempfile()
  writeLines(test_data, fn)
  
  laf <- laf_open_csv(fn, column_types = c("integer", "numeric"), 
    column_names = c("foo", "bar"), skip = 1)
  expect_error(laf[,])
  close(laf)
  
  laf <- laf_open_csv(fn, column_types = c("integer", "numeric"), 
    column_names = c("foo", "bar"), skip = 1, ignore_failed_conversion = TRUE)
  expect_equal(laf[,], dta)
  close(laf)
  
  file.remove(fn)
})



test_that("ignore_failed_conversion works for fixed width", {
  
  test_data <- "12.3\n23.3\n-4.4\n3---\n4   \n-6.6"
  fn <- tempfile()
  writeLines(test_data, fn)
  
  laf <- laf_open_fwf(fn, column_types = c("integer", "numeric"), 
    column_names = c("foo", "bar"), column_widths = c(1,3))
  expect_error(laf[,])
  close(laf)
  
  laf <- laf_open_fwf(fn, column_types = c("integer", "numeric"), 
    column_names = c("foo", "bar"), column_widths = c(1,3), 
    ignore_failed_conversion = TRUE)
  expect_equal(laf[,], dta)
  close(laf)
  
  file.remove(fn)
})

