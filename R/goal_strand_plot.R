#' @title Plot MAP Goal Strand Results
#'
#'
#' @description Plots a group of students' goal strand RIT scores, with each 
#' student ranked by overall RIT score.  Colors of points indicating goal strand RIT 
#' scores indicate deviation from overall RIT score; colors of overall RIT mark (|)
#' indicate national percentile rank of the overall RIT score.
#'
#' @details Creates and prints a ggplot2 object showing both overall and goal strand RIT
#' scores for each student in a subets.  
#' 
#' @param mapvizieR_obj a \code{mapvizieR} object 
#' @param studentids vector of student id numbers for students to plot
#' @param measurement_scale measurementscale to plot
#' @param fws season (fall, winter, or spring) to plot
#' @param year academic year to plot
#' 
#' @return a ggplot2 object
#' 
#' @examples 
#' data("ex_CombinedStudentsBySchool")
#' data("ex_CombinedAssessmentResults")
#'
#' map_mv<-mapvizieR(ex_CombinedAssessmentResults, ex_CombinedStudentsBySchool)
#'
#' ids<-ex_CombinedStudentsBySchool %>% filter(
#'    Grade==8,
#'    SchoolName=="Mt. Bachelor Middle School",
#'    TermName=="Spring 2013-2014") %>% select(StudentID) %>%
#'    unique()
#'
#' goal_strand_plot(
#'  map_mv, 
#'  studentids = c(ids[1:49, "StudentID"]), 
#'  measurement_scale="Mathematics", 
#'  fws="Spring", 
#'  year=2013
#'  )
#'
#'@export

goal_strand_plot <- function(mapvizieR_obj,
                         studentids,
                         measurement_scale,
                         fws,
                         year) {
  
     
  # validation
  #data validation and unpack
  mv_opening_checks(mapvizieR_obj, studentids, 1)

  #data processing ----------------------------------------------------------
  #just desired terms
  .data <- mapvizieR_obj$cdf %>%
    dplyr::filter(
      fallwinterspring == fws,
      map_year_academic == year,
      measurementscale == measurement_scale,
      studentid %in% studentids
    ) %>%
    dplyr::inner_join(mapvizieR_obj$roster %>%
                        dplyr::filter(fallwinterspring == fws,
                                      map_year_academic == year,
                                      studentid %in% studentids
                                      ) %>%
                        dplyr::select(studentid, 
                                      map_year_academic, 
                                      fallwinterspring, 
                                      studentfirstlast,
                                      studentlastfirst,
                                      grade
                                      ), 
                      by = c("studentid", 
                             "fallwinterspring", 
                             "map_year_academic",
                             "grade"
                             )
                      )

  
  m_sub_scores <- dplyr::select(.data, 
                              studentid,
                              studentfirstlast,
                              schoolname,
                              grade,
                              measurementscale,
                              testritscore,
                              testpercentile,
                              testquartile,
                              matches("(goal)[0-9]ritscore")
  )
  
  
  
  
  m_sub_names <- dplyr::select(.data, 
                             studentid,
                             studentfirstlast,
                             schoolname,
                             grade,
                             measurementscale,
                             testritscore,
                             testpercentile,
                             testquartile,
                             matches("(goal)[0-9]name")
  )
  
  
  # melt scores
  m_melt_scores <- reshape2::melt(m_sub_scores, 
                               id.vars = names(m_sub_scores)[1:8], 
                               measure.vars = names(m_sub_scores)[-c(1:8)]
  ) %>% 
    dplyr::mutate(value = as.numeric(value))
  
  m_melt_names <- reshape2::melt(m_sub_names, 
                              id.vars = names(m_sub_names)[1:8],
                              measure.vars = names(m_sub_names)[-c(1:8)]
  )
  
 assertthat::assert_that(nrow(m_melt_scores) == nrow(m_melt_names))
  
  
  # m.melt.scores2<-left_join(m.melt.scores, homerooms, by="StudentID")
  #  assert_that(nrow(m.melt.scores)==nrow(m.melt.scores2))
  
  m_long <- m_melt_scores
  
  m_long$goal_name <- m_melt_names$value
  
  assertthat::assert_that(nrow(m_long) == nrow(m_melt_names))
  
  m_long_2 <- filter(m_long, !is.na(goal_name)) %>%
    filter(!is.na(value))
  
  assertthat::assert_that(nrow(m_long) >= nrow(m_long_2))  
  
  m_plot <- m_long_2 %>% 
    dplyr::mutate(rank = rank(testritscore, ties.method = "first")) %>%
    dplyr::group_by(schoolname, 
             grade,
             measurementscale) %>%
    dplyr::mutate(
      student_display_name = factor(studentfirstlast, 
                                levels = unique(studentfirstlast)[order(rank,decreasing = TRUE)])  
    )
  
  p <- ggplot2::ggplot(data = m_plot, 
                       ggplot2::aes(y = goal_name, 
                                    x = value
                                    )
                      ) +
    ggplot2::geom_point(ggplot2::aes(fill = value - testritscore), 
                        shape = 21,
                        color = NA
                      ) + 
    ggplot2::geom_vline(ggplot2::aes(xintercept = mean(testritscore)), 
                        color = "gray") + 
    ggplot2::geom_vline(ggplot2::aes(xintercept = testritscore, 
                            color = testquartile
                            ), 
                        size = 1.5, 
                        show_guide = T
                        ) + 
    ggplot2::scale_fill_gradient("Deviation from\nOverall RIT",
                                 low = "red", 
                                 high = "green") +
    ggplot2::scale_color_discrete("Overall RIT Score\nQuartile") +
    ggplot2::xlab("RIT Score") + 
    ggplot2::ylab("Strand Name") +
    ggplot2::facet_grid(student_display_name ~ .) + 
    ggplot2::theme_bw() +
    ggplot2::theme(strip.text.y = ggplot2::element_text(angle = 0), 
                 axis.text.y = ggplot2::element_text(size = 5)
                 )
  
  # return
  p
  
}