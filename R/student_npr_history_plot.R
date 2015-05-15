#' A small multiples plot of a set of students' national percentile rank histories.
#'
#' @param mv_obj a \code{\link{mapvizier}} object
#' @param studentids a set of student ids to subset too.
#' @param measurment_scale the subject of interest
#'
#' @return a ggplot2 object
#'
#' @export
#'
#' @examples
#'
#' data("ex_CombinedStudentsBySchool")
#' data("ex_CombinedAssessmentResults")
#'
#' map_mv<-mapvizieR(ex_CombinedAssessmentResults, ex_CombinedStudentsBySchool)
#'
#' ids<-ex_CombinedStudentsBySchool %>% filter(Grade==8, SchoolName=="Mt. Bachelor Middle School", TermName=="Spring 2013-2014") %>% select(StudentID) %>% unique()
#'
#' student_npr_history_plot(map_mv, studentids = ids[1:80, "StudentID"], measurment_scale = "Reading")

student_npr_history_plot <- function(mv_obj, studentids, measurment_scale){

  # filter roster to only use requested subset
  roster <- mv_obj$roster %>%
    dplyr::filter(studentid  %in% studentids)

  cdf<-mv_obj$cdf %>%
    dplyr::filter(
      studentid %in% studentids,
      measurementscale %in% measurment_scale
      )

  map_df <- dplyr::inner_join(roster,
                              cdf,
                              by= c("studentid",
                                    "termname")
                              ) %>%
    mutate(Assessment=grade_season_label,
           Asses_sort=grade_level_season,
           Name=studentfirstlast)

   assessment_order<-map_df %>%
     ungroup %>%
     select(Assessment, Asses_sort) %>%
     unique %>%
     mutate(Assessment=factor(Assessment, levels = Assessment))

#   map_individual <- map_individual %>%
#     mutate(Assessment=factor(Assessment, levels=assessment_order$Assessment))



  min_grade <- min(map_df$grade_level_season)
  max_grade <- max(map_df$grade_level_season)
  assessments_breaks<-unique(map_df$grade_level_season)


  p_indv<-ggplot(map_df, aes(x=grade_level_season, y=testpercentile)) +
    geom_line(aes(group=studentid)) +
    geom_point(size=2) +
    annotate("rect", ymin=0, ymax=25, xmin=min_grade, xmax=max_grade, fill="red", alpha=.1) +
    annotate("rect", ymin=25, ymax=50, xmin=min_grade, xmax=max_grade, fill="gold", alpha=.1) +
    annotate("rect", ymin=50, ymax=75, xmin=min_grade, xmax=max_grade, fill="blue", alpha=.1) +
    annotate("rect", ymin=75, ymax=100, xmin=min_grade, xmax=max_grade, fill="green", alpha=.1) +
    stat_smooth(method="lm", se = FALSE) +
    facet_wrap(~Name, ncol = 10) +
    scale_x_continuous("Assessments",
                       breaks=assessments_breaks,
                       labels=assessment_order$Assessment) +
    theme_minimal() +
    theme(strip.text=element_text(size=8),
          axis.text.y=element_text(size=6),
          axis.text.x=element_text(size=4)
    ) +
    ylab("National Percentile Rank")

  #return
  p_indv

}
