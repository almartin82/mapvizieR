context("strand boxes tests")

#make sure that constants used below exist
testing_constants()


test_that("strand boxes errors when handed an improper mapviz object", {
  expect_error(
    mapvizieR::strand_boxes(cdf, studentids, 'Mathematics', 'Spring', 2013), 
    "The object you passed is not a conforming mapvizieR object"
  )  
})


test_that("strand boxes produces proper plot with a grade level of kids", {
        
  p <- strand_boxes(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    fws = 'Spring',
    academic_year = 2013 
  )
      
  p_build <- ggplot_build(p)
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$data[[1]]), 372)
  expect_equal(sum(p_build$data[[1]][, 3]), 83183.3, tolerance = .001)  
  expect_equal(ncol(p_build$data[[2]]), 4)
  expect_equal(sum(p_build$data[[2]][, 2]), 916, tolerance = .001)
  
})


test_that("fuzz test strand boxes plot", {
  results <- fuzz_test_plot(
    'strand_boxes', n = 10,
    additional_args = list(
      'measurementscale' = 'Mathematics', 'fws' = 'Fall', 'academic_year' = 2013
    )
  )
  expect_true(all(unlist(results)))
})
