context("goal strand plot tests")

#make sure that constants used below exist
testing_constants()

test_that("goal_strand_plot errors when handed an improper mapviz object", {
  expect_error(
    goal_strand_plot(cdf, 
                     studentids,  
                     measurement_scale = "Mathematics", 
                     fws = "Spring", 
                     year = 2013),
    "The object you passed is not a conforming mapvizieR object"
  )
})


test_that("goal_strand_plot produces proper plot with a grade level of kids", {

  p <- goal_strand_plot(
    mapviz,
    studentids_normal_use,
    measurement_scale = "Mathematics", 
    fws = "Spring", 
    year = 2013
    )

  p_build <- ggplot_build(p)

  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$plot$data), 372)

})