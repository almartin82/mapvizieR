context("norm plots")

#make sure that constants used below exist
testing_constants()


test_that("empty norm grade space should return a ggplot object", {  
  p <- empty_norm_grade_space('Reading')
  p_build <- ggplot2::ggplot_build(p)
  expect_true(is.ggplot(typ_test))
  expect_equal(nrow(p_build$data[[1]]), 429)
})  

