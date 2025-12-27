context("student_npr_two_term_plot tests")

test_that("student_npr_two_year_plot errors when handed an improper mapviz object", {
  expect_error(
    student_npr_two_term_plot(
      mapvizieR_obj = cdf,
      studentids = studentids_normal_use,
      measurementscale = "Reading", 
      term_first = "Spring 2012-2013", 
      term_second = "Fall 2013-2014", 
      n_col = 7, 
      min_n = 5),
    "The object you passed is not a conforming mapvizieR object"
  )
})


test_that("student_npr_two_term_plot produces proper plot with a grade level of kids", {
  p <- student_npr_two_term_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = "Reading", 
    term_first = "Spring 2012-2013", 
    term_second = "Fall 2013-2014", 
    n_col = 7, 
    min_n = 5
  )
                                
  p_build <- ggplot_build(p)
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$data[[1]]), 1369)
  # S7 ggplot2 may have more columns
  expect_true(ncol(p_build$data[[2]]) >= 10)
  # Use named column access instead of numeric index
  expect_equal(sum(p_build$data[[2]]$y), 1638, tolerance = .001)
})


test_that("fuzz test student_npr_two_term_plot plot", {
  results <- fuzz_test_plot(
    'student_npr_two_term_plot', 
    n = 2,
    additional_args = list(
      'measurementscale' = "Reading", 
      'term_first' = "Spring 2012-2013", 
      'term_second' = "Fall 2013-2014", 
      'n_col' = 7, 
      'min_n' = 5
    ),
    mapvizieR_obj = mapviz
  )
  expect_true(all(unlist(results)))
})
