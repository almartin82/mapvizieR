#' Creates lists of students names stacked by rank in each of a given 
#' MAP assessments goal strands
#'
#' @param mapvizier_obj a \code{\link{mapvizieR}} object
#' @param studentids a set of student ids to subset to
#' @param measurement_scale the subject to subest to
#' @param season the season to use
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
#'strands_list_plot(map_mv, 
#'                  ids$StudentID, 
#'                  "Mathematics", 
#'                  "Fall", 
#'                  2013)
#'}
strands_list_plot <- function(mapvizier_obj, 
                              studentids,
                              measurement_scale,
                              season,
                              year
                              ){
  
  if(!is.mapvizieR(mapvizier_obj)) stop("You need to use a proper mapvizieR object.  Your object isn't proper.")
  
  .data <- mapvizier_obj$cdf %>%
    dplyr::filter(measurementscale ==  measurement_scale,
                  fallwinterspring == season,
                  map_year_academic == year,
                  studentid %in% studentids) %>%
    dplyr::inner_join(mapvizier_obj$roster %>%
                 dplyr::filter(fallwinterspring == season,
                        map_year_academic == year) %>%
                   dplyr::select(-grade), 
               by = c("studentid", "termname"))
  
  m.sub.scores <- .data %>% 
    dplyr::select(studentid, 
                 studentfirstname,
                 studentlastname,
                 grade,
                 measurementscale,
                 testritscore,
                 consistent_percentile,
                 testquartile,
                 matches("(goal)[0-9]ritscore")
                 )
  
  
  
  m.sub.names<-.data %>% 
    dplyr::select(studentid, 
                  studentfirstname,
                  studentlastname,
                  grade,
                  measurementscale,
                  testritscore,
                  consistent_percentile,
                  testquartile,
                  matches("(goal)[0-9]name")
                  )
  
  # melt scores
  m.melt.scores <- reshape2::melt(m.sub.scores, 
                      id.vars = names(m.sub.scores)[1:8], 
                      measure.vars = names(m.sub.scores)[-c(1:8)]
  ) %>%
    dplyr::mutate(value=as.numeric(value))
  
  m.melt.names<-reshape2::melt(m.sub.names, 
                     id.vars=names(m.sub.names)[1:8],
                     measure.vars = names(m.sub.names)[-c(1:8)]
  )
  
  
  
  m.long <- m.melt.scores 
  m.long$goal_name<-m.melt.names$value
  

  
  m.long.2<-m.long %>% dplyr::filter(!is.na(goal_name))
  m.long.2<-m.long.2 %>% dplyr::filter(!is.na(value))
  
  
  m.plot<-m.long.2 %>% 
    dplyr::mutate(Rank = rank(testritscore, ties.method = "random")) %>% 
    dplyr::group_by(grade, measurementscale, goal_name) %>%
    dplyr::mutate(Rank2 = rank(value, ties.method = "random")) %>%
    dplyr::mutate(studentfullname = paste(studentfirstname, 
                                   studentlastname)
           ) %>%
    dplyr::filter(!is.na(goal_name)|is.na(value))
  
  x_max<-max(m.plot$value)+50
  x_min<-min(m.plot$value)
  
  p<-ggplot(data=m.plot, aes(y=Rank2, x=value)) +
    geom_point(aes(color=testquartile)) + 
    geom_text(aes(label=studentfullname, 
                  color=testquartile), hjust=-0.3, size=2) +
    #geom_hline(aes(yintercept=mean(TestRITScore))) + 
    scale_color_discrete("Overall MAP Quartile") +
    facet_grid(.~goal_name) + 
    xlim(x_min,x_max) +
    xlab("RIT Score") +
    ylab("") +
    theme_bw() + 
    theme(strip.text.y=element_text(angle=270), 
          legend.position="bottom")
  
  p
  
}