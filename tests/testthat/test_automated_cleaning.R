testing_constants()

test_that("sbs_missing shows correct output on sample data", {
  expect_message(ex_CombinedStudentsBySchool %>% sbs_missing(), 
    'Good news: All columns in your students_by_school file have no blank values!')
})


test_that("sbs_missing reports missing totals on intentionally mangled data", {
  
  busted_sbs <- ex_CombinedStudentsBySchool
  busted_sbs$StudentFirstName <- c(rep('', 20), busted_sbs$StudentFirstName[21:2670])

  expect_message(
    busted_sbs %>% sbs_missing(),
    'NOTE: there are 20 rows with missing values in the StudentFirstName column of the students_by_school file'
  )  
})
