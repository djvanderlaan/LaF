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

context("Test changing of levels")

laf <- laf_open_csv(filename="tmp.csv", 
    column_types=c("integer", "categorical", "double", "string"))

test_that(
    "setting levels works",
    {
        levels(laf)[["V1"]] <- data.frame(levels=1:10, labels=paste0("C", 1:10)) 
        expect_that(is.data.frame(levels(laf)[["V1"]]), is_true())
        expect_that(nrow(levels(laf)[["V1"]]), equals(10))
        data$id <- factor(data$id, levels=1:10, labels=paste0("C", 1:10))
        expect_that(laf$V1[], equals(data$id))

        levels(data$id) <- paste0("D", 1:10)
        c <- laf$V1
        levels(c) <- data.frame(levels=1:10, labels=paste0("D", 1:10))
        expect_that(c[], equals(data$id))
    })

test_that(
    "write_dm and read_dm work with levels",
    {
        levels(laf)[["V1"]] <- data.frame(levels=1:10, labels=paste0("C", 1:10)) 
        write_dm(laf, modelfile="tmp.yaml")
        model <- read_dm("tmp.yaml")
        laf2 <- laf_open(model)
        expect_that(laf[], equals(laf2[]))
    })

