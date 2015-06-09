context("estimate_rit tests")

# mapviz2 in global environment defined:
testing_constants()

test_that("estimate_rit does expected stuff ", {

  # test closest
  samp_val <- estimate_rit(mapviz, studentid = 'F08000002', 
                           measurementscale = 'Mathematics', target_date = '2013-10-20', 
                           method = 'closest')
  expect_equal(samp_val, 209, tolerance = .01)
  
  # test that forward parameter works
  samp_val <- estimate_rit(mapviz, studentid = 'F08000002', 
                           measurementscale = 'Mathematics', target_date = '2013-11-30', 
                           method = 'closest', forward = FALSE)
  expect_equal(samp_val, 209, tolerance = .01)
  
  # test lm
  samp_val <- estimate_rit(mapviz, studentid = 'F08000002', 
                           measurementscale = 'Mathematics', target_date = '2013-10-20',
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
  
  # test that error is returned
  expect_error(
    estimate_rit(mapviz, studentid = 'F08000002', measurementscale = 'Mathematics', 
                 target_date = '2013-10-20')
  )
  
  expect_error(
    estimate_rit(mapviz, studentid = 'F08000002', measurementscale = 'Mathematics',
                 target_date = '2013-10-20', method = 'logistic')
  )
  
  expect_error(
    estimate_rit(mapviz, studentid = 'abcdefg', measurementscale = 'Mathematics', 
                 target_date = '2013-10-20', method = 'closest')
  )
  
  # test num_days
  samp_val <- estimate_rit(mapviz, studentid = 'F08000002', 
                           measurementscale = 'Mathematics', 
                           target_date = '2014-9-20', method = 'closest')
  expect_true(is.na(samp_val))
  
  # change num_days to include this date
  samp_val <- estimate_rit(mapviz, studentid = 'F08000002',measurementscale = 'Mathematics',target_date = '2014-9-20',method = 'closest',num_days = 200)
  expect_equal(samp_val, 219, tolerance = .01)
  
  # measurement scale not given / spelled wrong
  expect_error(estimate_rit(mapviz, studentid = 'F08000002', target_date = '2013-10-20'))
  expect_error(
    estimate_rit(mapviz,studentid = 'F08000002', measurementscale = 'Mathatacsa', 
                 target_date = '2013-9-20')
    )
  
  # only one test event for measurement scale
  # filtered mapviz object to test for errors
  mapviz2 <- mapviz
  mapviz2[['cdf']] <-  dplyr::filter(mapviz2[['cdf']], studentid == 'F08000002', 
                                     measurementscale == 'Mathematics')[1,]

  samp_val <- estimate_rit(mapviz2, studentid = 'F08000002', 
                           measurementscale = 'Mathematics', target_date = '2013-9-20',
                           method = 'closest')
  expect_equal(samp_val, 209, tolerance = .01)
  
  samp_val <- estimate_rit(mapviz2, studentid = 'F08000002', 
                           measurementscale = 'Mathematics', target_date = '2015-9-20',
                           method = 'closest')
  expect_true(is.na(samp_val))
})