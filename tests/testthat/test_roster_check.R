context("testing roster_check functions for accurate behavior and error messages")

test_that("check_roster_names correctly checks for required fields", {
  
  #vanilla studentsbyschool should error
  expect_error(
    check_roster_names(ex_CombinedStudentsBySchool),
    "failed the NAMES test."
  )
  
  #prepping the sample data should return TRUE 
  expect_true(
    check_roster_names(prep_roster(ex_CombinedStudentsBySchool))
  )
  
})




test_that("check_roster_grades requires a grade field", {
  
  #vanilla studentsbyschool should error
  expect_error(
    check_roster_grades(ex_CombinedStudentsBySchool),
    "failed the GRADE field test."
  )
  
  #prepping the sample data should return TRUE 
  expect_true(
    check_roster_grades(prep_roster(ex_CombinedStudentsBySchool))
  )
  
})



test_that("check_roster_grades fails when given a non-integer grade level", {
  
  prepped <- prep_roster(ex_CombinedStudentsBySchool)
  mangled <- prepped[sample(nrow(prepped), 100), ]
  mangled$grade <- 'Kinder'
  mangled <- rbind(prepped, mangled)
  
  #prepping the sample data should return TRUE 
  expect_error(
    check_roster_grades(mangled),
    "Roster objects can only have integers for the GRADE field."
  )
  
})