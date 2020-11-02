testthat::context("annotate")

test_that(
  "annotate",
  {
    library(polmineR)
    use("polmineR")
    p <- partition("REUTERS", id = "127")
    
    testthat::expect_error(
      annotate(p, file = file.path(tempdir(), "abcdefg", "tmp_anno.rds"))
    )
  }
)
