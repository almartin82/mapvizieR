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
#' @param measurementscale measurementscale to plot
#' @param fws season (fall, winter, or spring) to plot
#' @param year academic year to plot
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
#'   dplyr::filter(
#'     Grade == 8,
#'     SchoolName == "Mt. Bachelor Middle School",
#'     TermName == "Spring 2013-2014") %>% select(StudentID) %>%
#'     unique()
#'
#' goal_strand_plot(
#'   map_mv, 
#'   studentids = c(ids[1:49, "StudentID"]), 
#'   measurementscale = "Mathematics", 
#'   fws = "Spring", 
#'   year = 2013
#' )
#'}
#'@export

goal_strand_plot <- function(
  mapvizieR_obj,
  studentids,
  measurementscale,
  fws,
  year
) {
  #NSE problems
  measurementscale_in <- measurementscale
  # validation
  #data validation and unpack
  mv_opening_checks(mapvizieR_obj, studentids, 1)

  #data processing ----------------------------------------------------------
  #just desired terms
  df <- mapvizieR_obj$cdf %>%
    dplyr::ungroup() %>%
    dplyr::filter(
      fallwinterspring == fws,
      map_year_academic == year,
      measurementscale == measurementscale_in,
      studentid %in% studentids
    ) 
  
  df <- roster_to_cdf(
    target_df = df, 
    mapvizieR_obj = mapvizieR_obj, 
    roster_cols = c('studentfirstlast')
  )
  
  m_sub_scores <- df %>% dplyr::select(
    studentid, studentfirstlast, schoolname, grade, measurementscale,
    testritscore, testpercentile, testquartile, dplyr::matches("(goal)[0-9]ritscore")
  )
  
  m_sub_names <- df %>% dplyr::select(
    studentid, studentfirstlast, schoolname, grade, measurementscale,
    testritscore, testpercentile, testquartile, dplyr::matches("(goal)[0-9]name")
  )
  
  # melt scores
  m_melt_scores <- reshape2::melt(
    m_sub_scores, 
    id.vars = names(m_sub_scores)[1:8], 
    measure.vars = names(m_sub_scores)[-c(1:8)]
  ) %>% 
  dplyr::mutate(value = as.numeric(value))
  
  m_melt_names <- reshape2::melt(
    m_sub_names, 
    id.vars = names(m_sub_names)[1:8],
    measure.vars = names(m_sub_names)[-c(1:8)]
  )
  
  assertthat::assert_that(nrow(m_melt_scores) == nrow(m_melt_names))
  
  m_long <- m_melt_scores
  
  m_long$goal_name <- m_melt_names$value
  
  assertthat::assert_that(nrow(m_long) == nrow(m_melt_names))
  
  m_long_2 <- dplyr::filter(m_long, !is.na(goal_name)) %>%
    dplyr::filter(!is.na(value))
  
  assertthat::assert_that(nrow(m_long) >= nrow(m_long_2))  
  
  m_plot <- m_long_2 %>% 
    dplyr::mutate(rank = rank(testritscore, ties.method = "first")) %>%
    dplyr::group_by(schoolname, grade, measurementscale) %>%
    dplyr::mutate(
      student_display_name = factor(
        studentfirstlast, 
        levels = unique(studentfirstlast)[order(rank,decreasing = TRUE)])  
    )
  
  p <- ggplot(
    data = m_plot, 
    aes(
      y = goal_name, 
      x = value
    )
  ) +
  geom_point(
    aes(fill = value - testritscore), 
    shape = 21,
    color = NA
  ) + 
  geom_vline(
    aes(xintercept = mean(testritscore)), 
    color = "gray"
  ) + 
  geom_vline(
    aes(
      xintercept = testritscore, 
      color = testquartile
    ), 
    size = 1.5, 
    show.legend = T
  ) + 
  scale_fill_gradient(
    "Deviation from\nOverall RIT",
    low = "red", 
    high = "green"
  ) +
  scale_color_discrete("Overall RIT Score\nQuartile") +
  xlab("RIT Score") + 
  ylab("Strand Name") +
  facet_grid(student_display_name ~ .) + 
  theme_bw() +
  theme(
    strip.text.y = element_text(angle = 0), 
    axis.text.y = element_text(size = 5)
  )
  
  # return
  p
}
