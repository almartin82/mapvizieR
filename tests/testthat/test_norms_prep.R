context("norms prep")

test_that("norms_students_wide_to_long correctly processess 2011 norms data", {
  
  norms_long <- norms_students_wide_to_long(student_growth_norms_2011)
  
  expect_equal(nrow(norms_long), 39645)
  expect_equal(round(sum(norms_long$typical_growth), 1), round(187402.6,1))
})

test_that("norms_students_wide_to_long correctly processes 2015 norms data", {

  norms_long <- norms_students_wide_to_long(student_growth_norms_2015)

  # 2015 norms data structure - updated expectations for current format
  expect_equal(nrow(norms_long), 55722)
  expect_equal(round(sum(norms_long$typical_growth, na.rm=TRUE), 1),
               round(206461.6, 1))
})


