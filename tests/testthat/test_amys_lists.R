context("amy's lists tests")

#make sure that constants used below exist
testing_constants()

test_that("amys_lists errors when handed an improper mapviz object", {
  expect_error(
    amys_lists(cdf, studentids),
    "The object you passed is not a conforming mapvizieR object"
  )
})


test_that("amys_lists produces proper plot with a grade level of kids", {

  p <- amys_lists(
    mapviz,
    studentids_normal_use,
    start_fws = "Fall",
    start_academic_year = 2013,
    end_fws = "Spring",
    end_academic_year = 2013,
    measurementscale =  c("Reading", "Mathematics")
  )

  p_build <- ggplot_build(p)

  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$plot$data), 89)

})
