context("localization tests")

#make sure that constants used below exist
testing_constants()

test_that("localization function works as expected", {

  knj <- localize("Newark")
  def <- localize("Toronto")
  
  expect_is(knj, 'list')
  expect_is(def, 'list')
  
  expect_equal(def$act_cuts, c(11, 16, 18, 22, 25, 29))
  
})
