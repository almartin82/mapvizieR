library(reshape2)
library(stringr)

sch_2015 <- read.csv('data-raw/SchoolGrowthNorms2015.csv')

sch_2015_long <- sch_2015 %>%
  dplyr::mutate(
    Subject = ifelse(Subject == 1, 'Mathematics', Subject),
    Subject = ifelse(Subject == 2, 'Reading', Subject),
    Subject = ifelse(Subject == 3, 'Language Usage', Subject),
    Subject = ifelse(Subject == 4, 'General Science', Subject)
  ) %>%
  reshape2::melt(
    id.vars = c('Subject', 'Grade', 'StartRIT')
  ) %>%
  dplyr::mutate(
    time_window = str_sub(variable, 2, 3),
    variable = str_sub(variable, 1, 1), 
    variable = ifelse(variable == 'P', 'typical_cohort_growth', variable),
    variable = ifelse(variable == 'Q', 'reported_cohort_growth', variable),
    variable = ifelse(variable == 'U', 'sd_of_expectation', variable)
  ) %>%
  dplyr::mutate(
    start_fallwinterspring = str_sub(time_window, 1, 1),
    end_fallwinterspring = str_sub(time_window, 2, 2),
    start_fallwinterspring = ifelse(start_fallwinterspring == '1', 'Winter', start_fallwinterspring),
    start_fallwinterspring = ifelse(start_fallwinterspring == '2', 'Spring', start_fallwinterspring),
    start_fallwinterspring = ifelse(start_fallwinterspring == '3', 'Summer', start_fallwinterspring),
    start_fallwinterspring = ifelse(start_fallwinterspring == '4', 'Fall', start_fallwinterspring),
    end_fallwinterspring = ifelse(end_fallwinterspring == '1', 'Winter', end_fallwinterspring),
    end_fallwinterspring = ifelse(end_fallwinterspring == '2', 'Spring', end_fallwinterspring),
    end_fallwinterspring = ifelse(end_fallwinterspring == '3', 'Summer', end_fallwinterspring),
    end_fallwinterspring = ifelse(end_fallwinterspring == '4', 'Fall', end_fallwinterspring)
  ) %>%
  dplyr::mutate(
    growth_window = paste0(start_fallwinterspring, ' to ', end_fallwinterspring)
  ) %>%
  dplyr::mutate(
    Grade = ifelse(Grade == 13, 0, Grade)
  ) %>%
  #omg omg omg
  dplyr::mutate(
    Grade = ifelse(growth_window == 'Fall to Fall', Grade + 1, Grade)
  ) %>%
  dplyr::rename(
    measurementscale = Subject,
    rit = StartRIT,
    end_grade = Grade
  ) %>%
  dplyr::select(-time_window) %>%
  reshape2::dcast(
    end_grade + measurementscale + growth_window + start_fallwinterspring +
      end_fallwinterspring + rit ~ variable, value.var = 'value'
  ) %>%
  dplyr::select(
    end_grade, measurementscale, growth_window,
    start_fallwinterspring, end_fallwinterspring, rit, 
    typical_cohort_growth, sd_of_expectation, reported_cohort_growth
  ) %>%
  dplyr::tbl_df() 

write.csv(sch_2015_long, file = 'data-raw/SchoolGrowthNorms2015_tidy.csv')
sch_growth_norms_2015 <- sch_2015_long
save(sch_growth_norms_2015, file = 'data/sch_growth_norms_2015.rda')

sch_2015_long %>% peek()
sch_2015_long %>% peek() %>% str()
sch_2015_long$end_grade %>% table()
