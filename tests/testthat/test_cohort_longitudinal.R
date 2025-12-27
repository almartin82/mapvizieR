context("cohort longitudinal plot tests")

test_that("cohort_longitudinal_npr_plot should return valid plot", {

  p <- cohort_longitudinal_npr_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    first_and_spring_only = TRUE,
    entry_grade_seasons = c(-0.8, 5.2)
  )
  
  expect_s3_class(p, 'ggplot')
  p <- ggplot_build(p)
  expect_equal( p$data[[2]]$y %>% sum(), 10354.33, tolerance = 0.1)
  
})


test_that("cohort_longitudinal_npr_plot with name annotations", {
  
  p <- cohort_longitudinal_npr_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    first_and_spring_only = TRUE,
    entry_grade_seasons = c(-0.8, 4.2), 
    name_annotations = TRUE
  )
  
  expect_s3_class(p, 'ggplot')
  p <- ggplot_build(p)
  expect_equal(p$data[[2]]$y %>% sum(), 6198.022, tolerance = 0.1)
  
})