context('cohort_status_trace_plot tests')

p <- cohort_status_trace_plot(
  mapvizieR_obj = mapviz,
  studentids = studentids_one_school,
  measurementscale = 'Mathematics'
)

p_build <- ggplot2::ggplot_build(p)

test_that("basic tests on cohort status trace plot", {
  expect_is(p, 'ggplot')
  expect_equal(sum(p_build$data[[1]]$label), 879.9, tolerance = 0.1)
  expect_equal(sum(p_build$data[[1]]$y), 167L)
})


test_that("cohort status trace plot with alternate parameters", {
  p_alt <- cohort_status_trace_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_one_school,
    measurementscale = 'Mathematics',
    plot_labels = 'NPR'
  )
  
  p_alt_build <- ggplot2::ggplot_build(p_alt)
  expect_is(p_alt_build, 'list')
  expect_equal(sum(p_alt_build$data[[1]]$label), 167L)
})


test_that("cohort status trace plot, no school collapse", {
  p_alt <- cohort_status_trace_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_one_school,
    measurementscale = 'Mathematics',
    plot_labels = 'NPR',
    collapse_schools = FALSE
  )
  
  p_alt_build <- ggplot2::ggplot_build(p_alt)
  expect_is(p_alt_build, 'list')
  expect_equal(sum(p_alt_build$data[[1]]$label), 215L)
})


test_that("cohort status trace plot with alternate retention strategies", {
  p_alt <- cohort_status_trace_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_one_school,
    measurementscale = 'Mathematics',
    plot_labels = 'NPR',
    collapse_schools = TRUE,
    retention_strategy = 'filter_small'
  )
  
  p_alt_build <- ggplot2::ggplot_build(p_alt)
  expect_is(p_alt_build, 'list')
  expect_equal(sum(p_alt_build$data[[1]]$label), 292L)
})