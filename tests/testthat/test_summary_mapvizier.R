context("mapvizier_summary tests")

test_that("sumamry works as expected", {
  ex <- summary(mapviz)
  expect_equal(ex$end_pct_75th_pctl %>% sum(na.rm = TRUE), 41.56)
  expect_equal(nrow(ex), 346)
  expect_equal(sum(ex$cgp, na.rm = TRUE), 7314.03)
  
  ex2 <- summary(mapviz, digits = 3)
  expect_equal(ex2$end_pct_75th_pctl %>% sum(na.rm = TRUE), 41.544)
  
})