#' @title Plot MAP Goal Strand Summary Info
#'
#'
#' @description Plots a group of students' average RIT scores and RIT Ranges for 
#' goal strands. 
#'
#' @details Creates and prints a ggplot2 object showing average and and average range 
#' of goal strand RIT scores 
#' 
#' @param mapvizieR_obj a \code{mapvizieR} object 
#' @param studentids vector of student id numbers for students to plot
#' @param measurementscale measurementscale to plot
#' @param fws seasons (fall, winter, or spring) as a character vector to plot
#' @param year academic year to plot
#' @param cohort cohort year to plot as integer or FALSE (the default).  If `cohort`
#' is not FALSE then `year` is ignored
#' 
#' @return a ggplot2 object
#' 
#' @examples 
#' \dontrun{
#' require(dplyr)
#' 
#' data("ex_CombinedStudentsBySchool")
#' data("ex_CombinedAssessmentResults")
#'
#' map_mv <- mapvizieR(ex_CombinedAssessmentResults, ex_CombinedStudentsBySchool)
#'
#' ids <- ex_CombinedStudentsBySchool %>%
#' dplyr::filter(
#'   TermName == "Spring 2013-2014") %>% select(StudentID) %>%
#'   unique()
#'
#' goal_strand_summary_plot(map_mv, 
#'    ids$StudentID, 
#'    measurementscale = "Reading", 
#'    year = 2013, 
#'    cohort = 2019, 
#'    fws  = c("Winter", "Spring")
#'    )
#'}
#'@export

goal_strand_summary_plot <- function(
  mapvizieR_obj,
  studentids,
  measurementscale,
  fws = c("Fall", "Winter", "Spring"),
  year,
  cohort = FALSE
) {
  #NSE problems
  measurementscale_in <- measurementscale
  cohort_year <- cohort
  # validation
  #data validation and unpack
  mv_opening_checks(mapvizieR_obj, studentids, 1)

  #data processing ----------------------------------------------------------
  #just desired terms
  .data <- mapvizieR_obj$cdf %>%
    dplyr::mutate(cohort = map_year_academic + 1 + 12 - grade) 
  
  if(cohort) {
    .data <- .data %>% 
      dplyr::filter(
        fallwinterspring %in% fws,
        measurementscale == measurementscale_in,
        studentid %in% studentids,
        cohort == cohort_year
      )
  } else {
    .data <- .data %>%
      dplyr::filter(
        fallwinterspring %in% fws,
        map_year_academic == year,
        measurementscale == measurementscale_in,
        studentid %in% studentids
      )
  }
  
  m_goal_scores <- .data %>%
    dplyr::select(studentid, testid, measurementscale, schoolname, cohort, termname, fallwinterspring, map_year_academic, grade,
           matches("(goal)[0-9]ritscore"))
  
  m_goal_stderr <- .data %>%
    dplyr::select(studentid, testid, measurementscale, schoolname, cohort, termname, fallwinterspring, map_year_academic, grade,
           matches("(goal)[0-9]stderr"))
  
  m_goal_names <- .data %>%
    dplyr::select(studentid, testid, measurementscale, schoolname, cohort, termname, fallwinterspring, map_year_academic, grade,
           matches("(goal)[0-9](name)")) 
  m_goal_range <- .data %>%
    dplyr::select(studentid, testid, measurementscale, schoolname, cohort, termname, fallwinterspring, map_year_academic, grade,
           matches("(goal)[0-9](range)"))
  
  # time to gather
  
  m_goal_names_long <- m_goal_names %>%
    tidyr::gather(key = variable, value = goal_name, goal1name:goal8name) %>%
    dplyr::mutate(goal_name = ifelse(goal_name == "", NA, goal_name))
  
  
  m_goal_scores_long <- m_goal_scores %>%
    tidyr::gather(key = variable, value = goal_score, goal1ritscore:goal8ritscore)
  
  m_goal_stderr_long <- m_goal_stderr %>%
    tidyr::gather(key = variable, value = goal_stderr, goal1stderr:goal8stderr)
  
  m_goal_range_long <- m_goal_range %>%
    tidyr::gather(key = variable, value = goal_range, goal1range:goal8range)
  
  
  m_goals <- m_goal_names_long %>%
    dplyr::mutate(goal_score = m_goal_scores_long$goal_score,
                  goal_stderr = m_goal_stderr_long$goal_stderr,
                  goal_low = round(goal_score - goal_stderr),
                  goal_high = round(goal_score + goal_stderr),
                  goal_range = m_goal_range_long$goal_range
    ) %>%
    dplyr::select(-variable) %>%
    dplyr::filter(!is.na(goal_name))
  
  # summarize those suckers!
  
  goals_summary_by_school <- m_goals %>%
    dplyr::group_by(goal_name, cohort, grade, fallwinterspring, map_year_academic, schoolname) %>%
    dplyr::summarize(mean_score = mean(goal_score),
              mean_stderr = round(sqrt(mean((goal_stderr^2))),1),
              mean_low = mean(goal_low),
              mean_high = mean(goal_high),
              n_students = n()) %>%
    dplyr::ungroup() %>%
    dplyr::filter(n_students>20) %>%
    dplyr::mutate(season = factor(fallwinterspring, c("Fall", "Winter", "Spring"), ordered=TRUE))
  
  
  ggplot(goals_summary_by_school,
         aes(y=mean_score,
             x=season)) +
    geom_text(aes(y = mean_low,
                  label = round(mean_low),
                  color=schoolname),
              position = position_dodge(width = 1),
              hjust=1,
              vjust=1) +
    geom_text(aes(y = mean_high,
                  label = round(mean_high),
                  color=schoolname),
              position = position_dodge(width = 1),
              hjust=0,
              vjust=1) +
    geom_linerange(aes(ymin = mean_low,
                       ymax = mean_high,
                       x = season,
                       color=schoolname),
                   position = position_dodge(width = 1)) +
    
    geom_point(aes(y = mean_score,
                   x = season,
                   color=schoolname),
               position = position_dodge(width = 1)) +

    geom_text(aes(y = mean_score,
                  label = round(mean_score),
                  color=schoolname),
              position = position_dodge(width = 1),
              hjust=.5,
              vjust=-.7,
              size=4,
              fontface="bold") +
    coord_flip() +
    facet_grid(goal_name ~ grade, switch = "y") +
    theme_light() +
    theme(legend.position = "bottom",
          strip.text.y = element_text(angle = 180)) + 
    labs(x = "RIT Score",
         y = "Goal Strand & Season")
}
  