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
  
  expect_s3_class(samp_sgp, 'gg')
  expect_s3_class(samp_sgp, 'ggplot')

  # ggplot2 now uses S7 objects - check plot has expected components
  expect_true(!is.null(samp_sgp$data))
  expect_true(!is.null(samp_sgp$layers))

  p_build <- ggplot_build(samp_sgp)

  # Check ggplot_build result has data
  expect_true(!is.null(p_build$data))
  expect_true(length(p_build$data) >= 2)
  expect_equal(sum(p_build$data[[2]]$density), 0.1, tolerance = 0.01)
  
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
  
  expect_s3_class(sgp_orange, 'gg')
  expect_s3_class(sgp_orange, 'ggplot')

  # ggplot2 now uses S7 objects - check plot has expected components
  expect_true(!is.null(sgp_orange$data))
  expect_true(!is.null(sgp_orange$layers))

  p_build <- ggplot_build(sgp_orange)

  # Check ggplot_build result has data
  expect_true(!is.null(p_build$data))
  expect_equal(sum(p_build$data[[2]]$density), 0.1, tolerance = 0.01)

  
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
  
  expect_s3_class(sgp_red, 'gg')
  expect_s3_class(sgp_red, 'ggplot')
  
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

