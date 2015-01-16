context("running cdf prep on sample data provided by NWEA")

test_that("prep_cdf_long correctly preps sample data", {
  samp_cdf <- prep_cdf_long(ex_CombinedAssessmentResults)
  expect_equal(check_cdf_long(samp_cdf)$boolean ,TRUE)
})