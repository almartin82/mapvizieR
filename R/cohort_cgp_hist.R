
foo_variables <- function() {
  
  testing_constants()
  mapvizieR_obj <- mapviz
  studentids <- studentids_normal_use
  measurementscale <- 'Mathematics'
  first_and_spring_only <- TRUE
  school_norms <- 2012
  primary_cohort_only <- TRUE
  entry_grade_seasons <- c(-0.8, 5.2)
  grouping <- 'implicit_cohort'
  
  cohort_cgp_hist_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    entry_grade_seasons = c(-0.8, 5.2)
  ) 
}
  
  
#' Show's a cohort's progress over time, in percentile space.
#'
#' @param mapvizieR_obj conforming mapvizieR obj
#' @param studentids vector of studentids
#' @param measurementscale target subject
#' @param match_method do we limit to matched students, and if so, how?
#' no matching = any student record in the studentids.
#' UNIMPLEMENTED METHODS / TODO
#' strict = only kids who appear in all terms
#' strict after imputation = impute first, then use stritc method
#' back one = look back one test term, and only include kids who can be matched
#' @param first_and_spring_only show all terms, or only entry & spring?  
#' default is TRUE.
#' @param school_norms c(2012, 2015).  what school norms to use?  default
#' is 2012.
#' @param primary_cohort_only will determine the most frequent cohort and limit to 
#' students in that cohort.  designed to handle discrepancies in grade/cohort
#' pattern caused by previous holdovers.  default is TRUE.  
#'
#' @return a ggplot object
#' @export

cohort_cgp_hist_plot <- function(
  mapvizieR_obj,
  studentids,
  measurementscale,
  match_method = 'no matching',
  first_and_spring_only = TRUE,
  entry_grade_seasons = c(-0.8, 4.2), 
  school_norms = 2015,
  primary_cohort_only = TRUE
) {

  mv_opening_checks(mapvizieR_obj, studentids, 1)
  this_cdf <- mv_limit_cdf(mapvizieR_obj, studentids, measurementscale)
  
  #put cohort onto cdf
  this_cdf <- roster_to_cdf(
    target_df = this_cdf,
    mapvizieR_obj = mapvizieR_obj,
    roster_cols = 'implicit_cohort'
  )
  
  #limit to primary cohort
  if (primary_cohort_only) {
    primary_cohort <- this_cdf$implicit_cohort %>% table() %>%
      names() %>% magrittr::extract(1)
  
    this_cdf <- this_cdf %>%
      dplyr::filter(
        implicit_cohort == primary_cohort
      )
  }
  
  #only valid seasons
  munge <- valid_grade_seasons(
    this_cdf, first_and_spring_only, entry_grade_seasons, 9999
  )
  
  as_cgp <- cdf_to_cgp(cdf = munge, grouping = 'implicit_cohort')
  
  print(as_cgp %>% as.data.frame())
  
  out <- ggplot(
    data = as_cgp,
    aes(
      x = start_grade_level_season,
      y = mean_npr,
      label = mean_npr %>% round(0)
    )
  ) +
  geom_point() +
  geom_text() +
  theme_bw() +
  theme(
    panel.grid = element_blank()
  )

  return(out)
}