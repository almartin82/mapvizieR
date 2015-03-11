context("testing cdf_check functions for accurate behavior and error messages")

#make sure that constants used below exist
testing_constants()

test_that("check_cdf correctly identifies a cdf with bad names", {
  
  #running check_cdf on the raw assessment results should fail.
  expect_error(check_cdf_long(ex_CombinedAssessmentResults), "failed the VALID NAMES test")
  
})


test_that("check_cdf correctly identifies a cdf with improper seasons", {
  
  mangled <- cdf
  mangled[, 'fallwinterspring'] <- 'fall/winter'
  
  #running check_cdf on the raw assessment results should fail.
  expect_error(check_cdf_fws(mangled), "failed the VALID SEASONS test")
  
})


test_that("processed cdf tests should return TRUE on the sample data", {

  #asserts
  expect_true(check_processed_names(cdf))
  expect_true(check_processed_cdf(cdf)$boolean)

})


test_that("processed cdf tests should indicate an error on bad data", {
  #on vanilla cdf
  expect_error(
    check_processed_names(ex_CombinedAssessmentResults),
    "Your processed CDF failed the VALID NAMES test."
  )
  expect_error(
    check_processed_cdf(ex_CombinedAssessmentResults),
    "CDF failed the VALID NAMES test."
  )
  
  #on partially processed cdf
  partial_cdf <- prep_cdf_long(ex_CombinedAssessmentResults)

  expect_error(
    check_processed_names(partial_cdf),
    "Your CDF is missing the following fields that are required"
  )
  expect_error(
    check_processed_names(partial_cdf),
    "grade, grade_level_season, grade_season_label"
  )
  
})