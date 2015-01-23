context("creating the mapvizier object using the sample NWEA data")

test_that("grade_level_ify correctly processes CDF", {
  ex_roster <- prep_roster(ex_CombinedStudentsBySchool)
  ex_cdf <- prep_cdf_long(ex_CombinedAssessmentResults)
  
  ex_cdf$grades <- grade_levelify_cdf(ex_cdf, ex_roster)
  grade_freq <- table(ex_cdf$grades)
  
  expect_equal(length(ex_cdf$grades), 9091)
  expect_equal(grade_freq[['1']], 131)
  expect_equal(grade_freq[['2']], 249)
  expect_equal(grade_freq[['3']], 165)
  expect_equal(grade_freq[['4']], 736)
  expect_equal(grade_freq[['5']], 625)  
  expect_equal(grade_freq[['6']], 1185)
  expect_equal(grade_freq[['7']], 1440)
  expect_equal(grade_freq[['8']], 1640)
  expect_equal(grade_freq[['9']], 1659)
  expect_equal(grade_freq[['10']], 640)
  expect_equal(grade_freq[['11']], 441)
})


test_that("cdf_roster_match properly joins assessment results and rosters", {
  ex_roster <- prep_roster(ex_CombinedStudentsBySchool)
  ex_roster_small <- ex_roster[-c(20:100),]
  ex_cdf <- prep_cdf_long(ex_CombinedAssessmentResults)
  ex_matched <- cdf_roster_match(ex_cdf, ex_roster)
  
  expect_equal(nrow(ex_matched), nrow(ex_cdf))
  expect_equal(ncol(ex_matched), ncol(ex_roster) + ncol(ex_cdf) -5) #-5 = -3 match columns and -2 duplicate columns
  
  expect_warning(cdf_roster_match(ex_cdf, ex_roster_small), "8848")
  
})



test_that("mapvizieR S3 class methods work", {
  mv <- mapvizieR(
    raw_cdf = ex_CombinedAssessmentResults,
    raw_roster = ex_CombinedStudentsBySchool
  )
  
  expect_equal(length(mv), 2)
  expect_equal(names(mv), c("cdf", "roster"))
  expect_output(mv, "714 students")
  expect_output(print.mapvizieR(mv), "SY2012 to SY2013")
  expect_true(is.mapvizieR(mv))
  expect_false(is.mapvizieR(ex_CombinedAssessmentResults))
})