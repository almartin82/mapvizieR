context('cohort_status_trace_plot tests')

p <- cohort_status_trace_plot(
  mapvizieR_obj = mapviz,
  studentids = studentids_one_school,
  measurementscale = 'Mathematics'
)

test_that("basic tests on cohort status trace plot", {
  expect_is(p, 'ggplot')
})