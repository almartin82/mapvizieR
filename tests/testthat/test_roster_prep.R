context("running roster prep on sample data provided by NWEA")

test_that("prep_roster correctly preps sample data", {
  samp_roster <- prep_roster(ex_CombinedStudentsBySchool)
  
  expect_equal(check_roster(samp_roster), TRUE)
  expect_type(samp_roster$grade, "integer")
  #regexp is - through 12
  expect_match(unique(samp_roster$grade) %>% as.character(), "^([0-9]|1[0-2])$") 
})