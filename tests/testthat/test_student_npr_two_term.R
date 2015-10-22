context("student_npr_two_term_plot tests")

#make sure that constants used below exist
testing_constants()

test_that("student_npr_two_year_plot errors when handed an improper mapviz object", {
  expect_error(
    student_npr_two_term_plot(cdf,
                              studentids = studentids_normal_use,
                              measurement_scale ="Reading", 
                              term_first = "Spring 2012-2013", 
                              term_second = "Fall 2013-2014", 
                              n_col = 7, 
                              min_n = 5),
    "The object you passed is not a conforming mapvizieR object"
  )
})


test_that("student_npr_two_term_plot produces proper plot with a grade level of kids", {
  p <- student_npr_two_term_plot(mapviz,
                                 studentids = studentids_normal_use,
                                 measurement_scale ="Reading", 
                                 term_first = "Spring 2012-2013", 
                                 term_second = "Fall 2013-2014", 
                                 n_col = 7, 
                                 min_n = 5)
                                
    
  p_build <- ggplot_build(p)
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$data[[1]]), 1369)
  expect_equal(ncol(p_build$data[[2]]), 7)
  expect_equal(sum(p_build$data[[2]][, 4]), 1638, tolerance = .001)
})


test_that("fuzz test student_npr_two_term_plot plot", {
  results <- fuzz_test_plot(
    'student_npr_two_term_plot', 
    n = 5,
    additional_args=list( 'measurement_scale' ="Reading", 
                          'term_first' = "Spring 2012-2013", 
                          'term_second' = "Fall 2013-2014", 
                          'n_col' = 7, 
                          'min_n' = 5)
  )
  expect_true(all(unlist(results)))
})