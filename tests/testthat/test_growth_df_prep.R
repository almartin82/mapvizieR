context("growth data frame prep")

#additional constants
norms_long <- norms_students_wide_to_long(student_growth_norms_2015)
  
f2s_scaffold <- student_scaffold(
  processed_cdf = processed_cdf,
  start_season = 'Fall',
  end_season = 'Spring',
  year_offset = 0
)

s2s_scaffold <- student_scaffold(
  processed_cdf = processed_cdf,
  start_season = 'Spring',
  end_season = 'Spring',
  year_offset = 1
)


test_that("prep_cdf_long correctly preps sample data", {
  expect_equal(nrow(f2s_scaffold), 4179)
  expect_equal(nrow(s2s_scaffold), 6466)
  
  expect_equal(sum(as.numeric(f2s_scaffold$start_testid), na.rm = TRUE), 267221268358)
  expect_equal(sum(as.numeric(f2s_scaffold$end_testid), na.rm = TRUE), 510850832216)
  
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
    c("start_growthmeasureyn", "start_testtype", "start_testname", 
      "start_teststartdate", "start_testdurationminutes", "start_testritscore", 
      "start_teststandarderror", "start_testpercentile", "start_consistent_percentile", 
      "start_testquartile", "start_rittoreadingscore", "start_rittoreadingmin", 
      "start_rittoreadingmax", "start_teststarttime", "start_percentcorrect", 
      "start_projectedproficiencylevel1"),
    names(ex_lookup)
  )
  expect_equal(sum(ex_lookup$start_percentcorrect), 435341)
  expect_equal(sum(ex_lookup$start_testritscore), 1871739)
})



test_that("generate_growth_df builds scaffold and finds growth scores", {
  
  growth_df <- generate_growth_dfs(processed_cdf)
  expect_equal(nrow(growth_df), 25754)
  expect_equal(sum(as.numeric(growth_df$start_testritscore), na.rm = TRUE), 3295979)
  expect_equal(sum(as.numeric(growth_df$end_testritscore), na.rm = TRUE), 4190977)
  
})



test_that("build_growth_scaffolds returns expected output on sample data", {
  scaffold <- build_growth_scaffolds(processed_cdf)
  expect_equal(nrow(scaffold), 25754)
  expect_equal(
    round(sum(as.numeric(scaffold$start_grade_level_season), na.rm = TRUE),1), 
    97731.6
  )
  expect_equal(
    sum(as.numeric(scaffold$end_testid), na.rm = TRUE) - 
      sum(as.numeric(scaffold$start_testid), na.rm = TRUE), 
    487259127716
  )
})



test_that("growth_testid_lookup behaves as expected", {
    scaffold <- build_growth_scaffolds(processed_cdf)
    score_matched <- growth_testid_lookup(scaffold, processed_cdf)
  
    expect_equal(nrow(score_matched), 25754)
    expect_equal(ncol(score_matched), 49)
    expect_equal(sum(as.numeric(score_matched$start_testritscore), na.rm = TRUE), 
                 3295979)
    expect_equal(sum(as.numeric(score_matched$end_testritscore), na.rm = TRUE),
                 4190977)
})



test_that("growth_norm_lookup find norm data", {
  scaffold <- build_growth_scaffolds(processed_cdf)
  score_matched <- growth_testid_lookup(scaffold, processed_cdf)
  norm_matched <- growth_norm_lookup(
    score_matched, processed_cdf, norms_long, FALSE
  )
  
  expect_equal(nrow(norm_matched), 25754)
  expect_equal(ncol(norm_matched), 52)
  expect_equal(
    as.character(summary(norm_matched)[, 'typical_growth'][3]), 
    "Median : 2.762  " 
  )
  expect_equal(sum(norm_matched$reported_growth, na.rm = TRUE), 52994, tolerance = 200)
})


test_that("calc_rit_growth_metrics properly calculates growth metrics", {
  scaffold <- build_growth_scaffolds(processed_cdf)
  score_matched <- growth_testid_lookup(scaffold, processed_cdf)
  norm_matched <- growth_norm_lookup(
    score_matched, processed_cdf, norms_long, FALSE
  )
  
  with_rit_metrics <- calc_rit_growth_metrics(norm_matched)
  
  expect_equal(nrow(with_rit_metrics), 25754)
  expect_equal(ncol(with_rit_metrics), 57)
  expect_equal(median(with_rit_metrics$rit_growth,na.rm = TRUE),3)
  expect_equal(median(with_rit_metrics$change_testpercentile,na.rm = TRUE),1)
  expect_equal(median(with_rit_metrics$cgi,na.rm = TRUE), 0.1186,
               tolerance = 1e-2)

  expect_equal(sum(norm_matched$reported_growth, na.rm = TRUE), 52994, tolerance = 200)  
})


test_that("growth_norm_lookup with unsanctioned windows", {
  scaffold <- build_growth_scaffolds(processed_cdf)
  score_matched <- growth_testid_lookup(scaffold, processed_cdf)
  norm_matched <- growth_norm_lookup(
    score_matched, processed_cdf, norms_long, TRUE
  )
  expect_equal(nrow(norm_matched), 30227)
  expect_equal(ncol(norm_matched), 52)
  expect_equal(
    as.character(summary(norm_matched)[, 'typical_growth'][3]), 
    "Median : 2.356  " 
  )
  expect_equal(sum(norm_matched$reported_growth, na.rm = TRUE), 60609.5, tolerance = 200)
  
})


test_that("scaffold with no one season returns projections, but not performance", {
  single_season_scaffold <- student_scaffold(
    processed_cdf = processed_cdf %>% dplyr::filter(fallwinterspring == 'Fall') 
   ,start_season = 'Fall'
   ,end_season = 'Spring'
   ,year_offset = 0
  )
  
  expect_equal(nrow(single_season_scaffold), 2186)
  expect_equal(ncol(single_season_scaffold), 17)
  expect_equal(sum(single_season_scaffold$start_grade_level_season), 13704.2)
  expect_true(all(is.na(single_season_scaffold$end_grade_level_season)))
})