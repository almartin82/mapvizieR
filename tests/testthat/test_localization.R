context("localization tests")

#make sure that constants used below exist
testing_constants()

test_that("localization function works as expected", {

  knj <- localize("Newark", verbose = TRUE)
  def <- localize("Toronto", verbose = TRUE)
  
  expect_is(knj, 'list')
  expect_is(def, 'list')
  
  expect_equal(def$act_cuts, c(11, 16, 18, 22, 25, 29))
  
  expect_output(localize("Newark", verbose = TRUE), "Localized 5 variables")
  expect_output(
    localize("Toronto", verbose = TRUE), 
    "Your localization choice did not match"
  )
})
