
context("BLAISE")

testbla <- 'DATAMODEL TEST
FIELDS
 FIELD1 "This is field1": STRING[1]
 FIELD2 "This is a field with weird characters in its description òé": INTEGER[2]
ENDMODEL'


test_that("read_dm_blaise handles encodings", {

  fn <- tempfile()

  con <- file(fn, "wt", encoding = "latin1")
  writeLines(testbla, con)
  close(con)

  dm <- read_dm_blaise(fn)
  expect_equal(dm$columns$name, c("FIELD1", "FIELD2"))
  expect_equal(dm$columns$type, c("string", "integer"))
  expect_equal(dm$columns$width, c(1L, 2L))

  dm <- read_dm_blaise(fn, encoding = "latin1")
  expect_equal(dm$columns$name, c("FIELD1", "FIELD2"))
  expect_equal(dm$columns$type, c("string", "integer"))
  expect_equal(dm$columns$width, c(1L, 2L))

  expect_error(suppressWarnings(dm <- read_dm_blaise(fn, encoding = "UTF-8")))

  con <- file(fn, "wt", encoding = "UTF-8")
  writeLines(testbla, con)
  close(con)

  dm <- read_dm_blaise(fn, encoding = "UTF-8")
  expect_equal(dm$columns$name, c("FIELD1", "FIELD2"))
  expect_equal(dm$columns$type, c("string", "integer"))
  expect_equal(dm$columns$width, c(1L, 2L))

  
  file.remove(fn)
})

