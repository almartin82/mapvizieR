context("strand list plot tests")

test_that("strands_list_plot errors when handed an improper mapviz object", {
  expect_error(
    strands_list_plot(cdf, studentids_normal_use, "Reading", season = "Fall", 2013),
    "You need to use a proper mapvizieR object."
  )
})


test_that("student_npr_two_term_plot produces proper plot with a grade level of kids", {
  p <- strands_list_plot(
    mapvizier_obj = mapviz,   
    studentids = studentids_normal_use, 
    measurement_scale = "Reading", 
    season = "Spring", 
    year = 2013
  )
  
  p_build <- ggplot_build(p)
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$data[[1]]), 279)
  # S7 ggplot2 may have more columns
  expect_true(ncol(p_build$data[[2]]) >= 14)
  # Use named column access instead of numeric index
  expect_equal(sum(p_build$data[[2]]$x), 59584, tolerance = .001)
})
