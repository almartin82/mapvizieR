context("nearest_rit tests")

#make sure that constants used below exist
# testing_constants()


test_that("nearest_rit does expected stuff ", {

  # test that it works to find closest
  samp_val <- nearest_rit(mapviz,'F08000002','Mathematics','2013-10-20')
  expect_equal(samp_val, 209)
  
  samp_val <- nearest_rit(mapviz,'F08000002','Reading','2013-10-20')
  expect_equal(samp_val, 217)
  
  samp_val <- nearest_rit(mapviz,'F08000002','Language Usage','2013-10-20')
  expect_equal(samp_val, 215)
  
  samp_val <- nearest_rit(mapviz,'F08000006','General Science','2013-10-20')
  expect_equal(samp_val, 194)
  
  # test that forward parameter does its job
  samp_val <- nearest_rit(mapviz,'F08000002','Mathematics','2013-11-30',forward=FALSE)
  expect_equal(samp_val, 209)
  
  samp_val <- nearest_rit(mapviz,'F08000002','Reading','2013-11-30',forward=FALSE)
  expect_equal(samp_val, 217)
  
  samp_val <- nearest_rit(mapviz,'F08000002','Language Usage','2013-11-30',forward=FALSE)
  expect_equal(samp_val, 215)
  
  samp_val <- nearest_rit(mapviz,'F08000006','General Science','2013-11-30',forward=FALSE)
  expect_equal(samp_val, 194)
  
  # test num_days
  samp_val <- estimate_rit(mapviz,'F08000002','Mathematics','2014-9-20','closest')
  expect_true(is.na(samp_val))
  
  samp_val <- estimate_rit(mapviz,'F08000002','Mathematics','2014-9-20','closest',num_days=200)
  expect_equal(samp_val,219)
})
