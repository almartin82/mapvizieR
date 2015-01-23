context("testing cdf_check functions for accurate behavior and error messages")

test_that("check_cdf correctly identifies a cdf with bad names", {
  
  #running check_cdf on the raw assessment results should fail.
  expect_error(check_cdf_long(ex_CombinedAssessmentResults), "failed the VALID NAMES test")
  
})

test_that("check_cdf correctly identifies a cdf with improper seasons", {
  
  mangled <- prep_cdf_long(ex_CombinedAssessmentResults)
  mangled <- mangled[sample(nrow(mangled), 100), ]
  mangled[, 'fallwinterspring'] <- 'fall/winter'
  
  #running check_cdf on the raw assessment results should fail.
  expect_error(check_cdf_fws(mangled), "failed the VALID SEASONS test")
  
})


test_that("check_processed_cdf should return TRUE on the sample data", {
  #prep
  ex_roster <- prep_roster(ex_CombinedStudentsBySchool)
  ex_cdf <- prep_cdf_long(ex_CombinedAssessmentResults)
  ex_mapvizieR <- mapvizieR(ex_cdf, ex_roster)
  ex_processed_cdf <- ex_mapvizieR[['cdf']]

  #asserts
  expect_true(check_processed_names(ex_processed_cdf))
  expect_true(check_processed_cdf(ex_processed_cdf)$boolean)

})