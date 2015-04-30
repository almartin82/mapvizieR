#' @title Chris Haid's class/cohort progress visualization
#'
#' @description
#' 
#' @param mapvizieR_obj mapvizieR object
#' @param studentids target students
#' @param measurementscale target subject
#' @param start_fws starting season
#' @param start_academic_year starting academic year
#' @param end_fws ending season
#' @param end_academic_year ending academic year
#' @param p_arrow_colors vector of colors passed to ggplot.
#' @param p_arrow_tiers vector of colors passed to ggplot.
#' @param p_name_colors vector of colors passed to ggplot.
#' @param p_name_color_tiers vector of colors passed to ggplot.
#' @param p_quartile_colors vector of colors passed to ggplot.
#' @param p_name_size sets point size of student names.
#' @param p_alpha sets level fo transparency for goals. 
#' 
#' @return prints a ggplot object
#' 
#' @export

haid_plot <- function(
  mapvizieR_obj,
  studentids,
  measurementscale,
  start_fws,
  start_academic_year,
  end_fws,
  end_academic_year,
  sort_column = 'start_testritscore',
  #look and feel
  p_arrow_colors = c("tan4", "snow4", "gold", "red"),
  p_arrow_tiers = c("Positive", "Typical", "College Ready", "Negative"),
  p_name_colors = c("#f3716b", "#79ac41", "#1ebdc2", "#a57eb8"),
  p_name_color_tiers = c("1","2","3","4"),
  p_quartile_colors = c('#f3716b', '#79ac41', '#1ebdc2', '#a57eb8'),
  p_name_size = 3,
  p_alpha = 1
) {
  
  #data validation and unpack
  mv_opening_checks(mapvizieR_obj, studentids, 1)

  #unpack the mapvizieR object and limit to desired students
  growth_df <- mv_limit_growth(mapvizieR_obj, studentids, measurementscale)

  #data processing ----------------------------------------------------------
  #just desired terms
  this_growth <- growth_df %>%
    dplyr::filter(
      start_map_year_academic == start_academic_year,
      start_fallwinterspring == start_fws,
      end_map_year_academic == end_academic_year,
      end_fallwinterspring == end_fws
    )
  
  #make a psuedo-axis by ordering based on one variable
  this_growth$y_order <- rank(
    x = this_growth[ , sort_column]
    ,ties.method = "first"
    ,na.last = FALSE
  )
  
  #thematic stuff
  pointsize <- 3
  segsize <- 1
  annotate_size <- 5

  #base ggplot object
  p <- ggplot(
    data = this_growth
    ,aes(
      x = start_testritscore
     ,y = y_order
    )
  )

  #typical and college ready goal lines (want these behind segments)
  p <- p + 
  geom_point(
    aes(
      x = start_testritscore + typical_growth
    )
    ,size = pointsize - 0.5
    ,shape = '|'
    ,color = '#CFCCC1'
    ,alpha = p_alpha
  ) + 
  geom_point(
    aes(
      x = start_testritscore + accel_growth
    )
    ,size = pointsize - 0.5
    ,shape = '|'
    ,color = '#FEBC11'
    ,alpha = p_alpha
  )  

  return(p)  
}