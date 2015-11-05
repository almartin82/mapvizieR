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


test_that("make_npr_consistent works", {
  
  for_test <- prepped_cdf %>% 
    dedupe_cdf(method = "NWEA") %>%
    grade_level_seasonify() %>%
    grade_season_labelify() %>%
    grade_season_factors() 
  
  n11 <- make_npr_consistent(cdf = for_test, norm_study = 2011)
  n15 <- make_npr_consistent(cdf = for_test, norm_study = 2015)
  
  expect_equal(nrow(n11), nrow(n15))
  expect_equal(n11$consistent_percentile %>% sum(na.rm = TRUE), 471468)
  expect_equal(n15$consistent_percentile %>% sum(na.rm = TRUE), 478973)
})