#' Shows a cohort's progress over time.  Similar to cohort_cgp_hist,
#' but uses the 2015 school grade level attainment/status norms.
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
#' @param primary_cohort_only will determine the most frequent cohort and limit to 
#' students in that cohort.  designed to handle discrepancies in grade/cohort
#' pattern caused by previous holdovers.  default is TRUE.  
#' @param small_n_cutoff any cohort below this percent will get filtered out.  
#' default is 0.5, eg cohorts under 0.5 of max size will get dropped.
#' @param no_labs if TRUE, will not label x or y axis
#' @param plot_labels c('RIT', 'NPR').  'RIT' is default.
#'
#' @return a ggplot object
#' @export

alt_cohort_cgp_hist_plot <- function(
  mapvizieR_obj,
  studentids,
  measurementscale,
  match_method = 'no matching',
  first_and_spring_only = TRUE,
  entry_grade_seasons = c(-0.8, 4.2), 
  primary_cohort_only = TRUE,
  small_n_cutoff = .5,
  no_labs = FALSE,
  plot_labels = 'RIT'
) {

  mv_opening_checks(mapvizieR_obj, studentids, 1)
  this_cdf <- mv_limit_cdf(mapvizieR_obj, studentids, measurementscale)
  this_cdf <- min_term_filter(this_cdf, small_n_cutoff) 
  
  #put cohort onto cdf
  if (!'cohort' %in% names(this_cdf) %>% any()) {
    this_cdf <- roster_to_cdf(this_cdf, mapvizieR_obj, 'implicit_cohort') %>%
      dplyr::rename(cohort = implicit_cohort)
  }
  
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

  as_cgp <- cdf_to_cgp(
    mapvizieR_obj = mapvizieR_obj,
    cdf = munge, 
    grouping = 'cohort', 
    norms = 2015
  )
  
  cohort_mean_rit_to_npr(
    measurementscale, 
    as_cgp[2, ]$start_grade, 
    as_cgp[2, ]$start_fallwinterspring,
    as_cgp[2, ]$start_mean_rit
  )
  
  as_cgp$start_cohort_status_npr <- NA_integer_
  as_cgp$end_cohort_status_npr <- NA_integer_
  
  for (i in 1:nrow(as_cgp)) {
    as_cgp[i, 'start_cohort_status_npr'] <- cohort_mean_rit_to_npr(
      measurementscale, 
      as_cgp[i, ]$start_grade, 
      as_cgp[i, ]$start_fallwinterspring,
      as_cgp[i, ]$start_mean_rit
    )
  
    as_cgp[i, 'end_cohort_status_npr'] <- cohort_mean_rit_to_npr(
      measurementscale, 
      as_cgp[i, ]$end_grade, 
      as_cgp[i, ]$end_fallwinterspring,
      as_cgp[i, ]$end_mean_rit
    )
  }
  
  as_cgp <- as_cgp %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      x_cgp = c(start_grade_level_season, end_grade_level_season) %>% mean(),
      y_cgp = c(start_cohort_status_npr, end_cohort_status_npr) %>% mean()
    ) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      cgp_label = cgp %>% round(0),
      cgp_helper = cumsum(!is.na(cgp)),
      cgp_label = ifelse(
        !is.na(cgp_label) & cgp_helper == 1, paste0('CGP: ', cgp_label), cgp_label
      )
    ) %>%
    as.data.frame(stringsAsFactors = FALSE)
  
  as_cgp$label1_text <- NA
  as_cgp$label2_text <- NA
  
  if(plot_labels == 'RIT') {
    as_cgp$label1_text <- as_cgp$start_mean_rit %>% round(1)
    as_cgp$label2_text <- as_cgp$end_mean_rit %>% round(1)
  }

  if(plot_labels == 'NPR') {
    as_cgp$label1_text <- as_cgp$start_cohort_status_npr
    as_cgp$label2_text <- as_cgp$end_cohort_status_npr
  }
  
  out <- ggplot(
    data = as_cgp,
    aes(
      x = start_grade_level_season,
      y = start_cohort_status_npr
    )
  ) +
  geom_point(
    aes(
      x = start_grade_level_season,
      y = start_cohort_status_npr
    ),
    shape = 1
  ) +
  geom_point(
    aes(
      x = end_grade_level_season,
      y = end_cohort_status_npr
    ),
    shape = 1
  ) +
  geom_text(
    aes(
      y = start_cohort_status_npr - 1,
      label = label1_text
    ),
    alpha = 0.5,
    vjust = 1,
    color = 'lightblue'
  ) +
  geom_text(
    aes(
      x = end_grade_level_season,
      y = end_cohort_status_npr + 1,
      label = label2_text
    ),
    alpha = 0.5,
    vjust = 0,
    color = 'darkblue'
  ) +    
  geom_segment(
    aes(
      xend = end_grade_level_season,
      yend = end_cohort_status_npr
    )
  ) 
  
  #only out geom text on plot if it exists
  if (as_cgp$cgp %>% is.na() %>% `n'est pas`() %>% any) {
    out <- out +   
      geom_text(
      aes(
        x = x_cgp, 
        y = y_cgp,
        label = cgp_label
      ),
      color = 'hotpink'
    ) 
  }
  
  out <- out +
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
  ) 
  
  if (!no_labs) {
    out <- out +
      labs(
        x = 'Grade & Season',
        y = 'Grade/Cohort Status Percentile'
      )
  } else {
    out <- out +
      theme(
        axis.title = element_blank()
      )
  }

  return(out)
}






