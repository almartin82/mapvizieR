context("haid_plot tests")

#make sure that constants used below exist
testing_constants()

test_that("haid_plot errors when handed an improper mapviz object", {
  expect_error(
    haid_plot(processed_cdf, studentids), 
    "The object you passed is not a conforming mapvizieR object"
  )  
})


test_that("haid_plot produces proper plot with a grade level of kids", {
  samp_haid <- haid_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013
  )
  
  expect_is(samp_haid, 'gg')
  expect_is(samp_haid, 'ggplot')
  
  expect_equal(length(samp_haid), 9)
  expect_equal(names(samp_haid), 
    c("data", "layers", "scales", "mapping", "theme", "coordinates", 
      "facet", "plot_env", "labels")             
  )
  
  p_build <- ggplot_build(samp_haid)
  
  expect_equal(length(p_build), 3)
  expect_equal(
    dimnames(p_build[[1]][[2]])[[2]],
    c("y", "x", "PANEL", "group")
  )
  expect_equal(sum(p_build[[1]][[5]]$xend), 19884, tolerance=0.01)
  
})


test_that("haid_plot with one season of data", {
  one_season <- haid_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    start_fws = 'Spring',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2014
  )
  
  expect_is(one_season, 'gg')
  expect_is(one_season, 'ggplot')
  
  expect_equal(length(one_season), 9)
  expect_equal(names(one_season), 
    c("data", "layers", "scales", "mapping", "theme", "coordinates", 
      "facet", "plot_env", "labels")             
  )
  
  p_build <- ggplot_build(one_season)
  
  expect_equal(length(p_build), 3)
  expect_equal(
    dimnames(p_build[[1]][[2]])[[2]],
    c("y", "x", "PANEL", "group")
  )
  expect_equal(sum(p_build[[1]][[5]]$x), 20744.75, tolerance=0.01)
  
})



test_that("fuzz test haid_plot", {
  results <- fuzz_test_plot(
    'haid_plot', 
    n=10,
    additional_args=list(
      'measurementscale' = 'Reading',
      'start_fws' = 'Fall',
      'start_academic_year' = 2013,
      'end_fws' = 'Spring',
      'end_academic_year' = 2013
    )
  )
  expect_true(all(unlist(results))) 
})

