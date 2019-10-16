## code to prepare `data/student_growth_norms_2015.rda` dataset goes here

stu_2015 <- read_csv("data-raw/STU_NORMS2015_GROWTHV2_EXT.csv") %>%
  mutate(Grade = if_else(Grade==13, 0, Grade))

var_names <- colnames(stu_2015)

# Here we need to pull apart the Spring to spring metrics and the witner to winter metrics, 
# roll the "Grade" back one year so that all "Grades" = "start grade" for a metric. 
stu_grade_is_end <- stu_2015 %>%
  select(Subject, Grade, StartRIT, matches("11|22")) 

stu_grade_is_start <- stu_2015 %>%
  select(-matches("11|22"))

stu_grade_is_end_correct <- stu_grade_is_end %>%
  mutate(Grade = Grade - 1)


stu_2015_corrected <- stu_grade_is_start %>%
  left_join(stu_grade_is_end_correct, by = c("Subject", "Grade", "StartRIT")) %>%
  select(var_names)


student_growth_norms_2015 <- stu_2015_corrected %>%
  mutate_at(vars(starts_with("R")), as.integer) %>%
  mutate(StartRIT = as.integer(StartRIT),
         MeasurementScale = case_when(
           Subject == 1 ~ "Mathematics",
           Subject == 2 ~ "Reading",
           Subject == 3 ~ "Language Usage",
           Subject == 4 ~ "General Science"
         ), 
         norms_year = 2015L) %>%
  arrange(Subject, Grade, StartRIT) %>%
  rename(StartGrade = Grade)

student_growth_norms_2015 %>% View




usethis::use_data(student_growth_norms_2015, internal = FALSE, overwrite = TRUE)
