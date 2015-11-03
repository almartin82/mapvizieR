#' @title calc_cgp
#' 
#' @description calculates both cgp targets and cgp results.
# '
#' @param measurementscale MAP subject
#' @param grade baseline/starting grad for the group of students
#' @param growth_window desired growth window for targets (fall/spring, spring/spring, fall/fall)
#' @param baseline_avg_rit the baseline mean rit for the group of students
#' @param ending_avg_rit the baseline mean rit for the group of students
#' @param sch_growth_study a school growth study to use.  default is sch_growth_norms_2012
#' @param calc_for vector of cgp targets to calculate for.
#' 
#' @return a named list - targets, and results
#' 
#' @export

calc_cgp <- function(
  measurementscale,
  grade,
  growth_window,
  baseline_avg_rit = NA,
  ending_avg_rit = NA,
  sch_growth_study = sch_growth_norms_2012,
  calc_for = c(1:99)
) {
  #cant have a calc_for value 0 or below, or above 100 - those aren't valid growth %iles.
  calc_for %>%
    ensurer::ensure_that(
      min(.) > 0, max(.) < 100,
      fail_with = function(...) {
        stop("valid calc_for values are between 1 and 99", call. = FALSE)
      }
    )
  
  #valid terms
  vt <- sch_growth_study[, c('measurementscale', 'grade', 'growth_window')]
  in_study <- paste(measurementscale, grade, growth_window, sep = '@') %in% paste(
    vt$measurementscale, vt$grade, vt$growth_window, sep = '@'
  )
  if (!in_study) {
    warning("measurementscale/grade/growth window combination isn't in school growth study.")
    return(list("targets" = NA, "results" = NA))
    
  }
  
  #start of growth window
  start_season <- stringr::str_sub(
    growth_window, 1, stringr::str_locate(growth_window, ' ')[1]-1
  )
  
  #TARGETS
  targets <- cohort_expectation_via_lookup(
    measurementscale,
    grade,
    growth_window,
    baseline_avg_rit,
    calc_for
  )

  #RESULTS
  #lookup expectation
  grw_expect <- sch_growth_lookup(
    measurementscale,
    grade,
    growth_window,
    baseline_avg_rit
  )

  #actual - typical over sd
  act = ending_avg_rit - baseline_avg_rit
  typ = grw_expect$typical_cohort_growth
  sdev = grw_expect$sd_of_expectation
  
  z_score = (act - typ) / sdev
  cgp = pnorm(z_score) * 100
    
  return(
    list("targets" = targets, "results" = cgp)
  )
}



#' @title cohort_expectation_via_lookup
#' 
#' @description wrapper function to get cohort growth expectations for the lookup method
#' 
#' @param measurementscale a MAP subject
#' @param grade the ENDING grade level for the growth window.  ie, if this calculation
#' crosses school years, use the grade level for the END of the term, per the example on p. 7
#' of the 2012 school growth study
#' @param growth_window the growth window to calculate CGP over
#' @param baseline_avg_rit mean rit at the START of the growth window
#' @param calc_for what CGPs to calculate for?
#' @param sch_growth_study which school growth study to use.  currently only have the 2012 data
#' files in the package

cohort_expectation_via_lookup <- function(
  measurementscale,
  grade,
  growth_window,
  baseline_avg_rit,
  calc_for,
  sch_growth_study = sch_growth_norms_2012
) {
  
  #get expectation
  grw_expect <- sch_growth_lookup(
    measurementscale,
    grade,
    growth_window,
    baseline_avg_rit
  )
  
  #calc targets over range
  growth_target <- lapply(
    X = calc_for, 
    FUN = rit_gain_needed, 
    sd_gain = grw_expect[['sd_of_expectation']], 
    mean_gain = grw_expect[['typical_cohort_growth']]
  ) %>% unlist()

  #return df
  data.frame(
    cgp = calc_for,
    z_score = qnorm(calc_for/100),
    growth_target = growth_target,
    measured_in = 'RIT'
  )
}



#' @title rit_gain_needed
#' 
#' @description rit gain needed to reach given percentile
#' 
#' @param percentile growth percentile, between 0-100
#' @param sd_gain sd for population growth
#' @param mean_gain typical growth for population

rit_gain_needed <- function(percentile, sd_gain, mean_gain) {
  z <- qnorm((percentile/100))
  (z * sd_gain) + mean_gain
}



#' @title sch_growth_lookup
#' 
#' @description get cohort growth expectations via lookup from growth study
#' 
#' @param measurementscale MAP subject
#' @param grade baseline/starting grade for the group of students
#' @param growth_window desired growth window for targets (fall/spring, spring/spring, fall/fall)
#' @param baseline_avg_rit the baseline mean rit for the group of students
#' @param sch_growth_study NWEA school growth study to use for lookup; defaults to 2012.

