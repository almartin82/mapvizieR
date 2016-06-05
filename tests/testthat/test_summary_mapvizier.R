context("mapvizier_summary tests")

ex <- summary(mapviz$growth_df)

test_that("summary works as expected on growth df", {
  expect_equal(ex$end_pct_75th_pctl %>% sum(na.rm = TRUE), 37.49)
  expect_equal(nrow(ex), 149)
  expect_equal(sum(ex$cgp, na.rm = TRUE), 7344.26)
  
  ex2 <- summary(mapviz$growth_df, digits = 3)
  expect_equal(ex2$end_pct_75th_pctl %>% sum(na.rm = TRUE), 37.462)
})

test_that("cohort/grade status percentile works", {
  expect_equal(sum(ex$start_cohort_status_npr, na.rm = TRUE), 9093)
})

ex2 <- summary(mapviz)

test_that("new summary method works as expected", {
  
  expect_is(ex2, 'mapvizieR_summary')
  expect_is(ex2$growth_summary, 'mapvizieR_growth_summary')
  expect_is(ex2$cdf_summary, 'mapvizieR_cdf_summary')
  
  expect_equal(sum(ex2$cdf_summary$mean_testritscore), 31195.44, tolerance = .01)
})