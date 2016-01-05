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
  
  expect_is(samp_scatter, 'gg')
  expect_is(samp_scatter, 'ggplot')
  
  expect_equal(length(samp_scatter), 9)
  expect_equal(names(samp_scatter), 
    c("data", "layers", "scales", "mapping", "theme", "coordinates", 
      "facet", "plot_env", "labels")             
  )
  
  p_build <- ggplot_build(samp_scatter)
  
  expect_equal(length(p_build), 3)
  expect_equal(
    dimnames(p_build[[1]][[2]])[[2]], 
    c("x", "y", "PANEL", "group", "colour", "size", "angle", "hjust", 
      "vjust", "alpha", "family", "fontface", "lineheight", "label"
    )
  )
  expect_equal(sum(p_build[[1]][[2]]$x), 298, tolerance = 0.01)
  
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
    )
  )
  expect_true(all(unlist(results))) 
})

