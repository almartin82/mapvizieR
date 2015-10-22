#' A small multiples plot of a set of students' national percentile rank histories.
#'
#' @description This plots a proto-typical example of Edward Tufte's small multiples
#' concept.  A class of students in one subject and grade is plotted, witch each
#' student's historical national percentile rank plotted with a simple liear fit.
#'
#' The background colors indicate the quartile the assessment earned.
#'
#' @param mapvizieR_obj a \code{\link{mapvizieR}} object
#' @param studentids a set of student ids to subset to
#' @param measurementscale a MAP measurementscale
#' @param title_text title as a character vector
#'
#' @return a ggplot2 object
#'
#' @export
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
#'    dplyr::filter(
#'      Grade == 8,
#'      SchoolName == "Mt. Bachelor Middle School",
#'      TermName == "Spring 2013-2014") %>% 
#'    dplyr::select(StudentID) %>%
#'    unique()
#'
#' student_npr_history_plot(
#'   map_mv,
#'   studentids = ids[1:80, "StudentID"],
#'   measurementscale = "Reading")
#'}

student_npr_history_plot <- function(
  mapvizieR_obj,
  studentids,
  measurementscale,
  title_text = ""
){
  # data validation
  mv_opening_checks(mapvizieR_obj, studentids, 1)

  # filter roster and df to only use those that exists in studentids
  roster <- mapvizieR_obj$roster %>%
    dplyr::filter(studentid %in% studentids)

  cdf <- mv_limit_cdf(mapvizieR_obj, studentids, measurementscale)

  # combine roster and cdf form mapvizier_object
  map_df <- roster_to_cdf(cdf, mapvizieR_obj, c('studentfirstlast'))

  min_grade <- min(map_df$grade_level_season)
  max_grade <- max(map_df$grade_level_season)

  assessments_breaks <- unique(map_df$grade_level_season)

  assessment_order2 <- unique(map_df$grade_season_label)

  p_indv <- ggplot(
      data = map_df, 
      aes(x = grade_level_season, y = testpercentile)
    ) +
    geom_line(aes(group = studentid)) +
    geom_point(size = 2) +
    annotate(
      "rect",
      ymin = 0,
      ymax  = 25,
      xmin = min_grade,
      xmax = max_grade,
      fill = "red",
      alpha = .1
    ) +
    annotate(
      "rect",
      ymin = 25,
      ymax = 50,
      xmin = min_grade,
      xmax = max_grade,
      fill = "gold",
      alpha = .1
    ) +
    annotate(
      "rect",
      ymin = 50,
      ymax = 75,
      xmin = min_grade,
      xmax = max_grade,
      fill = "blue",
      alpha = .1
    ) +
    annotate(
      "rect",
      ymin = 75,
      ymax = 100,
      xmin = min_grade,
      xmax = max_grade,
      fill = "green",
      alpha = .1
    ) +
    stat_smooth(method = "lm", se = FALSE) +
    facet_wrap(~studentfirstlast, ncol = 10) +
    scale_x_continuous("Assessments",
                       breaks = assessments_breaks,
                       labels = assessment_order2) +
    theme_minimal() +
    theme(strip.text = element_text(size = 8),
          axis.text.y = element_text(size = 6),
          axis.text.x = element_text(size = 4)
    ) +
    ylab("National Percentile Rank") + 
    ggtitle(title_text)

  #return
  p_indv

}
