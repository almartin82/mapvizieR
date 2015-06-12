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
#' @param title_text what is this report called?
#' @param ... additional arguments
#' 
#' @return prints a ggplot object
#' 
#' @export

two_pager <- function(
  mapvizieR_obj, 
  studentids, 
  measurementscale, 
  start_fws, start_academic_year, 
  end_fws, end_academic_year, 
  detail_academic_year,
  national_data_frame = NA,
  title_text = '', 
  ...
) {
 
  minimal = rectGrob(gp = gpar(col = "white"))
  
  #P1 CHARTS -----------------------------------
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
  strand_boxes <- strand_boxes(
    mapvizieR_obj = mapvizieR_obj,
    studentids = studentids,
    measurementscale_in = measurementscale,
    fws = end_fws,
    academic_year = end_academic_year
  )
  
  #kipp_comparison
  if (is.na(national_data_frame)) {
    kipp_comp <- minimal
  } else {
    #data processing
    growth_df <- mv_limit_growth(mapvizieR_obj, studentids, measurementscale)
    #just desired terms
    this_growth <- growth_df %>%
      dplyr::filter(
        start_map_year_academic == start_academic_year,
        start_fallwinterspring == start_fws,
        end_map_year_academic == end_academic_year,
        end_fallwinterspring == end_fws
      )

    minimal_sch <- mapvizieR_obj[['roster']] %>%
      dplyr::filter(
        studentid %in% this_growth$studentid
      ) %>%
      dplyr::select(
        studentid, school
      )
    
    kipp_comp <- kipp_typ_growth_distro(
      nat_results_df = national_data_frame,
      measurementscale = measurementscale, 
      academic_year = 2013,
      grade_level = round(mean(this_growth$end_grade, na.rm = TRUE), 0),
      start_fws = start_fws,
      end_fws = end_fws,
      comparison_name = table(minimal_sch$school)[[1]],
      comparison_pct_typ_growth = mean(this_growth$met_typical_growth, na.rm = TRUE)
    )
  }
  
  
  #growth_status
  growth_status <- growth_status_scatter(
    mapvizieR_obj = mapvizieR_obj,
    studentids = studentids,
    measurementscale_in = measurementscale,
    fws = end_fws,
    academic_year = end_academic_year
  ) 

  
  #P2 CHARTS -----------------------------------
  haid_plot <- haid_plot(
    mapvizieR_obj = mapvizieR_obj,
    studentids = studentids,
    measurementscale = measurementscale,
    start_fws = start_fws,
    start_academic_year = start_academic_year,
    end_fws = end_fws,
    end_academic_year = end_academic_year
  )

  
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
  
  #page 1
  p1 <- arrangeGrob(
    ur, br,
    nrow = 2, heights = c(1,3)
  )
  
  #page 2
  p2 <- arrangeGrob(
    haid_plot
  )
  
  return(list(p1, p2))
}
