context("goalbar tests")

#make sure that constants used below exist
testing_constants()


test_that("goalbar errors when handed an improper mapviz object", {
  expect_error(
    goalbar(cdf, studentids), 
    "The object you passed is not a conforming mapvizieR object"
  )  
})


test_that("goalbar produces proper plot with a grade level of kids", {
        
  p <- goalbar(mapviz, studentids_normal_use, 'Mathematics', 'Fall', 2013,
         'Spring', 2013)
  p_build <- ggplot_build(p)
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$data[[1]]), 4)
  expect_equal(sum(p_build$data[[1]][, 6]), 176, tolerance=.001)  
  expect_equal(ncol(p_build$data[[2]]), 6)
  expect_equal(sum(p_build$data[[2]][, 3]), 222.5, tolerance=.001)
})


test_that("goalbar works with ontrack params",{
  
  p <- goalbar(mapviz, studentids_normal_use, 'Mathematics', 'Fall', 2013,
         'Spring', 2013, ontrack_prorater = 0.5, ontrack_fws = 'Winter',
        ontrack_academic_year = 2014)
  expect_true(is.ggplot(p))
  
  p_build <- ggplot_build(p)
  expect_equal(sum(p_build$data[[2]][, 3]), 222.5, tolerance=.001)
  
})

test_that("fuzz test goalbar plot", {
  results <- fuzz_test_plot(
    'goalbar', 
    n=10,
    additional_args=list('measurementscale' = 'Mathematics', 'start_fws' = 'Fall',
      'start_academic_year' = 2013, 'end_fws' = 'Spring', 'end_academic_year' = 2013)
  )
  expect_true(all(unlist(results)))
})
