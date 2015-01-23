context("creating the mapvizier object using the sample NWEA data")

test_that("grade_level_ify correctly processes CDF", {
  ex_roster <- prep_roster(ex_CombinedStudentsBySchool)
  ex_cdf <- prep_cdf_long(ex_CombinedAssessmentResults)
  
  ex_cdf$grades <- grade_levelify_cdf(ex_cdf, ex_roster)
  grade_freq <- table(ex_cdf$grades)
  
  ex_roster_termname_missing <- ex_roster %>%
    filter(termname=="Fall 2013-2014") %>%
    sample_n(10)
    
  
  ex_cdf_termname_missing <- semi_join(ex_cdf %>% select(-grades),
                                       ex_roster_termname_missing,
                                       by=c("studentid", "termname")
                                       )
  
  ex_roster_termname_missing <- ex_roster_termname_missing %>%
    mutate(termname==NA)
  
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

test_that("cdf_roster_match properly joins assessment results and rosters", {
  ex_roster <- prep_roster(ex_CombinedStudentsBySchool)
  ex_roster_small <- ex_roster[-c(20:100),]
  ex_cdf <- prep_cdf_long(ex_CombinedAssessmentResults)
  ex_matched <- cdf_roster_match(ex_cdf, ex_roster)
  
  expect_equal(nrow(ex_matched), nrow(ex_cdf))
  expect_equal(ncol(ex_matched), ncol(ex_roster) + ncol(ex_cdf) -5) #-5 = -3 match columns and -2 duplicate columns
  
  expect_warning(cdf_roster_match(ex_cdf, ex_roster_small), "8848")
  
})


test_that("nwea_growth properly gets growth", {
  data(ex_CombinedAssessmentResults)
  data(ex_CombinedStudentsBySchool)
  
  cdf<- ex_CombinedAssessmentResults %>%
             prep_cdf_long 
  
  roster <- prep_roster(ex_CombinedStudentsBySchool)
  
  cdf$grade <-  grade_levelify_cdf(cdf, roster)
     
  growth<-nwea_growth(start.grade = cdf$grade, 
                      start.rit = cdf$testritscore,
                       measurementscale = cdf$measurementscale
                      )
  
  growth_spring_only<-nwea_growth(start.grade = cdf$grade,
                      start.rit = cdf$testritscore,
                      measurementscale = cdf$measurementscale,
                      "contains('22')"
  )
  expected_growth_col_names <- c("R12",
                                  "R22",
                                  "R41",
                                  "R42",
                                  "R44",
                                  "S12",
                                  "S22",
                                  "S41",
                                  "S42",
                                  "S44",
                                  "T12",
                                  "T22",
                                  "T41",
                                  "T42",
                                  "T44")

  expect_equal(ncol(growth), 15)
  expect_equal(nrow(growth), nrow(cdf))
  expect_equal(names(growth), expected_growth_col_names)
  expect_equal(names(growth_spring_only), c("R22", "S22", "T22"))
})

test_that("s2s_match properly matchs up data from a prepped long cdf",{
  cdf<- ex_CombinedAssessmentResults %>%
    prep_cdf_long 
  
  roster <- prep_roster(ex_CombinedStudentsBySchool)
  
  cdf$grade <-  grade_levelify_cdf(cdf, roster)
  
  cdf_growth_ss<-s2s_match(cdf, 
                        season1 = "Spring", 
                        season2 = "Spring", 
                        sy = 2013)
  
  cdf_growth_sw<-s2s_match(cdf, 
                           season1 = "Spring", 
                           season2 = "Winter", 
                           sy = 2013)
  
  expect_equal(nrow(cdf_growth_ss), 2099)
  expect_match(unique(cdf_growth_ss$growth_season), "Spring - Spring")
  expect_match(unique(cdf_growth_sw$growth_season), "Spring - Winter")
  
})

test_that("mapvizieR S3 class methods work", {
  mv<-mapvizieR(ex_CombinedAssessmentResults,
                ex_CombinedStudentsBySchool)
  
  expect_equal(length(mv), 3)
  expect_equal(names(mv), c("cdf", "roster", "cdf_growth"))
  expect_output(mv, "714 students")
  expect_output(print.mapvizieR(mv), "SY2012 to SY2013")
  expect_true(is.mapvizieR(mv))
  expect_false(is.mapvizieR(ex_CombinedAssessmentResults))
})