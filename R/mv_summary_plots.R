#' @title Plots mapvizieR summary object metrics longitudinally
#'
#'
#' @description Plots a grade-level metrics longitudinally
#'
#' @details Creates and prints a ggplot2 object showing line graphs of school-level 
#' metrics by grade or cohort and  and by subject over time
#' 
#' @param mapvizieR_summary a \code{mapvizieR_summary} summary object.
#' @param growth_window growth window to plot as character vector: "Fall to Spring", "Spring to Spring", etc.
#' @param by character vector of whether to plot "grade" or "cohort" longitudinally
#' @param metric which column from `mapviier_summary` to plot longitudinally
#' @param school_col character vector specifying column name with schools' names.  Defaults to `end_schoolname`
#' @param n_cutoff (default is 15), floor below which a growth calculation is ignored
#' 
#' @return a `ggplot` object.
#' @examples 
#' \dontrun{
#' require(dplyr)
#' 
#' data("ex_CombinedStudentsBySchool")
#' data("ex_CombinedAssessmentResults")
#'
#' map_mv <- mapvizieR(ex_CombinedAssessmentResults, ex_CombinedStudentsBySchool)
#' 
#' mv_summary <- summary(map_mv)
#' 
#' summary_long_plot(mv_summary, metric = "pct_typical", 
#' growth_window = "Fall to Spring")
#'}

#'@export

summary_long_plot <- function(
  mapvizieR_summary,
  growth_window = c("Fall to Spring"),
  by = "grade",
  metric = "pct_typical",
  school_col = "end_schoolname",
  n_cutoff = 30
  ) {
  
  # NSE problems
  growth_window_in <- growth_window
  
  # data validation and unpack
  if(!inherits(mapvizieR_summary, "mapvizieR_summary")) {
    x <- substitute(mapvizieR_summary)
    warning(
      sprintf(
        "%s must be a mapvizier_summary object. Try running summary(%s) first.",
        as.character(x), as.character(x)
        )
    )
  }
  
  if(!metric %in% names(mapvizieR_summary)){
    stop(
      sprintf(
        "%s is not a column in %s.",
        metric, 
        as.character(substitute(mapvizieR_summary))
      )
    )
  }
  
  g_windows <- c("Fall to Spring",
                 "Spring to Spring",
                 "Fall to Winter",
                 "Winter to Spring", 
                 "Fall to Fall",
                 "Winter to Winter",
                 "Spring to Winter")
  
  if(!growth_window_in %in% g_windows)
    stop(sprintf("%s is not a valid growth window.", growth_window_in))
  
  if(!growth_window_in %in% unique(mapvizieR_summary$growth_window)) {
    stop(
      sprintf(
        "%s is not a growth season in %s$growth_window.",
        growth_window_in,
        as.character(substitute(mapvizieR_summary))
      )
    )
  }
  
  # Updating data
  if(by == "grade") {
    type <- "end_grade"
    x_var <- "SY"
    } else {
      
      mapvizieR_summary <- mapvizieR_summary %>% 
        dplyr::group_by(end_schoolname, cohort_year) %>%
        dplyr::mutate(cohort = sprintf("%s\n(Current Grade: %s)",
                                cohort_year,
                                max(end_grade)),
               Grade = end_grade)
      
    type <- "cohort"
    x_var <- "Grade"
    }
  
  facet_formula <- formula(sprintf("measurementscale ~ %s", type))
  
  x <- mapvizieR_summary %>%
    dplyr::ungroup() %>%
    dplyr::filter(growth_window == growth_window_in,
                  n_students >= n_cutoff) %>%
    dplyr::mutate(SY = sprintf("%s-%s",
                               stringr::str_extract(end_map_year_academic,  "\\d{2}$"),
                               as.integer(
                                 stringr::str_extract(
                                   end_map_year_academic,  
                                    "\\d{2}$"
                                  )
                               ) + 1
                        )
                  )
  
  p <- ggplot(
        x,
        aes(
          x = .data[[x_var]],
          y = .data[[metric]]
        )
      ) +
    geom_line(
      aes(
        color = .data[[school_col]],
        group = .data[[school_col]]
        )
      ) +
    geom_point(
      size = 5,
      color = "white",
      fill = "white"
      ) +
    facet_grid(facet_formula) + 
    theme_bw(base_size = 10) +
    theme(legend.position = "bottom",
          axis.text.x = element_text(size = 8, angle = 45, hjust = 1))
  
  # if the metric is a pct or between 0 and 1 then adjust to %
if(grepl("^pct_", metric) | all(dplyr::between(x[[metric]], 0, 1))) {
    p <- p +
      geom_text(
        aes(
          label = round(.data[[metric]]*100),
          color = .data[[school_col]]
        ),
        size = 3
      ) +
      scale_y_continuous(labels = scales::percent)
  } else {
   p <- p +
     geom_text(
     aes(
       label = round(.data[[metric]]),
       color = .data[[school_col]]
     ),
     size = 2
   )
  }
  
  # let's prettify some known titles. 
  
  y_lab <- switch(metric, "pct_typical" = "% M/E Typical Growth",
         "pct_accel_growth" = "% M/E College Ready Growth",
         "pct_negative" = "% Pct Negative Change in RIT",
         "end_pct_50th_pctl" = "% >= 50th Percentile (End Season)",
         "end_pct_75th_pctl" = "% >= 75th Percentile (End Season)")
  
  if(is.null(y_lab)) {
    if(grepl("testritscore", metric)) y_lab <- "RIT Score"
    if(grepl("rit_growth", metric)) y_lab <- "RIT Points"
    if(grepl("cgi", metric)) y_lab <- "Standard Deviations"
    if(grepl("sgp", metric)) y_lab <- "Student Growth Percentile"
    if(grepl("cgp", metric)) y_lab <- "Cohort Growth Percentile"
    if(grepl("percentile", metric)) y_lab <- "Percentile"
    
    # and if still null set equalt to the metric name
    if(is.null(y_lab)) y_lab <- metric
  }
  
  
  
  p <- p + labs(y = y_lab)
  
  p
    
  
}
