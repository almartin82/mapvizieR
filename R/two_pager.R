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
#' @param national_data_frame for internal KIPP use - a data frame showing % making
#' typ growth across KIPP
#' @param title_text what is this report called?
#' @param entry_grade_seasons for becca plot.  default is c(-0.8, 4.2)
#' @param ... additional arguments
#' 
#' @return a list of grid graphics objects
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
  entry_grade_seasons = c(-0.8, 4.2),
  ...
) {
 
  minimal = grid::rectGrob(gp = grid::gpar(col = "white"))
  
  #P1 CHARTS -----------------------------------
  #title
  title_bar <- h_var(title_text, 20)

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
  growth_hist <- growth_histogram(
    mapvizieR_obj = mapvizieR_obj,
    studentids = studentids,
    measurementscale = measurementscale,
    start_fws = start_fws,
    start_academic_year = start_academic_year,
    end_fws = end_fws,
    end_academic_year = end_academic_year
  ) +
  labs(
    title = 'Growth Percentile\nDistribution'
  )
  
  #becca
  becca <- becca_plot(
    mapvizieR_obj = mapvizieR_obj, 
    studentids = studentids,
    measurementscale = measurementscale,
    detail_academic_year = detail_academic_year,
    entry_grade_seasons = entry_grade_seasons
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
  kipp_comp <- minimal
  
  if (class(national_data_frame) == 'data.frame') {
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
        studentid, schoolname
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
    start_fws = start_fws,
    start_academic_year = start_academic_year,
    end_fws = end_fws,
    end_academic_year = end_academic_year
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
    nrow = 2, heights = c(1, 4)
  )
  #upper row
  ur <- gridExtra::arrangeGrob(
    ul, ele, ncol = 2, widths = c(2, 3)
  )
  
  #bottom left, top
  blt <- gridExtra::arrangeGrob(
    growth_hist, becca, ncol = 2
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
  p1 <-arrangeGrob(
    ur, br,
    nrow = 2, heights = c(1,3)
  )
  
  #page 2
  p2 <- arrangeGrob(
    haid_plot
  )
  
  out <- list(p1, p2)
  
  out
}



#' @title two-pager, KNJ style
#' 
#' @description similar to the existing two pager, but attempts to auto-set fall-spring vs 
#' spring/spring
#'
#' @param mapvizieR_obj mapvizieR object
#' @param studentids target students
#' @param measurementscale target subject
#' @param end_fws ending season
#' @param end_academic_year ending academic year
#' @param detail_academic_year don't mask any data for this academic year
#' @param candidate_start_fws what possible start terms should we consider?
#' @param start_year_offsets using same order as candidate_start_fws, if we pick this year, what should we add
#' to the end_academic_year to get the right year's data?  eg, -1 for spring/spring.
#' @param prefer_fws what is the 'best' start term?
#' @param national_data_frame for internal KIPP use - a data frame showing % making
#' typ growth across KIPP
#' @param title_text what is this report called?
#' @param ... additional arguments
#' 
#' @return a ggplot object
#' 
#' @export

knj_two_pager <- function(
  mapvizieR_obj, 
  studentids, 
  measurementscale, 
  end_fws, 
  end_academic_year,
  detail_academic_year,
  candidate_start_fws = c('Fall', 'Spring'),
  start_year_offsets = c(0, -1),
  prefer_fws = 'Spring',
  national_data_frame = NA,
  title_text = '', 
  ...
) {

  #NSE problems... :(
  measurementscale_in <- measurementscale
  
  this_growth <- mapvizieR_obj[['growth_df']] %>%
    dplyr::filter(
      studentid %in% studentids & 
        end_map_year_academic == end_academic_year &
        end_fallwinterspring == end_fws &
        start_fallwinterspring %in% candidate_start_fws &
        measurementscale == measurementscale_in &
        complete_obsv == TRUE
    )

  exists_test <- prefer_fws %in% unique(this_growth$start_fallwinterspring)
  coverage_test <- sum(this_growth$start_fallwinterspring == prefer_fws) / length(unique(this_growth$studentid))
  
  if (all(exists_test & coverage_test > 0.5)) {
    inferred_start_fws <- prefer_fws
    inferred_start_academic_year <- end_academic_year + start_year_offsets[candidate_start_fws == prefer_fws]
  } else {
    inferred_start_fws <- candidate_start_fws[candidate_start_fws != prefer_fws]
    inferred_start_academic_year <- end_academic_year + start_year_offsets[candidate_start_fws != prefer_fws]
  }
   
  #hand that to two-pager
  p <- two_pager(
    mapvizieR_obj = mapvizieR_obj, 
    studentids = studentids, 
    measurementscale = measurementscale, 
    start_fws = inferred_start_fws, 
    start_academic_year = inferred_start_academic_year, 
    end_fws = end_fws, 
    end_academic_year = end_academic_year, 
    detail_academic_year = detail_academic_year,
    national_data_frame = national_data_frame,
    title_text = title_text,
    entry_grade_seasons = 'detect',
    ... = ...
  ) 
  
  return(p)
}