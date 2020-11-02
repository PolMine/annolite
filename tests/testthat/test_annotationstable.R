testthat::context("annotate")

test_that(
  "validity of as.annotationstable() output if reading table from disk",
  {
    outfile <- tempfile()
    write.csv(secretary_general_2000_annotations, file = outfile)
    x <- read.csv(file = outfile)
    is.annotationstable(as.annotationstable(x))
  }
)
