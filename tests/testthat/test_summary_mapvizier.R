context("mapvizier_summary tests")

test_that("summary works as expected", {
  ex <- summary(mapviz)
  expect_equal(ex$end_pct_75th_pctl %>% sum(na.rm = TRUE), 37.49)
  expect_equal(nrow(ex), 149)
  expect_equal(sum(ex$cgp, na.rm = TRUE), 7344.26)
  
  ex2 <- summary(mapviz, digits = 3)
  expect_equal(ex2$end_pct_75th_pctl %>% sum(na.rm = TRUE), 37.462)
})