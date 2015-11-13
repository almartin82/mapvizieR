#' Longitudinal plot against NPR background
#'
#' @description shows the progress of students, and cohort average, against
#' the NPR space.
#'
#' @param mapvizieR_obj a conforming mapvizieR object
#' @param studentids a vector of studentids
#' @param measurementscale target subject
#' @param first_and_spring_only logical, should we include fall/winter scores
#' from non-entry grades?
#' @param entry_grade_seasons what grades are 'entry' grades for this school? 
#' @param name_annotations should we include student names on the plot? 
#' default is FALSE.
#' @param student_alpha how much to alpha-out the student observations?
#' @param trace_lines what norms to show?
#'
#' @return a ggplot object
#' @export

cohort_longitudinal_npr_plot <- function(
  mapvizieR_obj,
  studentids,
  measurementscale,
  first_and_spring_only = TRUE,
  entry_grade_seasons = c(-0.8, 4.2), 
  name_annotations = FALSE,
  student_alpha = 0.1,
  trace_lines = c(1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 99)
) {
  #limit to these students, subject, and entry grade logic
  this_cdf <- mv_limit_cdf(mapvizieR_obj, studentids, measurementscale)
  this_cdf <- valid_grade_seasons(
    this_cdf, first_and_spring_only, entry_grade_seasons, 9999
  )
  this_cdf$type <- 'Student'

  #add student names
  this_cdf <- roster_to_cdf(
    this_cdf, mapvizieR_obj, c('studentfirstname', 'studentlastname')
  )
  
  #for student display name
  this_cdf <- this_cdf %>%
    dplyr::mutate(
      short_name = paste0(
        stringr::str_sub(studentfirstname, 1, 1), '. ', studentlastname
      )
    ) %>%
    dplyr::ungroup() %>%
    dplyr::arrange(
      studentid, desc(grade_level_season)
    ) %>%
    dplyr::group_by(studentid) %>%
    dplyr::mutate(
      name_helper = cumsum(!is.na(testritscore)),
      short_name = ifelse(!is.na(testritscore) & name_helper == 1, short_name, '')
    ) %>%
    dplyr::select(-name_helper)
  
  grouped <- this_cdf %>%
    dplyr::group_by(
      grade_level_season
    ) %>%
    dplyr::summarize(
      testritscore = mean(testritscore, na.rm = TRUE),
      consistent_percentile = mean(consistent_percentile, na.rm = TRUE)
    )
  grouped$type <- 'Cohort'
  grouped$studentid <- 'Cohort'
  grouped$short_name <- 'Cohort'
  
  final_cdf <- rbind(
    grouped,
    this_cdf %>% 
      dplyr::select(
        type, grade_level_season, testritscore, 
        consistent_percentile, studentid, short_name
      )
  )
  
  out <- ggplot() + 
    geom_point(
      data = final_cdf,
      aes(
        x = grade_level_season,
        y = consistent_percentile,
        group = studentid,
        color = type,
        size = type,
        alpha = type
      )
    )
  
  if (name_annotations) {
    out <- out +
      geom_text(
        data = final_cdf,
        aes(
          x = grade_level_season - 0.01,
          y = consistent_percentile,
          group = studentid,
          label = short_name,
          color = type
        ),
        alpha = .25,
        size = 3,
        hjust = 1,
        check_overlap = TRUE,
        position = position_jitter(width = 0, height = 0.5)
      )
  }
  
  
  out <- out +
    geom_line(
      data = final_cdf,
      aes(
        x = grade_level_season,
        y = consistent_percentile,
        group = studentid,
        color = type,
        size = type,
        alpha = type
      )
    ) +    
    scale_size_manual(values = c(3, 1)) +
    scale_alpha_manual(values = c(1, student_alpha)) +
    scale_color_manual(values = c('red2', 'darkblue')) +
    theme_bw() +
    theme(
      panel.grid = element_blank()
    ) +
    scale_y_continuous(breaks = seq(0, 100, 10)) +
    coord_cartesian(
      xlim = c(
        this_cdf$grade_level_season %>% min() %>%  - 0.05, 
        this_cdf$grade_level_season %>% max() %>% + 0.05
      ), 
      ylim = c(0, 100)
    ) 
  
  return(out)
  
}