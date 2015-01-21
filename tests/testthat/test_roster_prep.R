context("running roster prep on sample data provided by NWEA")

test_that("prep_roster correctly preps sample data", {
  samp_roster <- prep_roster(ex_CombinedStudentsBySchool)
  
  expect_equal(check_roster(samp_roster)$boolean, TRUE)
  expect_is(samp_roster$grade, "integer")
  expect_match(unique(samp_roster$grade), "^([0-9]|1[0-2])$") # regexp is - through 12
})