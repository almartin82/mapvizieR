#' Cohort Status Trace Plot
#'
#' @inheritParams cohort_rit_trace_plot
#' @param plot_labels c('RIT', 'NPR').  'RIT' is default.
#'
#' @return a ggplot object
#' @export

cohort_status_trace_plot <- function(
  mapvizieR_obj,
  studentids,
  measurementscale,
  match_method = 'no matching',
  first_and_spring_only = TRUE,
  entry_grade_seasons = c(-0.8, 4.2),
  collapse_schools = TRUE,
  retention_strategy = 'collapse',
  small_n_cutoff = -1,
  plot_labels = 'RIT'
) {

  #opening parameter checks
  valid_retention <- c('collapse', 'filter_small')
  if (!(retention_strategy %in% valid_retention)) {
    cli::cli_abort(paste0("retention_strategy should be either one of: ", paste(valid_retention, collapse = ', ')))
  }

  #mv consistency checks
  mv_opening_checks(mapvizieR_obj, studentids, 1)
  
  #limit
  this_cdf <- mv_limit_cdf(mapvizieR_obj, studentids, measurementscale)
  
  #prep the internal cdf for summary().  zero out map_year_academic and termname to prevent retained students from showing 
  #as unique terms
  if (retention_strategy == 'collapse') {
    this_cdf <- cdf_collapse_by_grade(this_cdf)
  } 
  
  #summary groups by school.  if you want transfers in prior years to show as one unit, you want to collapse schools.
  if (collapse_schools) {
    # Preserve classes through assignment
    old_classes <- class(this_cdf)
    this_cdf$schoolname <- table(this_cdf$schoolname) %>% sort(decreasing = TRUE) %>% names() %>% magrittr::extract(1)
    class(this_cdf) <- old_classes
  }

  #cdf summary
  this_sum <- summary(this_cdf)

  if (retention_strategy == 'filter_small') {
    this_sum <- this_sum[this_sum$n_students >= small_n_cutoff * max(this_sum$n_students), ]
  }

  if(plot_labels == 'RIT') {
    this_sum$label_text <- this_sum$mean_testritscore %>% round(1)
  }
  
  if(plot_labels == 'NPR') {
    this_sum$label_text <- this_sum$cohort_status_npr %>% round(1)
  }
  
  
  p <- ggplot(
    data = this_sum,
    aes(
      x = grade_level_season,
      y = cohort_status_npr,
      label = label_text,
      color = schoolname
    )
  ) +
  geom_line() +
  geom_point(
    size = 8,
    shape = 16,
    color = 'white'
  ) +
  geom_text()
  
  p <- p +
  theme_bw() +
  theme(
    panel.grid = element_blank()
  ) +
  scale_y_continuous(
    limits = c(0, 100),
    breaks = seq(0, 100, 10)
  ) +
  scale_x_continuous(
    breaks = this_sum$grade_level_season %>% unique(),
    labels = this_sum$grade_level_season %>% unique() %>%
      lapply(fall_spring_me) %>% unlist(),
    limits = c(
      this_sum$grade_level_season %>% unique() %>% min() - .1,
      this_sum$grade_level_season %>% unique() %>% max() + .1
    )
  ) 
  
  p <- p +
  labs(
    x = 'Grade & Season',
    y = 'Grade/Cohort Status Percentile'
  )

  if (collapse_schools) {
    p <- p + theme(legend.position = 'none')
  }
  
  p  
  
}



#' Cohort RIT trace plot

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
#' @param collapse_schools treats all students as part of the same 'school' for purposes of plotting, so that one trajectory is shown.
#' default is TRUE.  if FALSE will separate lines by school and show a lengend.
#' @param small_n_cutoff numeric, drop observations that are smaller than X% of the
#' cohort maximum.
#' @param retention_strategy c('collapse', 'filter_small') retained students show up as cohorts of 1 student.  
#' collapse will run `collapse_by_grade` to merge those students into existing cohorts.  `filter_small` will drop
#' them from this visualization. 
#'
#' @return a ggplot2 object
#' @export

cohort_rit_trace_plot <- function(
  mapvizieR_obj,
  studentids,
  measurementscale,
  match_method = 'no matching',
  first_and_spring_only = TRUE,
  entry_grade_seasons = c(-0.8, 4.2),
  collapse_schools = TRUE,
  retention_strategy = 'collapse',
  small_n_cutoff = -1
) {
  #opening parameter checks
  valid_retention <- c('collapse', 'filter_small')
  if (!(retention_strategy %in% valid_retention)) {
    cli::cli_abort(paste0("retention_strategy should be either one of: ", paste(valid_retention, collapse = ', ')))
  }

  #mv consistency checks
  mv_opening_checks(mapvizieR_obj, studentids, 1)
  
  #limit
  this_cdf <- mv_limit_cdf(mapvizieR_obj, studentids, measurementscale)
  
  #prep the internal cdf for summary().  zero out map_year_academic and termname to prevent retained students from showing 
  #as unique terms
  if (retention_strategy == 'collapse') {
    this_cdf <- cdf_collapse_by_grade(this_cdf)
  } 
  
  #summary groups by school.  if you want transfers in prior years to show as one unit, you want to collapse schools.
  if (collapse_schools) {
    # Preserve classes through assignment
    old_classes <- class(this_cdf)
    this_cdf$schoolname <- table(this_cdf$schoolname) %>% sort(decreasing = TRUE) %>% names() %>% magrittr::extract(1)
    class(this_cdf) <- old_classes
  }

  #cdf summary
  this_sum <- summary(this_cdf)
  
  if (retention_strategy == 'filter_small') {
    this_sum <- this_sum[this_sum$n_students >= small_n_cutoff * max(this_sum$n_students), ]
  }
  
  empty_norms <- empty_norm_grade_space(
    measurementscale = measurementscale,
    trace_lines = c(1, 5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 95, 99),
    norms = 2015,
    spring_only = TRUE,
    school = TRUE
  )
  
  p <- empty_norms +
    geom_line(
      data = this_sum,
      aes(
        x = grade_level_season,
        y = mean_testritscore,
        color = schoolname
      )
    ) +
    geom_point(
      data = this_sum,
      aes(
        x = grade_level_season,
        y = mean_testritscore
      ),
      size = 8,
      shape = 16,
      color = 'white'
    ) +
    geom_text(
      data = this_sum,
      aes(
        x = grade_level_season,
        y = mean_testritscore,
        label = round(mean_testritscore, 0),
        color = schoolname
      )
    ) +
    scale_x_continuous(
      breaks = this_sum$grade_level_season %>% unique(),
      labels = this_sum$grade_level_season %>% unique() %>%
        lapply(fall_spring_me) %>% unlist()
    ) +
    coord_cartesian(
      xlim = c(
        this_sum$grade_level_season %>% unique() %>% min() - .1,
        this_sum$grade_level_season %>% unique() %>% max() + .1
      ),
      ylim =  c(
        this_sum$mean_testritscore %>% min %>% round_to_any(., 5, f = floor),
        this_sum$mean_testritscore %>% max %>% round_to_any(., 5, f = ceiling)
      )
    )
    
  p <- p +
    labs(
      x = 'Grade & Season',
      y = 'Mean RIT Score'
    )
  
  if (collapse_schools) {
    p <- p + theme(legend.position = 'none')
  }
  
  p
}