context("sgp histogram tests")

test_that("growth_histogram errors when handed an improper mapviz object", {
  expect_error(
    growth_histogram(processed_cdf, studentids), 
    "The object you passed is not a conforming mapvizieR object"
  )  
})


test_that("growth_histogram produces proper plot with a grade level of kids", {
  samp_sgp <- growth_histogram(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013
  )
  
  expect_is(samp_sgp, 'gg')
  expect_is(samp_sgp, 'ggplot')
  
  expect_equal(length(samp_sgp), 9)
  expect_equal(names(samp_sgp), 
    c("data", "layers", "scales", "mapping", "theme", "coordinates", 
      "facet", "plot_env", "labels")             
  )
  
  p_build <- ggplot_build(samp_sgp)
  
  expect_equal(length(p_build), 3)
  expect_equal(
    dimnames(p_build[[1]][[2]])[[2]],
    c("y", "count", "x", "xmin", "xmax", "density", "ncount", "ndensity", 
      "PANEL", "group", "ymin", "ymax", "colour", "fill", "size", "linetype", 
      "alpha")
  )
  expect_equal(sum(p_build[[1]][[2]]$density), 0.1, tolerance = 0.01)
  
})


test_that("growth_histogram produces proper plot with a grade level of kids", {
    
  studentids_orange <- cdf[with(cdf, 
    map_year_academic == 2013 & measurementscale == 'Mathematics' & 
    fallwinterspring == 'Fall' & grade == 2), ]$studentid
  
  sgp_orange <- growth_histogram(
    mapvizieR_obj = mapviz,
    studentids = studentids_orange,
    measurementscale = 'Reading',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013
  )
  
  expect_is(sgp_orange, 'gg')
  expect_is(sgp_orange, 'ggplot')
  
  expect_equal(length(sgp_orange), 9)
  expect_equal(names(sgp_orange), 
    c("data", "layers", "scales", "mapping", "theme", "coordinates", 
      "facet", "plot_env", "labels")             
  )
  
  p_build <- ggplot_build(sgp_orange)
  
  expect_equal(length(p_build), 3)
  expect_equal(sum(p_build[[1]][[2]]$density), 0.1, tolerance = 0.01)

  
  #test sgp red
  studentids_red <- cdf[with(cdf, 
    map_year_academic == 2013 & measurementscale == 'Mathematics' & 
    fallwinterspring == 'Fall' & grade == 6 & testpercentile < 30), ]$studentid
  
  sgp_red <- growth_histogram(
    mapvizieR_obj = mapviz,
    studentids = studentids_red,
    measurementscale = 'Mathematics',
    start_fws = 'Spring',
    start_academic_year = 2012,
    end_fws = 'Spring',
    end_academic_year = 2013
  )
  
  expect_is(sgp_red, 'gg')
  expect_is(sgp_red, 'ggplot')
  
})


test_that("fuzz test growth_histogram", {
  
  results <- fuzz_test_plot(
    'growth_histogram', 
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

