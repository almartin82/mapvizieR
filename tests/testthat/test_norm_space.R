context("norm plots")

test_that("empty norm grade space should return a ggplot object", {  
  p <- empty_norm_grade_space('Reading', norms = 2011)
  p_build <- ggplot2::ggplot_build(p)
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$data[[1]]), 429)
  expect_equal(p_build$data[[2]]$y %>% sum(), 29647)
})  


test_that("empty norm grade space with 2015 norms", {  
  p <- empty_norm_grade_space('Reading', norms = 2015)
  p_build <- ggplot2::ggplot_build(p)
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$data[[1]]), 429)
  expect_equal(p_build$data[[2]]$y %>% sum(), 29521)
})  


test_that("empty norm grade space with SCHOOL attainment norms", {  
  p <- empty_norm_grade_space('Reading', norms = 2015, school = TRUE)
  p_build <- ggplot2::ggplot_build(p)
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$data[[1]]), 429)
  expect_equal(p_build$data[[2]]$y %>% sum(), 29521)
})  