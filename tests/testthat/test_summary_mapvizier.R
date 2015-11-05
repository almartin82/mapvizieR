context("mapvizier_summary tests")

#make sure that constants used below exist
testing_constants()

test_that("sumamry works as expected", {
  ex <- summary(mapviz)
  expect_equal(ex$end_pct_75th_pctl %>% sum(na.rm = TRUE), 41.56)

  ex2 <- summary(mapviz, digits = 3)
  expect_equal(ex2$end_pct_75th_pctl %>% sum(na.rm = TRUE), 41.544)
})