#' Multiple Cohort CGP histories
#'
#' @description see cohort_cgp_hist_plot for use.  Pass a vector of studentids
#' of *all* desired cohorts.  Plot will facet one plot per cohort.
#' 
#' @inheritParams cohort_cgp_hist_plot
#' @param min_cohort_size filter cohorts with less than this many students.
#' useful when weird enrollment patterns exist in your data.
#' @param plot_labels c('RIT', 'NPR').  'RIT' is default.
#' @param facet_dir c('wide', 'long') facet the cohorts the wide way or the long way
#' 
#' @return a list of ggplotGrobs
#' @export

alt_multi_cohort_cgp_hist_plot <- function(
  mapvizieR_obj,
  studentids,
  measurementscale,
  match_method = 'no matching',
  first_and_spring_only = TRUE,
  entry_grade_seasons = c(-0.8, 4.2), 
  small_n_cutoff = .5,
  min_cohort_size = -1,
  plot_labels = 'RIT',
  facet_dir = 'wide'
) {
  
  mv_opening_checks(mapvizieR_obj, studentids, 1)
  this_cdf <- mv_limit_cdf(mapvizieR_obj, studentids, measurementscale)

  #put cohort onto cdf
  if (!'cohort' %in% names(this_cdf) %>% any()) {
    this_cdf <- roster_to_cdf(this_cdf, mapvizieR_obj, 'implicit_cohort') %>%
      dplyr::rename(cohort = implicit_cohort)
  }
  
  #only valid seasons
  munge <- valid_grade_seasons(
    this_cdf, first_and_spring_only, entry_grade_seasons, 9999
  )
  
  as_cgp <- cdf_to_cgp(
    mapvizieR_obj, cdf = munge, grouping = 'cohort', norms = 2015
  )
  
  #min size
  as_cgp <- as_cgp %>%
    dplyr::filter(
      n > min_cohort_size
    )

  as_cgp$start_cohort_status_npr <- NA_integer_
  as_cgp$end_cohort_status_npr <- NA_integer_
  
  for (i in 1:nrow(as_cgp)) {
    as_cgp[i, 'start_cohort_status_npr'] <- cohort_mean_rit_to_npr(
      measurementscale, 
      as_cgp[i, ]$start_grade, 
      as_cgp[i, ]$start_fallwinterspring,
      as_cgp[i, ]$start_mean_rit
    )
    
    as_cgp[i, 'end_cohort_status_npr'] <- cohort_mean_rit_to_npr(
      measurementscale, 
      as_cgp[i, ]$end_grade, 
      as_cgp[i, ]$end_fallwinterspring,
      as_cgp[i, ]$end_mean_rit
    )
  }
  
  as_cgp <- as_cgp %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      x_cgp = c(start_grade_level_season, end_grade_level_season) %>% mean(),
      y_cgp = c(start_cohort_status_npr, end_cohort_status_npr) %>% mean()
    ) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      cgp_label = cgp %>% round(0),
      cgp_helper = cumsum(!is.na(cgp)),
      cgp_label = ifelse(
        !is.na(cgp_label) & cgp_helper == 1, paste0('CGP: ', cgp_label), cgp_label
      )
    )
  
  as_cgp$label1_text <- NA
  as_cgp$label2_text <- NA
  
  if(plot_labels == 'RIT') {
    as_cgp$label1_text <- as_cgp$start_mean_rit %>% round(1)
    as_cgp$label2_text <- as_cgp$end_mean_rit %>% round(1)
  }
  
  if(plot_labels == 'NPR') {
    as_cgp$label1_text <- as_cgp$start_cohort_status_npr
    as_cgp$label2_text <- as_cgp$end_cohort_status_npr
  }
  
  out <- ggplot(
    data = as_cgp,
    aes(
      x = start_grade_level_season,
      y = start_cohort_status_npr,
      group = cohort
    )
  ) +
  geom_point() +
  geom_text(
    aes(
      y = start_cohort_status_npr - 1,
      label = label1_text
    ),
    alpha = 0.5,
    vjust = 1,
    color = 'lightblue'
  ) +
  geom_text(
    aes(
      x = end_grade_level_season,
      y = end_cohort_status_npr + 1,
      label = label2_text
    ),
    alpha = 0.5,
    vjust = 0,
    color = 'darkblue'
  ) +    
  geom_line()
  
  if (facet_dir == 'wide') {
    out <- out + facet_grid(. ~ cohort) 
  }
  if (facet_dir == 'long') {
    out <- out + facet_grid(cohort ~ .)
  }
  
  #only out geom text on plot if it exists
  if (as_cgp$cgp %>% is.na() %>% `n'est pas`() %>% any) {
    out <- out +   
      geom_text(
        data = as_cgp %>% dplyr::filter(!is.na(cgp)),
        aes(
          x = x_cgp, 
          y = y_cgp,
          label = cgp_label,
          group = cohort
        ),
        color = 'hotpink'
      ) 
  }
  
  out <- out +
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
      labels = as_cgp$start_grade_level_season %>% unique() %>%
        lapply(fall_spring_me) %>% unlist(),
      limits = c(
        as_cgp$start_grade_level_season %>% unique() %>% min() - .1,
        as_cgp$start_grade_level_season %>% unique() %>% max() + .1
      )
    ) +
    labs(
      x = 'Grade & Season',
      y = 'Grade/Cohort Status Percentile'
    )

  return(out)
}
