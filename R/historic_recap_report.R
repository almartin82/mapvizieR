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
    start_fws_prefer = NA
) {
  
  p1 <- quealy_subgroups(
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
  p2 <- textGrob('quealy')
  p3 <- textGrob('cgp table')
  p4 <- textGrob('schambach')
  p5 <- textGrob('becca')

  template_06(p1, p2, p3, p4, p5)
}