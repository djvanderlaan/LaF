lines <- c(
  "1,M,1.45,Rotterdam",
  "2,F,12.00,Amsterdam",
  "3,,.22,Berlin",
  ",M,22,Paris",
  "4,F,12345,London",
  "5,M,,Copenhagen",
  "6,M,-12.1,",
  "7,F,-1,Oslo")
 
data <- data.frame(
      id=c(1,2,3,NA,4,5,6,7),
      gender=factor(c("M", "F", NA, "M", "F", "M", "M", "F"), levels=c("M", "F")),
      x=c(1.45, 12, 0.22, 22, 12345, NA, -12.1, -1),
      city=c("Rotterdam", "Amsterdam", "Berlin", "Paris", 
          "London", "Copenhagen", "", "Oslo"),
      stringsAsFactors=FALSE
    )

writeLines(lines, con="tmp.csv", sep="\n")

context("Test reading and writing of data models")

laf <- laf_open_csv(filename="tmp.csv", 
    column_types=c("integer", "categorical", "double", "string"))

test_that(
    "write_dm and read_dm work",
    {
        write_dm(laf, modelfile="tmp.yaml")
        model <- read_dm("tmp.yaml")
        laf2 <- laf_open(model)
        testdata <- laf2[]
        expect_that(testdata[,1], equals(data[,1]))
        expect_that(sort(levels(testdata[[2]])), equals(c("F", "M")))
        expect_that(as.character(testdata[,2]), equals(as.character(data[,2])))
        expect_that(testdata[,3], equals(data[,3]))
        expect_that(testdata[,4], equals(data[,4]))
        expect_that(is.na(testdata[4,1]), is_true())
        expect_that(is.na(testdata[3,2]), is_true())
        expect_that(is.na(testdata[6,3]), is_true())

        datamodel <- paste(
            "type: csv",
            "filename: tmp.csv",
            "columns:",
            "- {name: V1, type: integer}",
            "- {name: V2, type: categorical}",
            "- name: V3",
            "  type: double",
            "- name: V4",
            "  type: string",
            sep="\n")
        writeLines(datamodel, con="tmp.yaml")
        model <- read_dm("tmp.yaml")
        laf2 <- laf_open(model)
        testdata <- laf2[]
        expect_that(testdata[,1], equals(data[,1]))
        expect_that(sort(levels(testdata[[2]])), equals(c("F", "M")))
        expect_that(as.character(testdata[,2]), equals(as.character(data[,2])))
        expect_that(testdata[,3], equals(data[,3]))
        expect_that(testdata[,4], equals(data[,4]))
        expect_that(is.na(testdata[4,1]), is_true())
        expect_that(is.na(testdata[3,2]), is_true())
        expect_that(is.na(testdata[6,3]), is_true())
    })

test_that("detect_dm_csv works", {
    model <- detect_dm_csv("tmp.csv", header=FALSE, factor_fraction=0.8)
    laf <- laf_open(model)
    testdata <- laf[]
    expect_that(testdata[,1], equals(data[,1]))
    expect_that(sort(levels(testdata[[2]])), equals(c("F", "M")))
    expect_that(as.character(testdata[,2]), equals(as.character(data[,2])))
    expect_that(testdata[,3], equals(data[,3]))
    expect_that(testdata[,4], equals(data[,4]))
    expect_that(is.na(testdata[4,1]), is_true())
    expect_that(is.na(testdata[3,2]), is_true())
    expect_that(is.na(testdata[6,3]), is_true())
})

test_that("detect_dm_csv handles empty columns correctly (regression test issue #1)", {
    lines <- c("1;;A", "2;;A", "3;;B", "4;;B")
    writeLines(lines, "test.csv")
    expect_warning(dm <- detect_dm_csv("test.csv", sep=";"))
    codes <- LaF:::.laf_to_typecode(dm$columns$type)
    expect_that(codes, is_a("integer"))
})

lines <- c(
  " 1M 1.45Rotterdam ",
  " 2F12.00Amsterdam ",
  " 3  .22 Berlin    ",
  "  M22   Paris     ",
  " 4F12345London    ",
  " 5M     Copenhagen",
  " 6M-12.1          ",
  " 7F   -1Oslo      ")
 
data <- data.frame(
      id=c(1,2,3,NA,4,5,6,7),
      gender=c("M", "F", "", "M", "F", "M", "M", "F"),
      x=c(1.45, 12, 0.22, 22, 12345, NA, -12.1, -1),
      city=c("Rotterdam", "Amsterdam", "Berlin", "Paris", 
          "London", "Copenhagen", "", "Oslo"),
      stringsAsFactors=FALSE
    )

test_that("read_dm_blaise works", {
    writeLines(lines, con="tmp.fwf", sep="\n")
    writeLines(c( "DATAMODEL test", "FIELDS", " id \"label\" : INTEGER[2]", " gender : STRING[1]", " x : REAL[5] {comment}", " city : STRING[10]", "ENDMODEL"), con="tmp.bla")
    model <- read_dm_blaise("tmp.bla", datafilename="tmp.fwf")
    laf <- laf_open(model)
    testdata <- laf[]
    expect_that(testdata[,1], equals(data[,1]))
    expect_that(as.character(testdata[,2]), equals(as.character(data[,2])))
    expect_that(testdata[,3], equals(data[,3]))
    expect_that(testdata[,4], equals(data[,4]))
    expect_that(is.na(testdata[4,1]), is_true())
    expect_that(is.na(testdata[6,3]), is_true())
})

