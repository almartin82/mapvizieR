context("cohort cgp history tests")

test_that("cohort_cgp_hist_plot should return a plot", {  
  
  p <- cohort_cgp_hist_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    first_and_spring_only = FALSE,
    entry_grade_seasons = c(-0.8, 5.2)
  ) 
  
  expect_s3_class(p, 'ggplot')
  p <- ggplot_build(p)
  expect_equal(p$data[[2]]$y %>% round(2) %>% sum(na.rm = TRUE), 90.07)
  
  p2 <- cohort_cgp_hist_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    entry_grade_seasons = c(-0.8, 5.2)
  )
  
  expect_s3_class(p2, 'ggplot')
  p2 <- ggplot_build(p2)
  expect_equal(p2$data[[5]][1,1:2] %>% sum(na.rm = TRUE) %>% round(2), 89.68)
  
})


test_that("cohort_cgp_hist_plot parameter args", {  
  
  p <- cohort_cgp_hist_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    first_and_spring_only = FALSE,
    entry_grade_seasons = c(-0.8, 5.2),
    no_labs = TRUE
  ) 
  
  expect_s3_class(p, 'ggplot')
  p <- ggplot_build(p)
  expect_equal(p$data[[2]]$y %>% round(2) %>% sum(na.rm = TRUE), 90.07)
  
})


test_that("mult_cohort_cgp_hist_plot produces valid plot", {  
  
  p_mult <- multi_cohort_cgp_hist_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_ms,
    measurementscale = 'Mathematics',
    first_and_spring_only = FALSE,
    entry_grade_seasons = c(-0.8, 5.2)
  )
  
  expect_s3_class(p_mult, 'ggplot')
  p_mult <- ggplot_build(p_mult)
  expect_equal(p_mult$data[[1]]$y %>% round(2) %>% sum(na.rm = TRUE), 459.32)
  
})



test_that("alt_cohort_cgp_hist_plot should return a plot", {  
  
  p <- alt_cohort_cgp_hist_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    first_and_spring_only = FALSE,
    entry_grade_seasons = c(-0.8, 5.2)
  ) 
  
  expect_s3_class(p, 'ggplot')
  p <- ggplot_build(p)
  expect_equal(p$data[[2]]$y %>% round(2) %>% sum(na.rm = TRUE), 78)
  
})

test_that("alt_cohort_cgp_hist_plot with NPR labels", {  
  
  p <- alt_cohort_cgp_hist_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    first_and_spring_only = FALSE,
    entry_grade_seasons = c(-0.8, 5.2),
    plot_labels = 'NPR'
  ) 
  
  expect_s3_class(p, 'ggplot')
  p <- ggplot_build(p)
  expect_equal(p$data[[2]]$y %>% round(2) %>% sum(na.rm = TRUE), 78)
  
})

test_that("alt_multi_cohort_cgp_hist_plot minimal test", {  
  
  p <- alt_multi_cohort_cgp_hist_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    first_and_spring_only = FALSE,
    entry_grade_seasons = c(-0.8, 5.2)
  ) 
  
  expect_s3_class(p, 'ggplot')
  p <- ggplot_build(p)
  expect_equal(p$data[[2]]$y %>% round(2) %>% sum(na.rm = TRUE), 73)
  
})


test_that("alt_multi_cohort_cgp_hist_plot with NPR labels", {

  p <- alt_multi_cohort_cgp_hist_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    first_and_spring_only = FALSE,
    entry_grade_seasons = c(-0.8, 5.2),
    plot_labels = 'NPR'
  )

  expect_s3_class(p, 'ggplot')
  p <- ggplot_build(p)
  expect_equal(p$data[[2]]$y %>% round(2) %>% sum(na.rm = TRUE), 73)

})
