#' @title MAP two-pager 
#'
#' @param mapvizieR_obj mapvizieR object
#' @param studentids target students
#' @param measurementscale target subject
#' @param detail_academic_year don't mask any data for this academic year
#' @param start_fws starting season
#' @param start_academic_year starting academic year
#' @param end_fws ending season
#' @param end_academic_year ending academic year
#' @param detail_academic_year don't mask any data for this academic year
#' @param title_text what is this report called?
#' @param ... additional arguments
#' 
#' @return prints a ggplot object
#' 
#' @export

two_pager <- function(
  mapvizieR_obj, studentids, measurementscale, 
  start_fws, start_academic_year, end_fws, end_academic_year, detail_academic_year,
  title_text = '', 
  ...
) {
 
  minimal = rectGrob(gp=gpar(col="white"))
  
  #CHARTS -----------------------------------
  #title
  title_bar <- h_var(title_text, 24)

  #cgp_table
  three_key <- cgp_table(
    mapvizieR_obj = mapvizieR_obj,
    studentids = studentids,
    measurementscale = measurementscale,
    start_fws = start_fws,
    start_academic_year = start_academic_year,
    end_fws = end_fws,
    end_academic_year = end_academic_year
  )  

  
  #elephants
  ele <- galloping_elephants(
    mapvizieR_obj = mapvizieR_obj, 
    studentids = studentids, 
    measurementscale = measurementscale
  ) +
  labs(
    title = 'Cohort RIT Distribution, Longitudinal Data'
  )

  #histogram
  sgp <- sgp_histogram(
    mapvizieR_obj = mapvizieR_obj,
    studentids = studentids,
    measurementscale = measurementscale,
    start_fws = start_fws,
    start_academic_year = start_academic_year,
    end_fws = end_fws,
    end_academic_year = end_academic_year
  ) +
  labs(
    title = 'SGP Distribution'
  )
  
  #becca
  becca <- becca_plot(
    mapvizieR_obj = mapvizieR_obj, 
    studentids = studentids,
    measurementscale = measurementscale,
    detail_academic_year = detail_academic_year
  )

  #strand boxplots
  strand_boxes <- minimal
  
  #kipp_comparison
  kipp_comp <- minimal
  
  #growth_status
  growth_status <- minimal
  
  #LAYOUT -----------------------------------
  #upper left
  ul <- gridExtra::arrangeGrob(
    title_bar, three_key,
    nrow = 2, heights = c(1, 5)
  )
  #upper row
  ur <- gridExtra::arrangeGrob(
    ul, ele, ncol = 2, widths = c(2, 3)
  )
  
  #bottom left, top
  blt <- gridExtra::arrangeGrob(
    sgp, becca, ncol = 2
  )
  
  
  #bottom left, bottom
  blb <- gridExtra::arrangeGrob(
    strand_boxes, kipp_comp, ncol = 2
  )
  
  #bottom left, combined
  bl <- gridExtra::arrangeGrob(
    blt, blb, nrow = 2
  )
  
  #bottom row
  br <- gridExtra::arrangeGrob(
    bl, growth_status, ncol = 2, widths = c(2, 3)
  )
    
  arrangeGrob(
    ur, br,
    nrow = 2, heights = c(1,3)
  )
}