sch_growth_lookup <- function(  
  measurementscale,
  grade,
  growth_window,
  baseline_avg_rit,
  sch_growth_study = sch_growth_norms_2012
) {
  #nse
  measurementscale_in <- measurementscale
  grade_in <- grade
  growth_window_in <- growth_window
  
  norm_match <- sch_growth_study %>%
    dplyr::filter(
      measurementscale == measurementscale_in, 
      growth_window == growth_window_in, 
      grade == grade_in
    ) 
  
  norm_match$diff <- norm_match$rit - baseline_avg_rit
  
  best_match <- rank(abs(norm_match$diff), ties.method = c("first"))
  
  as.list(norm_match[best_match == 1, ])
}



#' @title rit_to_npr
#' 
#' @description given a RIT score, return the best match percentile rank
#' 
#' @param measurementscale MAP subject
#' @param grade grade level
#' @param season fall winter spring
#' @param RIT rit score

rit_to_npr <- function(measurementscale, grade, season, RIT) {
  
  measurementscale_in <- measurementscale
  grade_in <- grade
  rit_in <- RIT
  
  matches <- student_status_norms_2011 %>%
    dplyr::filter(
      measurementscale == measurementscale_in & 
      grade == grade_in & 
      fallwinterspring == season &
      round(RIT, 0) == rit_in     
    ) %>%
    dplyr::select(student_percentile)
  
  if (nrow(matches) == 0) {
    out <- NA
  } else{
    out <-matches %>% unlist() %>% unname()
  }
  
  return(out)
}



#' @title npr_to_rit
#' 
#' @description given a percentile rank, return the best match RIT
#' 
#' @param measurementscale MAP subject
#' @param grade grade level
#' @param season fall winter spring
#' @param npr a percentile rank, between 1-99

npr_to_rit <- function(measurementscale, grade, season, npr) {
  
  measurementscale_in <- measurementscale
  grade_in <- grade

  matches <- student_status_norms_2011_dense_extended %>%
    dplyr::filter(
      measurementscale == measurementscale_in & 
        grade == grade_in & 
        fallwinterspring == season &
        student_percentile == npr     
    ) %>%
    dplyr::select(RIT)
  
  if (nrow(matches) == 0) {
    out <- NA
  } else{
    out <- matches %>% unlist() %>% unname() %>% magrittr::extract(1)
  }
  
  return(out)
}



#' @title mapvizieR interface to simplify CGP calculations
#'
#' @param mapvizieR_obj mapvizieR object
#' @param studentids target students
#' @param measurementscale target subject
#' @param start_fws starting season
#' @param start_academic_year starting academic year
#' @param end_fws ending season
#' @param end_academic_year ending academic year

mapviz_cgp <- function(
  mapvizieR_obj, 
  studentids,
  measurementscale,
  start_fws, 
  start_academic_year, 
  end_fws, 
  end_academic_year
) {
  #data validation and unpack
  mv_opening_checks(mapvizieR_obj, studentids, 1)

  #unpack the mapvizieR object and limit to desired students
  growth_df <- mv_limit_growth(mapvizieR_obj, studentids, measurementscale)

  #data processing
  #just desired terms
  this_growth <- growth_df %>%
    dplyr::filter(
      start_map_year_academic == start_academic_year,
      start_fallwinterspring == start_fws,
      end_map_year_academic == end_academic_year,
      end_fallwinterspring == end_fws,
      complete_obsv == TRUE
    ) %>%
    dplyr::group_by(
      measurementscale, start_fallwinterspring, start_map_year_academic,
      end_fallwinterspring, end_map_year_academic
    ) 


  df <- this_growth %>%
    dplyr::summarize(
      avg_start_rit = mean(start_testritscore, na.rm = TRUE),
      avg_end_rit = mean(end_testritscore, na.rm = TRUE),
      avg_rit_change = mean(rit_growth, na.rm = TRUE),
      avg_start_npr = mean(start_consistent_percentile, na.rm = TRUE),
      avg_end_npr = mean(end_consistent_percentile, na.rm = TRUE),
      avg_npr_change = mean(end_consistent_percentile - start_consistent_percentile, na.rm = TRUE),
      n_typ_true = sum(met_typical_growth, na.rm = TRUE),
      n_typ_false = sum(!met_typical_growth, na.rm = TRUE),
      n = n(),
      approx_grade = round(mean(end_grade, na.rm = TRUE), 0) 
      ) %>%       
    dplyr::mutate(
      percent_typ = n_typ_true / (n_typ_true + n_typ_false)
  ) 
  
  #add cgp
  df <- df %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      cgp = calc_cgp(
        measurementscale = measurementscale,
        grade = approx_grade,
        growth_window = paste(start_fallwinterspring, 'to', end_fallwinterspring),
        baseline_avg_rit = avg_start_rit,
        ending_avg_rit = avg_end_rit
      )[['results']] 
  ) %>%
  as.data.frame
  
  return(df)
}
