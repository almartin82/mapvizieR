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
#' @param spring_is_first logical indicating whether spring is in the given 
#' academic year or from the year prior. 
#' @param filter_args a list of character vectors to filter `mapvizieR_obj$cdf` 
#' by that is passed to \code{\link[dplyr]{filter}}
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
  cohort = FALSE,
  spring_is_first = FALSE,
  filter_args = NULL
) {
  #NSE problems
  measurementscale_in <- measurementscale
  cohort_year <- cohort
  
  #data validation and unpack
  mv_opening_checks(mapvizieR_obj, studentids, 1)

  #data processing ----------------------------------------------------------
  #just desired terms
  .data <- mapvizieR_obj$cdf %>%
    dplyr::mutate(cohort = map_year_academic + 1 + 12 - grade) 
  
  if (cohort) {
    .data <- .data %>% 
      dplyr::filter(
        fallwinterspring %in% fws,
        measurementscale == measurementscale_in,
        studentid %in% studentids,
        cohort == cohort_year
      )
  } else {
    if (spring_is_first){
      .data_not_spring <- .data %>%
        dplyr::filter(
          fallwinterspring %in% dplyr::setdiff(fws, "Spring"),
          map_year_academic == year,
          measurementscale == measurementscale_in,
          studentid %in% studentids 
          )
      
      .data_prior_spring <- .data %>%
        dplyr::filter(
          fallwinterspring == "Spring",
          map_year_academic == year-1,
          measurementscale == measurementscale_in,
          studentid %in% studentids 
        ) %>%
        dplyr::mutate(grade = grade+1,
                      map_year_academic = map_year_academic +1)
      
      .data <- dplyr::bind_rows(.data_not_spring,
                       .data_prior_spring)
    } else {
    .data <- .data %>%
      dplyr::filter(
        fallwinterspring %in% fws,
        map_year_academic == year,
        measurementscale == measurementscale_in,
        studentid %in% studentids
      )
    }
  }
  
  # other filter arguments
  if (!missing(filter_args)) {
    filter_args$.data <- .data
    .data <- do.call(dplyr::filter_, filter_args)
  }
    
  m_goal_scores <- .data %>%
    dplyr::ungroup() %>%
    dplyr::select(studentid, testid, measurementscale, schoolname, cohort, termname, fallwinterspring, map_year_academic, grade,
           dplyr::matches("(goal)[0-9]ritscore"))
  
  m_goal_stderr <- .data %>%
    dplyr::ungroup() %>%  
    dplyr::select(studentid, testid, measurementscale, schoolname, cohort, termname, fallwinterspring, map_year_academic, grade,
           dplyr::matches("(goal)[0-9]stderr"))
  
  m_goal_names <- .data %>%
    dplyr::ungroup() %>%    
    dplyr::select(studentid, testid, measurementscale, schoolname, cohort, termname, fallwinterspring, map_year_academic, grade,
           dplyr::matches("(goal)[0-9](name)")) 
  
  m_goal_range <- .data %>%
    dplyr::ungroup() %>%    
    dplyr::select(studentid, testid, measurementscale, schoolname, cohort, termname, fallwinterspring, map_year_academic, grade,
           dplyr::matches("(goal)[0-9](range)"))
  
  # time to gather
  m_goal_names_long <- m_goal_names %>%
    tidyr::pivot_longer(cols = goal1name:goal8name, names_to = "variable", values_to = "goal_name") %>%
    dplyr::mutate(goal_name = ifelse(goal_name == "", NA, goal_name))


  m_goal_scores_long <- m_goal_scores %>%
    tidyr::pivot_longer(cols = goal1ritscore:goal8ritscore, names_to = "variable", values_to = "goal_score")

  m_goal_stderr_long <- m_goal_stderr %>%
    tidyr::pivot_longer(cols = goal1stderr:goal8stderr, names_to = "variable", values_to = "goal_stderr")

  m_goal_range_long <- m_goal_range %>%
    tidyr::pivot_longer(cols = goal1range:goal8range, names_to = "variable", values_to = "goal_range")
  
  
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
              mean_stderr = round(sqrt(mean((goal_stderr ^ 2))),1),
              mean_low = mean(goal_low),
              mean_high = mean(goal_high),
              n_students = dplyr::n()) %>%
    dplyr::ungroup() %>%
    dplyr::filter(n_students>20)
  
  if (spring_is_first & any(cohort == FALSE)) {
    goals_summary_by_school <- goals_summary_by_school %>%
      dplyr::mutate(
        fws = ifelse(fallwinterspring=="Spring", 
                     "Prior\nSpring", 
                     fallwinterspring),
        season = factor(fws, 
                        c("Prior\nSpring", "Fall", "Winter"), 
                        ordered=TRUE))
  } else {
    goals_summary_by_school <- goals_summary_by_school %>%
      dplyr::mutate(season = factor(fallwinterspring, 
                                    c("Fall", "Winter", "Spring"), 
                                    ordered=TRUE))
  }
    
  
  
  ggplot(goals_summary_by_school,
         aes(y=mean_score,
             x=season)) +
    geom_text(aes(y = mean_low,
                  label = round(mean_low),
                  color=schoolname),
              position = position_dodge(width = 1),
              hjust=1,
              vjust=1,
              show.legend = FALSE) +
    geom_text(aes(y = mean_high,
                  label = round(mean_high),
                  color=schoolname),
              position = position_dodge(width = 1),
              hjust=0,
              vjust=1,
              show.legend = FALSE) +
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
              fontface="bold",
              show.legend = FALSE) +
    coord_flip() +
    facet_grid(goal_name ~ grade, switch = "y") +
    theme_light() +
    theme(legend.position = "bottom",
          strip.text.y = element_text(angle = 180)) + 
    labs(x = "RIT Score",
         y = "Goal Strand & Season",
         color = "School")
}
  