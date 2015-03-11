context("running cdf prep on sample data provided by NWEA")

#make sure that constants used below exist
testing_constants()


test_that("prep_cdf_long correctly preps sample data", {
  expect_true(check_cdf_long(prepped_cdf)$boolean, TRUE)
  expect_equal(table(prepped_cdf$map_year_academic)[[2]], 7041)
})

test_that("process_cdf_long correctly processes sample data", {
    
  expect_true(check_processed_cdf(processed_cdf)$boolean)
  expect_equal(table(processed_cdf$grade_level_season)[[7]], 83)
  expect_equal(table(processed_cdf$grade_level_season)[[17]], 279)
})