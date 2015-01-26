context("norms prep")


test_that("norms_students_wide_to_long correctly processess 2011 norms data", {
  
  norms_long <- norms_students_wide_to_long(norms_students_2011)
  
  expect_equal(nrow(norms_long), 39645)
  expect_equal(round(sum(norms_long$typical_growth), 1), round(187402.6,1))

  
})


