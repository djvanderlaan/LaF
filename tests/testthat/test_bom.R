
context("BOM")

dta <- data.frame(
  foo = c(1,2,3,10),
  bar = c(2.2, 3.3, 4.4, 9.9)
)

test_that("DOM detection works for fixed width", {

  lines <- " 12.2\n 23.3\n 34.4\n109.9"
  fn <- tempfile()

  con <- file(fn, "wt", encoding="UTF-8")
  # No BOM writeChar("\ufeff", con, eos = NULL)
  writeChar(lines, con, eos="\n")
  close(con)

  con <- laf_open_fwf(fn,
    column_names = c("foo", "bar"),
    column_widths = c(2,3),
    column_types = c("integer", "numeric"))

  expect_equal(con[,], dta)
  expect_equal(con[1,], dta[1,])
  expect_equivalent(con[4,], dta[4,])
  expect_equal(nrow(con), nrow(dta))
  close(con)
  
  con <- file(fn, "wt", encoding="UTF-8")
  writeChar("\ufeff", con, eos = NULL)
  writeChar(lines, con, eos="\n")
  close(con)

  con <- laf_open_fwf(fn,
    column_names = c("foo", "bar"),
    column_widths = c(2,3),
    column_types = c("integer", "numeric"))

  expect_equal(con[,], dta)
  expect_equal(con[1,], dta[1,])
  expect_equivalent(con[4,], dta[4,])
  expect_equal(nrow(con), nrow(dta))
  close(con)
  
  file.remove(fn)
})

test_that("DOM detection works for CSV", {

  lines <- "1,2.2\n2,3.3\n3,4.4\n10,9.9"
  fn <- tempfile()

  con <- file(fn, "wt", encoding="UTF-8")
  # No BOM writeChar("\ufeff", con, eos = NULL)
  writeChar(lines, con, eos="\n")
  close(con)

  con <- laf_open_csv(fn,
    column_names = c("foo", "bar"),
    column_types = c("integer", "numeric"))

  expect_equal(con[,], dta)
  expect_equal(con[1,], dta[1,])
  expect_equivalent(con[4,], dta[4,])
  expect_equal(nrow(con), nrow(dta))
  close(con)
  
  con <- file(fn, "wt", encoding="UTF-8")
  writeChar("\ufeff", con, eos = NULL)
  writeChar(lines, con, eos="\n")
  close(con)

  con <- laf_open_csv(fn,
    column_names = c("foo", "bar"),
    column_types = c("integer", "numeric"))

  expect_equal(con[,], dta)
  expect_equal(con[1,], dta[1,])
  expect_equivalent(con[4,], dta[4,])
  expect_equal(nrow(con), nrow(dta))
  close(con)
  
  file.remove(fn)
})

