context("cohort cgp history tests")

test_that("cohort_cgp_hist_plot should return a plot", {  
  
  p <- cohort_cgp_hist_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    entry_grade_seasons = c(-0.8, 5.2)
  ) 
  
  expect_is(p, 'ggplot')
  p <- ggplot_build(p)
  expect_equal(p$data[[2]]$y %>% round(2) %>% sum(), 134.33)
})