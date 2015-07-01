context("auto growth window")

#make sure that constants used below exist
testing_constants()


test_that("auto_growth_window picks correct window", {
  ex_window <- auto_growth_window(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    end_fws = 'Spring', 
    end_academic_year = 2013
  )
  expect_equal(ex_window[[1]], 'Fall')
  expect_equal(ex_window[[2]], 2013)
})


test_that("auto_growth_window picks correct window", {
  
  spring_stu <- c("F08000002", "F08000003", "F08000004", "F08000005", "F08000010", 
    "F08000021", "F08000023", "F08000030", "F08000036", "F08000037", 
    "F08000052", "F08000069", "F08000086", "F08000130", "F08000160", 
    "F08000216", "F08000265", "F08000286", "F08000289", "F08000292", 
    "F08000293", "F08000294", "F08000303", "F08000304", "F08000306", 
    "F08000308", "F08000311", "F08000313", "SF06000123", "SF06000361", 
    "SF06000405", "SF06000426", "SF06001226", "SF06001380", "SF07002061", 
    "SS07001540", "SS07001546")

  ex_window <- auto_growth_window(
    mapvizieR_obj = mapviz,
    studentids = spring_stu,
    measurementscale = 'Mathematics',
    end_fws = 'Spring', 
    end_academic_year = 2013
  )
  expect_equal(ex_window[[1]], 'Spring')
  expect_equal(ex_window[[2]], 2012)
})