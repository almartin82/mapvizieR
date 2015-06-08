context("nearest_rit tests")

#make sure that constants used below exist
testing_constants()

test_that("nearest_rit does expected stuff ", {

  # test that it works to find closest
  samp_val <- nearest_rit(mapviz, studentid='F08000002', measurementscale='Mathematics', 
    target_date='2013-10-20')
  expect_equal(samp_val, 209)
  
  samp_val <- nearest_rit(mapviz, studentid='F08000002', measurementscale='Reading', 
    target_date='2013-10-20')
  expect_equal(samp_val, 217)
  
  samp_val <- nearest_rit(mapviz, studentid='F08000002', measurementscale='Language Usage', 
    target_date='2013-10-20')
  expect_equal(samp_val, 215)
  
  samp_val <- nearest_rit(mapviz, studentid='F08000006', measurementscale='General Science', 
    target_date='2013-10-20')
  expect_equal(samp_val, 194)
  
  # test that forward parameter does its job
  samp_val <- nearest_rit(mapviz, studentid='F08000002', measurementscale='Mathematics',
    target_date='2013-11-30', forward=FALSE)
  expect_equal(samp_val, 209)
  
  samp_val <- nearest_rit(mapviz, studentid='F08000002', measurementscale='Reading', 
    target_date='2013-11-30', forward=FALSE)
  expect_equal(samp_val, 217)
  
  samp_val <- nearest_rit(mapviz, studentid='F08000002', measurementscale='Language Usage', 
    target_date='2013-11-30', forward=FALSE)
  expect_equal(samp_val, 215)
  
  samp_val <- nearest_rit(mapviz, studentid='F08000006', measurementscale='General Science', 
    target_date='2013-11-30', forward=FALSE)
  expect_equal(samp_val, 194)
  
  # test num_days
  samp_val <- nearest_rit(mapviz, studentid='F08000002', measurementscale='Mathematics',target_date='2014-9-20')
  expect_true(is.na(samp_val))
  
  samp_val <- nearest_rit(mapviz, studentid='F08000002', measurementscale='Mathematics',target_date='2014-9-20',num_days=200)
  expect_equal(samp_val,219)
  
  # test errors
  expect_error(nearest_rit(mapviz, studentid='F08000002', target_date='2013-10-20'))
  expect_error(nearest_rit(mapviz, studentid='F08000002', measurementscale='Mathatacsa',target_date='2013-9-20'))
  expect_error(nearest_rit(mapviz, studentid='abcdefg', measurementscale='Mathematics',target_date='2013-10-20'))
})
