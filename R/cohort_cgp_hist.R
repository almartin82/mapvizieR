#' Shows a cohort's progress over time, in percentile space.
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
#' @param entry_grade_seasons which grade_level_seasons are entry grades?
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
  this_cdf$cohort <- this_cdf$map_year_academic + 13 - this_cdf$grade

  #limit to primary cohort
  if (primary_cohort_only) {
    primary_cohort <- this_cdf$cohort %>%
      table() %>% sort() %>% names() %>% rev() %>% magrittr::extract(1)
  
    this_cdf <- this_cdf %>%
      dplyr::filter(
        cohort == primary_cohort
      )
  }
  
  #only valid seasons
  munge <- valid_grade_seasons(
    this_cdf, first_and_spring_only, entry_grade_seasons, 9999
  )
  
  as_cgp <- cdf_to_cgp(cdf = munge, grouping = 'cohort', norms = school_norms)
  
  as_cgp <- as_cgp %>%
    dplyr::mutate(
      x_cgp = c(start_grade_level_season, end_grade_level_season) %>% mean(),
      y_cgp = c(start_mean_npr, end_mean_npr) %>% mean()
    ) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      cgp_label = cgp %>% round(0),
      cgp_helper = cumsum(!is.na(cgp)),
      cgp_label = ifelse(
        !is.na(cgp_label) & cgp_helper == 1, paste0('CGP: ', cgp_label), cgp_label
      )
    )
  
  out <- ggplot(
    data = as_cgp,
    aes(
      x = start_grade_level_season,
      y = start_mean_npr,
      label = start_mean_rit %>% round(1)
    )
  ) +
  geom_point() +
  geom_text(
    aes(y = start_mean_npr - 2),
    vjust = 1
  ) +
  geom_line() +
  geom_text(
    aes(
      x = x_cgp, 
      y = y_cgp,
      label = cgp_label
    ),
    color = 'hotpink'
  ) +
  theme_bw() +
  theme(
    panel.grid = element_blank()
  ) +
  scale_y_continuous(
    limits = c(0, 100),
    breaks = seq(0, 100, 10)
  ) +
  scale_x_continuous(
    breaks = as_cgp$start_grade_level_season %>% unique(),
    labels = as_cgp$start_grade_level_season %>% 
      lapply(fall_spring_me) %>% unlist(),
    limits = c(
      as_cgp$start_grade_level_season %>% unique() %>% min() - .1,
      as_cgp$start_grade_level_season %>% unique() %>% max() + .1
    )
  ) +
  labs(
    x = 'Grade & Season',
    y = 'Average Percentile Rank'
  )

  return(out)
}