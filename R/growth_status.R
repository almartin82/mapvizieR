#' @title growth status scatter
#'
#' @param mapvizieR_obj mapvizieR object
#' @param studentids target students
#' @param measurementscale_in target subject
#' @param start_fws starting season
#' @param start_academic_year starting academic year
#' @param end_fws ending season
#' @param end_academic_year ending academic year
#' 
#' @return prints a ggplot object
#' 
#' @export

growth_status_scatter <- function(
  mapvizieR_obj,
  studentids,
  measurementscale_in,
  fws,
  academic_year
) {

  #data
  goal_df <- mapvizieR_obj[['cdf']] %>%
    dplyr::filter(
      measurementscale == measurementscale_in & studentid %in% studentids
    ) %>%
    dplyr::filter(
      (map_year_academic == academic_year & fallwinterspring == fws) 
    )
  #add student name
  goal_df <- goal_df %>%
    dplyr::left_join(
      mapvizieR_obj[['roster']] %>%
        dplyr::select(
          studentid, studentfirstlast
        ),
      by = 'studentid'
    )
  
  annotation_df <- data.frame(
    lab_x = c(33/2, 50, 66 + 33/2, 33/2, 50, 66 + 33/2)
   ,lab_y = c(75, 75, 75, 25, 25, 25)
   ,lab_text = c(
     'Low Growth\nAbove Gr. Lev.', 'Avg Growth\nAbove Gr. Lev.',
     'High Growth\nAbove Gr. Lev.', 'Low Growth\nBelow Gr. Lev.',
     'Avg Growth\nBelow Gr. Lev.', 'High Growth\nBelow Gr. Lev.'
    )
  )
  
  #plot
  p <- ggplot(
     data = df,
     aes(
       x = sgp,
       y = end_testpercentile,
       label = studentfirstlast
     )
   ) +
   #I am definitely going to hell for this
   geom_point(
    alpha = 0 
   ) 
  
}


