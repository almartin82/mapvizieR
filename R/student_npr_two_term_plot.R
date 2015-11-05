#' A small multiples plot of a set of students' national percentile rank over two terms.
#'
#' @param mapvizieR_obj a \code{\link{mapvizieR}} object
#' @param studentids a set of student ids to subset to
#' @param measurement_scale a MAP measurementscale
#' @param term_first the first test term. You need to use the full name, such
#' as 'Spring 2012-2013'
#' @param term_second the second test term. You need to use the full name, such
#' as 'Fall 2013-2014'
#' @param n_col number of columns to display in the plot
#' @param min_n minimum number of students required to produce the plot. 
#'
#' @return a ggplot object
#' @export
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
#' student_npr_two_term_plot(
#'   map_mv,
#'   studentids = ids[1:80, "StudentID"],
#'   measurement_scale ="Reading", 
#'   term_first = "Spring 2012-2013", 
#'   term_second = "Fall 2013-2014", 
#'   n_col = 7, 
#'   min_n = 5)
#'}
student_npr_two_term_plot <- function(mapvizieR_obj,
                                      studentids,
                                      measurement_scale = "Reading",
                                      term_first, 
                                      term_second, 
                                      n_col=9, 
                                      min_n=10) {
  
  if (! is.mapvizieR(mapvizieR_obj)){
    stop("The object you passed is not a conforming mapvizieR object")
  } 
  
  .data <- mapvizieR_obj$cdf

  .data <- .data %>%
    dplyr::filter(termname %in% c(term_first, term_second), 
                  studentid %in% studentids,
                  measurementscale == measurement_scale
                  ) %>%
    dplyr::mutate(termname = factor(as.character(termname), 
                                  levels = c(term_first, term_second)
                                  )
                  ) %>%
    dplyr::inner_join(mapvizieR_obj$roster,
                      by = c("studentid",
                             "termname",
                             "fallwinterspring",
                             "map_year_academic",
                             "grade"))
  
  .data_joined <- 
    dplyr::inner_join(dplyr::filter(.data, termname == term_first), 
                      dplyr::filter(.data, termname == term_second),
                      by = c("studentid", "measurementscale")
                      )  %>%
    dplyr::mutate(
           diff_pctl = consistent_percentile.y-consistent_percentile.x,
           diff_bool = diff_pctl >= 0,
           diff_rit =  testritscore.y-testritscore.x,
           diff_rit_se = sqrt(teststandarderror.y^2 + teststandarderror.x^2),
           diff_rit_bool = (0 >= -2 * diff_rit_se + diff_rit) & 
                              (0 <= 2 * diff_rit_se + diff_rit),
           diff_rit_neg_pos = ifelse(diff_rit_bool == FALSE & 
                                       diff_rit > 0, 
                                     "Positive",
                                     ifelse(diff_rit_bool == FALSE & 
                                              diff_rit < 0, 
                                            "Negative", 
                                            "Zero"
                                            )
                                     ),
           diff_rit_neg_pos = factor(diff_rit_neg_pos, 
                                     levels=c("Zero", 
                                              "Negative", 
                                              "Positive"
                                              )
                                     ),
           studentname=paste(studentfirstname.x,
                             studentlastname.x),
           name=factor(studentname, levels=unique(studentname)[order(-diff_pctl)])
    )
  
  if (nrow(.data_joined) < min_n) {
    return(message(paste("Returning without generating plot:\n",
                         "Number of students is fewer than",
                         min_n
                         )
                   )
           )
  }
  
  
  .data_joined_2 <- .data_joined %>%
    dplyr::select(-name)
  

  
  #format terms
  t1<-gsub("(.+)\\s(.+)", "\\1\n\\2", term_first)
  t2<-gsub("(.+)\\s(.+)", "\\1\n\\2", term_second)
  p<-ggplot(.data_joined, 
            aes(x=0,
                y=consistent_percentile.x)
  ) + 
    geom_segment(data=.data_joined_2, 
                 aes(xend=1,
                     yend=consistent_percentile.y,
                     group=studentid
                 ), 
                 alpha=.1) +
    geom_segment(aes(xend=1,
                     yend=consistent_percentile.y,
                     group=studentid,,
                     color=diff_rit_neg_pos), 
                 size=2) +
    scale_x_continuous(name="Test Term", breaks=c(0, 1), labels=c(t1,t2)) +
    scale_color_manual("RIT Difference\nis statistically:",values = c('#439539', #green
                                                                      '#F7941E', # Orange
                                                                      "purple"
                                                                      # True 
    )
    ) +
    facet_wrap(~name,ncol = n_col) + 
    theme_bw() + 
    theme(axis.text.x=element_text(hjust=c(0,1))) +
    ylab("Test Percentile")
  
  p
  
  
  
}
  
