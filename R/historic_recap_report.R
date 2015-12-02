#' Historic Recap Report
#'
#' @description looks back across multiple cohorts.  
#' summarizes growth and and attainment
#' 
#' @param mapvizieR_obj conforming mapvizieR object
#' @param studentids vector of studentids
#' @param measurementscale target subject
#' @param target_percentile integer, what is the 'goal' percentile to show
#' progress against?
#' @param first_and_spring_only logical, should we drop fall and winter 
#' scores?
#' @param entry_grade_seasons numeric vector, what are 'entry' grades to the school?
#' @param small_n_cutoff numeric, drop observations that are smaller than X% of the
#' cohort maximum.
#' @param min_cohort_size integer, filter out cohorts with less than this many students
#' in them.
#' @param title_text report title
#'
#' @return grob, with plots arranged
#' @export

historic_recap_report <- function(
  mapvizieR_obj,
  studentids,
  measurementscale,
  target_percentile = 75,
  first_and_spring_only = TRUE,
  entry_grade_seasons = c(-0.8, 4.2),
  small_n_cutoff = 0.2,
  min_cohort_size = -1,
  title_text = ''
) {
 
  p_75 <- historic_nth_percentile_plot(  
    mapvizieR_obj = mapvizieR_obj,
    studentids = studentids,
    measurementscale = measurementscale,
    target_percentile = target_percentile,
    first_and_spring_only = first_and_spring_only,
    entry_grade_seasons = entry_grade_seasons,
    small_n_cutoff = small_n_cutoff
  ) +
  labs(
    title = sprintf(
      'Percent at Target %%ile (%s), by Cohort', 
      target_percentile %>% toOrdinal::toOrdinal()
    )
  )
  
  p_cgp <- multi_cohort_cgp_hist_plot(
    mapvizieR_obj = mapvizieR_obj,
    studentids = studentids,
    measurementscale = measurementscale,
    first_and_spring_only = first_and_spring_only,
    entry_grade_seasons = entry_grade_seasons,
    small_n_cutoff = small_n_cutoff,
    min_cohort_size = min_cohort_size
  )
  
  t <- template_05(p_75, p_cgp)
  
  gridExtra::arrangeGrob(
    h_var(title_text, 36), t,
    nrow = 2, heights = c(1, 17)
  )
}


historic_recap_report_detail <- function(
    mapvizieR_obj, 
    studentids, 
    measurementscale,
    subgroup_cols = c('starting_quartile'),
    pretty_names = c('Starting Quartile'),
    magic_subgroups = FALSE,
    start_fws,
    start_year_offset,
    end_fws,
    end_academic_year,
    start_fws_prefer = NA,
    entry_grade_seasons = c(-0.8, 4.2),
    title_text = ''
) {
  end_academic_year <- as.integer(end_academic_year)
  
  if (length(start_fws) == 1) {
    inferred_start_fws <- start_fws
    inferred_start_academic_year <- end_academic_year + start_year_offset
  } else {
    auto_windows <- auto_growth_window(
      mapvizieR_obj = mapvizieR_obj,
      studentids = studentids,
      measurementscale = measurementscale,
      end_fws = end_fws, 
      end_academic_year = end_academic_year,
      candidate_start_fws = start_fws,
      candidate_year_offsets = start_year_offset,
      candidate_prefer = start_fws_prefer,
      window_tolerance = 0.66
    )
    inferred_start_fws <- auto_windows[[1]]
    inferred_start_academic_year <- auto_windows[[2]]
  }
  
  p1 <- h_var(title_text, 36)
  p2 <- quealy_subgroups(
    mapvizieR_obj = mapvizieR_obj, 
    studentids = studentids, 
    measurementscale = measurementscale,
    subgroup_cols = subgroup_cols,
    pretty_names = pretty_names,
    magic_subgroups = magic_subgroups,
    start_fws = start_fws,
    start_year_offset = start_year_offset,
    end_fws = end_fws,
    end_academic_year = end_academic_year,
    start_fws_prefer = start_fws_prefer
  )
  
  p3 <- schambach_figure(
    mapvizieR_obj = mapvizieR_obj,
    measurementscale_in = measurementscale,
    studentids_in = studentids,
    subgroup_cols = subgroup_cols,
    pretty_names = pretty_names,
    start_fws = inferred_start_fws, 
    start_academic_year = inferred_start_academic_year, 
    end_fws = end_fws, 
    end_academic_year = end_academic_year
  )
  
  p4 <- cgp_table(
    mapvizieR_obj = mapvizieR_obj, 
    studentids = studentids,
    measurementscale = measurementscale, 
    start_fws = inferred_start_fws, 
    start_academic_year = inferred_start_academic_year, 
    end_fws = end_fws, 
    end_academic_year = end_academic_year,
    big_font = 50,
    norms = 2015
  )
      
  
  p5 <- cohort_cgp_hist_plot(
    mapvizieR_obj = mapvizieR_obj,
    studentids = studentids,
    measurementscale = measurementscale,
    entry_grade_seasons = entry_grade_seasons
  ) +
  labs(title = 'Historic Cohort Growth Percentiles')
  
  mapvizieR_obj$cdf <- mapvizieR_obj$cdf %>%
    dplyr::filter(
      map_year_academic <= end_academic_year
    )
  p6 <- becca_plot(
    mapvizieR_obj = mapvizieR_obj,
    studentids = studentids,
    measurementscale = measurementscale,
    detail_academic_year = end_academic_year,
    entry_grade_seasons = entry_grade_seasons
  ) 
  
  template_06(p1, p2, p3, p4, p5, p6)
}