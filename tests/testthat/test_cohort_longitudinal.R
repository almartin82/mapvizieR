context("cohort longitudinal plot tests")

test_that("cohort_longitudinal_npr_plot should return valid plot", {

  p <- cohort_longitudinal_npr_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    first_and_spring_only = TRUE,
    entry_grade_seasons = c(-0.8, 5.2), 
    student_norms = 2015
  )
  
  expect_is(p, 'ggplot')
  p <- ggplot_build(p)
  expect_equal(p$data[[4]]$y %>% sum(), 49643.13, tolerance = 0.1)
  
})


test_that("cohort_longitudinal_npr_plot with name annotations", {
  
  p <- cohort_longitudinal_npr_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    first_and_spring_only = TRUE,
    entry_grade_seasons = c(-0.8, 4.2), 
    name_annotations = TRUE,
    student_norms = 2015
  )
  
  expect_is(p, 'ggplot')
  p <- ggplot_build(p)
  expect_equal(p$data[[4]]$y %>% sum(), 29412.38, tolerance = 0.1)
  
})