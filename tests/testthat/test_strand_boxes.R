context("strand boxes tests")

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
  expect_equal(nrow(p_build$data[[1]]), 4)
  expect_equal(sum(p_build$data[[1]][, 3]), 894, tolerance = .001)  
  expect_equal(ncol(p_build$data[[2]]), 16)
  expect_equal(sum(p_build$data[[2]][, 2]), 0, tolerance = .001)
  
})


test_that("fuzz test strand boxes plot", {
  
  results <- fuzz_test_plot(
    plot_name = 'strand_boxes', 
    n = 10,
    additional_args = list(
      'measurementscale' = 'Mathematics', 'fws' = 'Fall', 
      'academic_year' = 2013
    ),
    mapvizieR_obj = mapviz
  )
  expect_true(all(unlist(results)))
  
})
