context("student_npr_history_plot tests")

studentids <- mapviz$roster %>%
  dplyr::filter(grade == 8,
         schoolname == "Mt. Bachelor Middle School",
         termname == "Spring 2013-2014") %>%
  dplyr::select(studentid) %>%
  unique()


test_that("student_npr_history_plot errors when handed an improper mapviz object", {
  expect_error(
    student_npr_history_plot(cdf, studentids$studentid, "Reading"),
    "The object you passed is not a conforming mapvizieR object"
  )
})


test_that("student_npr_history_plot produces proper plot with a grade level of kids", {
  p <- student_npr_history_plot(mapviz, studentids$studentid[1:40], 'Mathematics')
  p_build <- ggplot_build(p)
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$data[[1]]), 160)
  expect_equal(ncol(p_build$data[[2]]), 4)
  expect_equal(sum(p_build$data[[3]][, 2]), 320, tolerance = .001)
})


test_that("fuzz test student_npr_history_plot plot", {
  results <- fuzz_test_plot(
    'student_npr_history_plot', 
    n = 5,
    additional_args=list('measurementscale' = 'Mathematics')
  )
  expect_true(all(unlist(results)))
})
