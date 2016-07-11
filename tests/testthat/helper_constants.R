#everything here gets run before tests
mapviz <- mapvizieR(
  cdf = ex_CombinedAssessmentResults, 
  roster = ex_CombinedStudentsBySchool
)
cdf <- mapviz[['cdf']]
roster <- mapviz[['roster']]
growth_df <- mapviz[['growth_df']]

#intermediate
prepped_cdf <- prep_cdf_long(ex_CombinedAssessmentResults)
#processed
prepped_roster <- prep_roster(ex_CombinedStudentsBySchool)
prepped_cdf$grade <- grade_levelify_cdf(prepped_cdf, prepped_roster)
processed_cdf <- process_cdf_long(prepped_cdf)

#studentid vectors
studentids_normal_use <- cdf %>%
  dplyr::filter(
    map_year_academic == 2013 & 
      measurementscale == 'Mathematics' & 
      fallwinterspring == 'Fall' & 
      grade == 6
  ) %>%
  dplyr::ungroup() %>%
  dplyr::select(studentid) %>%
  unlist() %>% unname()

studentids_random <- sample(ex_CombinedStudentsBySchool$StudentID, 100) %>% 
  unique()

studentids_subset <- cdf %>%
  dplyr::filter(
    map_year_academic == 2013 & 
      measurementscale == 'Mathematics' & 
      fallwinterspring == 'Fall'
  ) %>%
  dplyr::ungroup() %>%
  dplyr::select(studentid) %>%
  unlist() %>% unname()

studentids_hs <- cdf %>%
  dplyr::filter(
    map_year_academic == 2013 & 
      measurementscale == 'Mathematics' & 
      fallwinterspring == 'Fall' &
      grade %in% c(10,11)
  ) %>%
  dplyr::ungroup() %>%
  dplyr::select(studentid) %>%
  unlist() %>% unname()

studentids_ms <- cdf %>%
  dplyr::filter(
    map_year_academic == 2013 & 
      measurementscale == 'Mathematics' & 
      fallwinterspring == 'Fall' &
      grade %in% c(5,6,7,8)
  ) %>%
  dplyr::ungroup() %>%
  dplyr::select(studentid) %>%
  unlist() %>% unname()

studentids_gr11 <- cdf %>%
  dplyr::filter(
    map_year_academic == 2013 & 
      measurementscale == 'Mathematics' & 
      fallwinterspring == 'Fall' &
      grade == 11
  ) %>%
  dplyr::ungroup() %>%
  dplyr::select(studentid) %>%
  unlist() %>% unname()

studentids_one_school <- cdf %>%
  dplyr::filter(
    map_year_academic == 2013 & 
      measurementscale == 'Mathematics' & 
      fallwinterspring == 'Fall' & 
      grade == 2 &
      schoolname == 'Three Sisters Elementary School'
  ) %>%
  dplyr::ungroup() %>%
  dplyr::select(studentid) %>%
  unlist() %>% unname()

mapviz_midyear <- mapvizieR(
  cdf = ex_CombinedAssessmentResults[with(ex_CombinedAssessmentResults, 
                                          TermName != 'Spring 2013-2014'), ], 
  roster = ex_CombinedStudentsBySchool
)

#simulated KIPP data
#TOTALLY FAKE.  the distributions do not even match KIPP data.  you should not
#(and cannot) make any conclusions about the performance of KIPP schools from 
#this data.  this data frame exists ONLY for automated testing and bears
#no relation to actual data.
fake_kipp_data <- data.frame(
  School_Display_Name = c(
    "KIPP Harmony Academy", "KIPP Harmony Academy", "KIPP Legacy Preparatory School", 
    "KIPP Austin Comunidad", "KIPP Harmony Academy", "KIPP Legacy Preparatory School", 
    "KIPP Harmony Academy", "KIPP Harmony Academy", "KIPP Harmony Academy", 
    "KIPP Harmony Academy", "KIPP Harmony Academy", "KIPP Harmony Academy", 
    "KIPP SHARP College Prep Lower School", "KIPP Austin Connections Elementary", 
    "KIPP Explore Academy", "KIPP Harmony Academy", "KIPP Austin Comunidad", 
    "KIPP Explore Academy", "KIPP Harmony Academy", "KIPP Harmony Academy", 
    "KIPP Harmony Academy", "KIPP Harmony Academy", "KIPP Empower Academy", 
    "KIPP Explore Academy", "KIPP SHINE Prep", "KIPP Explore Academy", 
    "KIPP Explore Academy", "KIPP ZENITH Academy", "KIPP DC: Heights Academy", 
    "KIPP Dream Prep"
  ), 
  Start_RIT = rnorm(30, 165, 10), 
  End_RIT = rnorm(30, 175, 12), 
  Perc_Growth = rnorm(30, 0.50, .12), 
  N = rnorm(30, 100, 15), 
  Growth_Grade_Level = rep(1, 30), 
  Sub_Test_Name = rep('Mathematics', 30), 
  Start_Season = rep('FALL', 30), 
  End_Season = rep('SPRING', 30),
  Growth_Academic_Year = rep(2013, 30),
  stringsAsFactors = FALSE
)
