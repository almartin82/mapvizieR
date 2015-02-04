context("cgp_prep tests")

test_that("determine_cgp_method tests", {

  #cgp_nearest_lookup
  expect_equal(
    determine_cgp_method(
      'Mathematics', 5, 'Fall to Spring'
      ,206, 10, sch_growth_norms_2012
    ),
    "cgp_nearest_lookup"
  )

  #cgp_nearest_lookup for science
  expect_equal(
    determine_cgp_method(
      'General Science', 5, 'Fall to Spring'
      ,206, 10, sch_growth_norms_2012
    ),
    "cgp_generalization"
  )
  
  #cgp_generalization when outside of rit difference tolerance  
  expect_equal(
    determine_cgp_method(
      'Mathematics', 5, 'Fall to Spring'
      ,178, 10, sch_growth_norms_2012
    ),
    "cgp_generalization"
  )

})



