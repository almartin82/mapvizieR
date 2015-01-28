context("testing roster_check functions for accurate behavior and error messages")

test_that("ensure_roster_names correctly pass and fail on sample input data", {
  
  #vanilla studentsbyschool should error
  expect_error(
    ensure_roster_names(ex_CombinedStudentsBySchool),
    "check your roster - it must have a field named studentid."
  )
  expect_error(
    ensure_roster_names(ex_CombinedStudentsBySchool),
    "check your roster - it must have a field named grade"
  )
  
  #prepping the sample data should return TRUE 
  expect_true(
    is.data.frame(
      ensure_roster_names(prep_roster(ex_CombinedStudentsBySchool))
    )
  )
  
})


test_that("ensure_roster_types correctly pass and fail on sample input data", {
  
  #should fail on vanilla object
  expect_error(
    ensure_roster_types(ex_CombinedStudentsBySchool),
    "check type on grade field, should be integer"
  )
  expect_error(
    ensure_roster_types(ex_CombinedStudentsBySchool),
    "check type on map_year_academic field, should be integer"
  )
  expect_error(
    ensure_roster_types(ex_CombinedStudentsBySchool),
    "check type on fallwinterspring, should be character"
  )
  
  #mangled df with non-integer grade should fail
  prepped <- prep_roster(ex_CombinedStudentsBySchool)
  mangled <- prepped[sample(nrow(prepped), 100), ]
  mangled$grade <- 'Kinder'
  mangled <- rbind(prepped, mangled)
  expect_error(
    ensure_roster_types(mangled),
    "check type on grade field, should be integer"
  )
  
  #prepping the sample data should return TRUE 
  expect_true(
    is.data.frame(
      ensure_roster_types(prep_roster(ex_CombinedStudentsBySchool))
    )
  )
  
})