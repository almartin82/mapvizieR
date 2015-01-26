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
  
  expect_equal(sum(as.numeric(f2s_scaffold$start_testid), na.rm=TRUE), 267221268358)
  expect_equal(sum(as.numeric(f2s_scaffold$end_testid), na.rm=TRUE), 510850832216)
  
  f2s_match_counts <- table(f2s_scaffold$match_status)
  s2s_match_counts <- table(s2s_scaffold$match_status)
  
  expect_equal(f2s_match_counts[['only end']], 1993)
  expect_equal(f2s_match_counts[['start and end']], 2186)

  expect_equal(s2s_match_counts[['only start']], 2287)
  expect_equal(s2s_match_counts[['only end']], 2287)
  expect_equal(s2s_match_counts[['start and end']], 1892)
  
})



test_that("scores_by_testid correctly looks up test events", {
  
  ex_lookup <- scores_by_testid(processed_cdf$testid, processed_cdf, 'start')
  expect_equal(nrow(ex_lookup), 8551)
  expect_equal(
    c('start_growthmeasureyn','start_testtype','start_testname',
      'start_teststartdate','start_testdurationminutes','start_testritscore',
      'start_teststandarderror','start_testpercentile','start_rittoreadingscore',
      'start_rittoreadingmin','start_rittoreadingmax','start_teststarttime',
      'start_percentcorrect','start_projectedproficiency'),
    names(ex_lookup)
  )
  expect_equal(sum(ex_lookup$start_percentcorrect), 435341)
  expect_equal(sum(ex_lookup$start_testritscore), 1871739)
})



test_that("generate_growth_df builds scaffold and finds growth scores", {
  
  growth_df <- generate_growth_dfs(processed_cdf)$headline
  expect_equal(nrow(growth_df), 17010)
  expect_equal(sum(as.numeric(growth_df$start_testritscore), na.rm=TRUE), 2344192)
  expect_equal(sum(as.numeric(growth_df$end_testritscore), na.rm=TRUE), 3239190)
  
})

