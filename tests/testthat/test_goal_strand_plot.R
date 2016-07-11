context("goal strand plot tests")

test_that("goal_strand_plot errors when handed an improper mapviz object", {
  expect_error(
    goal_strand_plot(cdf, studentids,  measurementscale = "Mathematics", 
      fws = "Spring", year = 2013),
    "The object you passed is not a conforming mapvizieR object"
  )
})


test_that("goal_strand_plot produces proper plot with a grade level of kids", {

  p <- goal_strand_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = "Mathematics", 
    fws = "Spring", 
    year = 2013
  )

  p_build <- ggplot_build(p)

  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$plot$data), 372)

})

test_that("Goals strand summary and range works for a given year", {
  
  p <- goal_strand_summary_plot(
    mapviz,
    studentids_normal_use,
    measurementscale = "Mathematics", 
    fws = "Spring", 
    year = 2013
  )
  
  p_build <- ggplot_build(p)
  
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$plot$data), 4)
  
})


test_that("Goals strand summary and range works for a given cohort", {
  
  p <- goal_strand_summary_plot(
    mapviz,
    studentids_normal_use,
    measurementscale = "Mathematics", 
    fws = c("Fall", "Spring"), 
    cohort = 2020,
    spring_is_first = TRUE
  )
  
  p_build <- ggplot_build(p)
  
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$plot$data), 12)
  
})

test_that("Goals strand summary and range works for a given year", {
  
  p <- goal_strand_summary_plot(
    mapviz,
    studentids_normal_use,
    measurementscale = "Mathematics", 
    fws = "Spring", 
    year = 2013
  )
  
  p_build <- ggplot_build(p)
  
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$plot$data), 4)
  
})


test_that("Goals strand summary and range works with filter_args", {
  
  p <- goal_strand_summary_plot(
    mapviz,
    studentids_normal_use,
    measurementscale = "Mathematics", 
    fws = c("Fall", "Spring"), 
    cohort = 2020,
    spring_is_first = TRUE,
    filter_args = list("grade == 6", "grepl('Bach', schoolname)")
  )
  
  p_build <- ggplot_build(p)
  
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$plot$data), 8)
  
})

