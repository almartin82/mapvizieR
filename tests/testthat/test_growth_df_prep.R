context("growth data frame prep")

#constants
mapviz <- mapvizieR(raw_cdf=ex_CombinedAssessmentResults, raw_roster=ex_CombinedStudentsBySchool)
processed_cdf <- mapviz[['cdf']]
  
f2s_scaffold <- student_scaffold(
  processed_cdf = processed_cdf
 ,start_season = 'Fall'
 ,end_season = 'Spring'
 ,year_offset = 0
)

s2s_scaffold <- student_scaffold(
  processed_cdf = processed_cdf
 ,start_season = 'Spring'
 ,end_season = 'Spring'
 ,year_offset = 1
)


test_that("prep_cdf_long correctly preps sample data", {
  expect_equal(nrow(f2s_scaffold), 4179)
  expect_equal(nrow(s2s_scaffold), 6466)
  
  expect_equal(sum(as.numeric(f2s_scaffold$testid)), 510850865583)
  expect_equal(sum(as.numeric(s2s_scaffold$testid)), 790417103624)
  
  f2s_match_counts <- table(f2s_scaffold$match_status)
  s2s_match_counts <- table(s2s_scaffold$match_status)
  
  expect_equal(f2s_match_counts[['only end']], 1993)
  expect_equal(f2s_match_counts[['start and end']], 2186)

  expect_equal(s2s_match_counts[['only start']], 2287)
  expect_equal(s2s_match_counts[['only end']], 2287)
  expect_equal(s2s_match_counts[['start and end']], 1892)
  
})