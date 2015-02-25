context("running cdf prep on sample data provided by NWEA")

samp_cdf <- prep_cdf_long(ex_CombinedAssessmentResults)

test_that("prep_cdf_long correctly preps sample data", {
  expect_true(check_cdf_long(samp_cdf)$boolean, TRUE)
  expect_equal(table(samp_cdf$map_year_academic)[[2]], 7041)
})

test_that("process_cdf_long correctly processes sample data", {
  
  prepped_roster <- prep_roster(ex_CombinedStudentsBySchool)
  samp_cdf$grade <- grade_levelify_cdf(samp_cdf, prepped_roster)
  processed_cdf <- process_cdf_long(samp_cdf)
  
  expect_true(check_processed_cdf(processed_cdf)$boolean)
  expect_equal(table(processed_cdf$grade_level_season)[[7]], 83)
  expect_equal(table(processed_cdf$grade_level_season)[[17]], 279)
})