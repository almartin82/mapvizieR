context("growth_status_scatter tests")

test_that("growth_status_scatter produces proper plot with a grade level of kids", {
  samp_scatter <- growth_status_scatter(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013
  )
  
  expect_s3_class(samp_scatter, 'gg')
  expect_s3_class(samp_scatter, 'ggplot')

  # ggplot2 now uses S7 objects - check plot has expected components
  expect_true(!is.null(samp_scatter$data))
  expect_true(!is.null(samp_scatter$layers))
  expect_true(!is.null(samp_scatter$mapping))

  p_build <- ggplot_build(samp_scatter)

  # Check ggplot_build result has data
  expect_true(!is.null(p_build$data))
  expect_true(length(p_build$data) >= 2)
  expect_equal(sum(p_build$data[[2]]$x), 298, tolerance = 0.01)
  
})



test_that("fuzz test growth_status_scatter", {
  results <- fuzz_test_plot(
    'growth_status_scatter', 
    n = 10,
    additional_args = list(
      'measurementscale' = 'Reading',
      'start_fws' = 'Fall',
      'start_academic_year' = 2013,
      'end_fws' = 'Spring',
      'end_academic_year' = 2013
    ),
    mapvizieR_obj = mapviz
  )
  expect_true(all(unlist(results))) 
})

