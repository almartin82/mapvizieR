#' @title sgp_histogram
#'
#' @description
#' \code{sgp_histogram} a simple visualization of the distribution of student SGPs.
#'
#' @param mapvizieR_obj mapvizieR object
#' @param studentids target students
#' @param measurementscale target subject
#' @param start_fws starting season
#' @param start_academic_year starting academic year
#' @param end_fws ending season
#' @param end_academic_year ending academic year
#' @param perf_breaks sgp_histogram will color the median growth percentile
#' green, yellow, or red.  where to break between colors?  default is 55 and 45.
#' 
#' @return returns a ggplot object
#' @export

sgp_histogram <- function (
    mapvizieR_obj,
    studentids,
    measurementscale,
    start_fws,
    start_academic_year,
    end_fws,
    end_academic_year,
    perf_breaks = c(45, 55)
  ) {
  
  #data validation and unpack
  mv_opening_checks(mapvizieR_obj, studentids, 1)

  #unpack the mapvizieR object and limit to desired students
  growth_df <- mv_limit_growth(mapvizieR_obj, studentids, measurementscale)

  #data processing
  #just desired terms
  this_growth <- growth_df %>%
    dplyr::filter(
      start_map_year_academic == start_academic_year,
      start_fallwinterspring == start_fws,
      end_map_year_academic == end_academic_year,
      end_fallwinterspring == end_fws
    )
  
  #need to be at least one row with valid data
  ensure_rows_in_df(this_growth[!is.na(this_growth$sgp), ]) 
  
  #helper
  bins <- c(0, seq(10, 90, by = 10), 100)
  bins_7 <- seq(0, 105, by = 7.5)

  #get the count by bin?
  simple_hist <- hist(this_growth$sgp * 100, breaks = bins, plot=FALSE)
  
  e <- new.env()

  e$chart_max <- max(simple_hist$counts) + 5
  #calculate median SGP
  e$med_sgp <- median(this_growth$sgp * 100, na.rm = TRUE)
  
  #plot
  p <- ggplot(
    data = this_growth
   ,environment = e
   ,aes(
      x = sgp * 100
    )
  ) +
  geom_text (
    data = NULL
   ,aes(
      x = 50
     ,y = .5 * chart_max
     ,label = round(med_sgp, 0)
     ,alpha = 0.7
    )
   ,environment = e
   ,size = 26
   ,color = if(e$med_sgp >= perf_breaks[1]) {
         'lightgreen'
       } else if (e$med_sgp >= perf_breaks[2]) {
         'orange'
       } else if (e$med_sgp < perf_breaks[3]) {
         'firebrick1'
       }
  ) +
  geom_histogram(
   ,binwidth = 7.5
   ,alpha = 0.85
   #'TEAM blue'
   #,color = '#0067AC'
   #,fill = '#0067AC'
   ,fill = 'gray60'
  ) +    
  #labels
   labs(
     x = 'Student Growth Percentile'
    ,y = 'Number of Students'
   ) +
   theme(    #zero out cetain formatting
     panel.background = element_blank()
    ,plot.background = element_blank()
    ,panel.grid.major = element_blank()
    ,panel.grid.minor = element_blank()
    ,legend.position="none"
   ) + 
  scale_x_continuous(
    breaks = bins
  ) 
    
  return(p)
}