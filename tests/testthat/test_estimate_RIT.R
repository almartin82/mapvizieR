context("estimate_rit tests")

test_that("estimate_rit normal behavior", {

  # test closest
  samp_val <- estimate_rit(
    mapviz, studentid = 'F08000002', 
    measurementscale = 'Mathematics', 
    target_date = '2013-10-20', 
    method = 'closest'
  )
  expect_equal(samp_val, 209, tolerance = .01)
  
  # test that forward parameter works
  samp_val <- estimate_rit(mapviz, studentid = 'F08000002', 
                           measurementscale = 'Mathematics', 
                           target_date = '2013-11-30', 
                           method = 'closest', forward = FALSE)
  expect_equal(samp_val, 209, tolerance = .01)
  
  # test lm
  samp_val <- estimate_rit(mapviz, studentid = 'F08000002', 
                           measurementscale = 'Mathematics', 
                           target_date = '2013-10-20',
                           method = 'lm')
  expect_true(is.numeric(samp_val))
  
  samp_val <- estimate_rit(mapviz, studentid = 'F08000002', 
                           measurementscale = 'Mathematics',
                           target_date = '2014-9-20', method = 'lm')
  expect_true(is.numeric(samp_val))
  
  # test interpolate
  samp_val <- estimate_rit(mapviz, studentid = 'F08000002',
                           measurementscale = 'Mathematics',
                           target_date = '2013-10-20',
                           method = 'interpolate')
  expect_true(is.numeric(samp_val))
  
  samp_val <- estimate_rit(mapviz, studentid = 'F08000002',
                           measurementscale = 'Mathematics', 
                           target_date = '2013-9-12', method = 'interpolate')
  expect_true(is.numeric(samp_val))
  
  # target_date is a test date
  samp_val <- estimate_rit(mapviz, studentid = 'F08000002',
                           measurementscale = 'Mathematics',
                           target_date = '2014-03-16', method = 'closest')
  expect_equal(samp_val, 219, tolerance = .01)
  
  # check when student hasn't taken a test in given measurementscale
  samp_val <- estimate_rit(mapviz, studentid = 'F08000002',
                           measurementscale = 'General Science',
                           target_date = '2013-10-20', method = 'closest')
  expect_true(is.na(samp_val))
  
  samp_val <- estimate_rit(mapviz, studentid = 'F08000003', 
                           measurementscale = 'General Science',
                           target_date = '2013-10-20', method = 'closest')
  expect_true(is.na(samp_val))
  
  # target_date before first test event
  samp_val <- estimate_rit(mapviz, studentid = 'F08000002',
                           measurementscale = 'Mathematics',
                           target_date = '2013-1-10', method = 'interpolate')
  expect_true(is.na(samp_val))
  
  # target_date after last test event
  samp_val <- estimate_rit(mapviz,studentid = 'F08000002', 
                           measurementscale = 'Mathematics', 
                           target_date = '2014-5-16',
                           method = 'interpolate')
  expect_true(is.na(samp_val))
})
    

test_that("estimate_rit error conditions", {
  
  #no method
  expect_error(
    estimate_rit(mapviz, studentid = 'F08000002', measurementscale = 'Mathematics', 
                 target_date = '2013-10-20'), "method not given"
  )
  
  #bad method
  expect_error(
    estimate_rit(mapviz, studentid = 'F08000002', 
                 measurementscale = 'Mathematics',
                 target_date = '2013-10-20', method = 'logistic'), 
    "method not available"
  )
  
  #bad student
  expect_error(
    estimate_rit(mapviz, studentid = 'abcdefg', 
                 measurementscale = 'Mathematics', 
                 target_date = '2013-10-20', method = 'closest'), 
    "studentid not in mapvizieR cdf object"
  )
  
  #no measurementscale
  expect_error(
    estimate_rit(mapviz, studentid = 'F08000002', 
                 target_date = '2013-10-20', method = 'closest'), 
    "measurementscale not given"
  )

  #bad measurementscale
  expect_error(
    estimate_rit(mapviz, studentid = 'F08000002', measurementscale = 'Science', 
    target_date = '2013-10-20', method = 'closest'), "invalid measurementscale"
  )

})


test_that("advanced estimate_rit options", {

  # test num_days
  samp_val <- estimate_rit(mapviz, studentid = 'F08000002', 
                           measurementscale = 'Mathematics', 
                           target_date = '2014-9-20', method = 'closest')
  expect_true(is.na(samp_val))
  
  # change num_days to include this date
  samp_val <- estimate_rit(mapviz, studentid = 'F08000002',
                           measurementscale = 'Mathematics',
                           target_date = '2014-9-20',
                           method = 'closest', num_days = 200)
  expect_equal(samp_val, 219, tolerance = .01)
  
  
  # only one test event for measurement scale
  # filtered mapviz object to test for errors
  mapviz2 <- mapviz
  mapviz2[['cdf']] <-  dplyr::filter(mapviz2[['cdf']], studentid == 'F08000002', 
                                     measurementscale == 'Mathematics')[1,]

  # Use num_days parameter to cover the gap between test date and target date
  samp_val <- estimate_rit(mapviz2, studentid = 'F08000002',
                           measurementscale = 'Mathematics',
                           target_date = '2013-9-20',
                           method = 'closest',
                           num_days = 200)
  expect_equal(samp_val, 210, tolerance = .01)
  
  samp_val <- estimate_rit(mapviz2, studentid = 'F08000002', 
                           measurementscale = 'Mathematics', 
                           target_date = '2015-9-20',
                           method = 'closest')
  expect_true(is.na(samp_val))
})