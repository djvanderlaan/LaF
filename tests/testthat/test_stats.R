
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
      city=c("Rotterdam", "Amsterdam ", "Berlin", "Paris", 
          "London", "Copenhagen", "", "Oslo"),
      stringsAsFactors=FALSE
    )

tmpcsv <- tempfile()
writeLines(lines, con=tmpcsv, sep="\n")
laf <- laf_open_csv(filename=tmpcsv, 
    column_types=c("integer", "categorical", "double", "string"))

context("Test calculation of column statistics")

test_that(
    "colmean works",
    {
        expect_that(as.numeric(colmean(laf, 1)), 
            equals(mean(data[,1], na.rm=TRUE)))
        expect_that(as.numeric(colmean(laf, 3)), 
            equals(mean(data[,3], na.rm=TRUE)))
        expect_that(as.numeric(colmean(laf, 1, na.rm=FALSE)), 
            equals(mean(data[,1], na.rm=FALSE)))
        expect_that(as.numeric(colmean(laf, 3, na.rm=FALSE)), 
            equals(mean(data[,3], na.rm=FALSE)))
        expect_that(as.numeric(colmean(laf$V3, na.rm=FALSE)), 
            equals(mean(data[,3], na.rm=FALSE)))
    })
test_that(
    "colsum works",
    {
        expect_that(as.numeric(colsum(laf, 1)), 
            equals(sum(data[,1], na.rm=TRUE)))
        expect_that(as.numeric(colsum(laf, 3)), 
            equals(sum(data[,3], na.rm=TRUE)))
        expect_that(as.numeric(colsum(laf, 1, na.rm=FALSE)), 
            equals(sum(data[,1], na.rm=FALSE)))
        expect_that(as.numeric(colsum(laf, 3, na.rm=FALSE)), 
            equals(sum(data[,3], na.rm=FALSE)))
        expect_that(as.numeric(colsum(laf$V3, na.rm=FALSE)), 
            equals(sum(data[,3], na.rm=FALSE)))
    })
test_that(
    "colrange works",
    {
        expect_that(as.numeric(colrange(laf, 1)), 
            equals(range(data[,1], na.rm=TRUE)))
        expect_that(as.numeric(colrange(laf, 3)), 
            equals(range(data[,3], na.rm=TRUE)))
        expect_that(as.numeric(colrange(laf, 1, na.rm=FALSE)), 
            equals(range(data[,1], na.rm=FALSE)))
        expect_that(as.numeric(colrange(laf, 3, na.rm=FALSE)), 
            equals(range(data[,3], na.rm=FALSE)))
        expect_that(as.numeric(colrange(laf$V3, na.rm=FALSE)), 
            equals(range(data[,3], na.rm=FALSE)))
    })
test_that(
    "colnmissing works",
    {
        expect_that(as.numeric(colnmissing(laf, 1:ncol(laf))), 
            equals(as.numeric(apply(data, 2, function(a) sum(is.na(a))))))
    })
test_that(
    "colfreq works",
    {
        expect_that(as.numeric(colfreq(laf, 1)), 
            equals(as.numeric(table(data[, 1], useNA="ifany"))))
        expect_that(as.numeric(colfreq(laf, 1, useNA="always")), 
            equals(as.numeric(table(data[, 1], useNA="always"))))
        expect_that(as.numeric(colfreq(laf, 1, useNA="no")), 
            equals(as.numeric(table(data[, 1], useNA="no"))))
        expect_that(as.numeric(colfreq(laf, 2)), 
            equals(as.numeric(table(data[, 2], useNA="ifany"))))
        expect_that(as.numeric(colfreq(laf, 3)), 
            equals(as.numeric(table(as.integer(data[, 3]), useNA="ifany"))))
    })


file.remove(tmpcsv)

