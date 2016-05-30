context("mapvizier_summary tests")

ex <- summary(mapviz)

test_that("summary works as expected", {
  expect_equal(ex$end_pct_75th_pctl %>% sum(na.rm = TRUE), 37.49)
  expect_equal(nrow(ex), 149)
  expect_equal(sum(ex$cgp, na.rm = TRUE), 7344.26)
  
  ex2 <- summary(mapviz, digits = 3)
  expect_equal(ex2$end_pct_75th_pctl %>% sum(na.rm = TRUE), 37.462)
})

test_that("cohort/grade status percentile works", {
  expect_equal(sum(ex$start_cohort_status_npr, na.rm = TRUE), 9093)
})