context("growth_status_scatter tests")

#make sure that constants used below exist
testing_constants()


test_that("impute_rit only accepts valid inputs", {

  expect_error(
    impute_rit(
      mapvizieR_object = mapviz,
      studentids = studentids_normal_use,
      measurementscale = 'Mathematics',
      impute_method = 'intentionally broken'
    ),
    'is not a valid imputation method'
  )

})


test_that("candidate_scaffold", {
  
  cs <- candidate_scaffold(processed_cdf)
  
  expect_equal(nrow(cs), 8602)
  expect_is(cs, 'data.frame')
  expect_equal(sum(cs$grade_level_season), 56325.5)
  
})


test_that("impute_rit_simple_average repairs cdf with intentionally missing rows", {
  
  missing_cdf <- processed_cdf
  missing_cdf[missing_cdf$testid == 122220176, ]$testritscore <- NA
  missing_cdf[missing_cdf$testid == 122220145, ]$testritscore <- NA
  
  sa <- impute_rit_simple_average(missing_cdf)
  
  expect_equal(sa[sa$testid == 122220145 & !is.na(sa$testid), ]$testritscore, 176)
  expect_equal(sa[sa$testid == 122220176 & !is.na(sa$testid), ]$testritscore, 184)
  
})