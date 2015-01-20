context("test util functions on sample data provided by NWEA")

test_that("abbrev abbreviates school names properly", {
  
  roster <- prep_roster(ex_CombinedStudentsBySchool)
  school_names <- unique(roster$schoolname)
  
  expected_abbrev <- c("MBMS", "MHHS", "SHES", "TSES")
  
  alts <- list(old=c("SHES", "TSES"),
               new=c("St. Helens", "3 Sisters")
               )
  expected_alts <- c("MBMS", "MHHS", "St. Helens", "3 Sisters")
  
  expect_equal(abbrev(school_names), expected_abbrev)
  expect_equal(abbrev(school_names, exceptions = alts), expected_alts)
  
  expect_equal(length(abbrev(roster$schoolname)), nrow(roster))
  
})

test_that("kipp_quartile returns KIPP style quartiles",{
  test_percentiles<-c(78, 16, 64, 72, 17, 27, 92, 34, 67, 33, 25, 50, 75)
  expected_quartiles_kipp<-    c(4,1,3,3,1,2,4,2,3,2,2,3,4)
  expected_quartiles_not_kipp<-c(4,1,3,3,1,2,4,2,3,2,1,2,3)
  
  cdf <- prep_cdf_long(ex_CombinedAssessmentResults)
  
  expect_equal(kipp_quartile(test_percentiles, return.factor = FALSE), 
               expected_quartiles_kipp)
  
  expect_equal(kipp_quartile(test_percentiles, return.factor = TRUE), 
               as.factor(expected_quartiles_kipp))
  
  expect_equal(kipp_quartile(test_percentiles, 
                             return.factor = TRUE, 
                             proper.quartile = TRUE),
               as.factor(expected_quartiles_not_kipp))
  
  expect_equal(kipp_quartile(test_percentiles, 
                             return.factor = FALSE, 
                             proper.quartile = TRUE),
               expected_quartiles_not_kipp)
  
  expect_equal(length(kipp_quartile(cdf$testpercentile)), nrow(cdf))
})

test_that("tiered_growth_factors calculates proper tiered growth factors",{
  
  grades<-rep(0:12, times=4)
  quartiles <- c(rep(1, times=13), 
                rep(2, times=13),
                rep(3, times=13),
                rep(4, times=13))
  expected_quartiles <- c(rep(1.50, times=4),
                          rep(2.00, times=9),
                          rep(1.50, times=4),
                          rep(1.75, times=9),
                          rep(1.25, times=4),
                          rep(1.50, times=9),
                          rep(1.25, times=4),
                          rep(1.25, times=9)
                          )
  
  cdf <- prep_cdf_long(ex_CombinedAssessmentResults)
  cdf <- cdf  %>%
    mutate(testquartiles=kipp_quartile(testpercentile))
  
  
  expect_equal(tiered_growth_factors(quartiles, grades), expected_quartiles)
  #expect_equal(length(tiered_growth_factors(cdf$testquartiles, cdf$grade)), 
  #             nrow(cdf)
  #             )
  
  
})