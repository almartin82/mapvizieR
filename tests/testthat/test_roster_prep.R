context("running roster prep on sample data provided by NWEA")

test_that("prep_roster correctly preps sample data", {
  samp_roster <- prep_roster(ex_CombinedStudentsBySchool)
  expect_equal(check_roster(samp_roster)$boolean, TRUE)
})