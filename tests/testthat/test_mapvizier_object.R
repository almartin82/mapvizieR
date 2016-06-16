context("creating the mapvizier object using the sample NWEA data")

test_that("grade_level_ify correctly processes CDF", {
  ex_roster <- prep_roster(ex_CombinedStudentsBySchool)
  ex_cdf <- prep_cdf_long(ex_CombinedAssessmentResults)
  
  ex_cdf$grades <- grade_levelify_cdf(ex_cdf, ex_roster)
  grade_freq <- table(ex_cdf$grades)
  
  ex_roster_termname_missing <- ex_roster %>%
    dplyr::filter(termname == "Fall 2013-2014") %>%
    dplyr::sample_n(10)
    
  
  ex_cdf_termname_missing <- dplyr::semi_join(
    ex_cdf %>% dplyr::select(-grades),
    ex_roster_termname_missing,
    by = c("studentid", "termname")
  )
  
  ex_roster_termname_missing <- ex_roster_termname_missing %>%
    dplyr::mutate(termname=paste(termname,".xxx"))
  
  ex_cdf_termname_missing$grades <- grade_levelify_cdf(ex_cdf_termname_missing, 
                                                       ex_roster_termname_missing)
  
  
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
  
  expect_equal(sum(is.na(ex_cdf_termname_missing$grades)), 0)
})



test_that("grade_season_factors return correct order", {
  
  just_grade_season <- data.frame(
    grade_level_season = c(-0.8, -0.5, 4, 5, 11, 6.5, 6.2, 7, 7.2, 8, 10.5)
  )
  
  with_factors <- just_grade_season %>% 
    dplyr::rowwise() %>%
    dplyr::mutate(
      grade_season_label = fall_spring_me(grade_level_season)
    ) %>%
    grade_season_factors()
  
  expect_true(all(c("ordered", "factor") %in% class(with_factors$grade_season_label)))
  
  label_order <- levels(with_factors$grade_season_label)
  
  expect_equal(label_order[[1]], 'KF')
  expect_equal(label_order[[4]], '5S')
  expect_equal(label_order[[5]], '7F')
  expect_equal(label_order[[6]], '7W')
  expect_equal(label_order[[7]], '7S')
  expect_equal(label_order[[10]], '11W')
})



test_that("mapvizieR S3 class methods work", {
  mv <- mapvizieR(
    cdf = ex_CombinedAssessmentResults,
    roster = ex_CombinedStudentsBySchool
  )
  
  expect_equal(length(mv), 4)
  expect_equal(names(mv), c("cdf", "roster", "growth_df", "goals"))
  expect_output(print.mapvizieR(mv), "714 students")
  expect_output(print.mapvizieR(mv), "SY2012 to SY2013")
  expect_true(is.mapvizieR(mv))
  expect_false(is.mapvizieR(ex_CombinedAssessmentResults))
})



test_that("mapvizieR messages print when in verbose mode", {
  expect_output(
    mapvizieR(
      cdf = ex_CombinedAssessmentResults,
      roster = ex_CombinedStudentsBySchool,
      verbose = TRUE), 
    "preparing and processing your CDF..."
  )
  
  samp_cdf <- prep_cdf_long(ex_CombinedAssessmentResults)
  samp_roster <- prep_roster(ex_CombinedStudentsBySchool)
  samp_cdf$grade <- grade_levelify_cdf(samp_cdf, samp_roster)
  processed_cdf <- process_cdf_long(samp_cdf)

  expect_output(
    mapvizieR(
      cdf = processed_cdf,
      roster = ex_CombinedStudentsBySchool,
      verbose = TRUE), 
    "your CDF is ready to go!"
  )
  
})


test_that("mapvizieR object works with different norms",{
  mv_2011 <- mapvizieR(
    cdf = ex_CombinedAssessmentResults,
    roster = ex_CombinedStudentsBySchool,
    norms = 2011
  )
  
  expect_equal(sum(mv_2011$growth_df$reported_growth, na.rm = TRUE), 47050L)
  expect_equal(sum(mapviz$growth_df$reported_growth, na.rm = TRUE), 53164L)

})