#' @title calc_cgp
#' 
#' @description calculates both cgp targets and cgp results.
# '
#' @param measurementscale MAP subject
#' @param end_grade baseline/starting grad for the group of students
#' @param growth_window desired growth window for targets (fall/spring, spring/spring, fall/fall)
#' @param baseline_avg_rit the baseline mean rit for the group of students
#' @param ending_avg_rit the baseline mean rit for the group of students
#' @param norms which school growth study to use.  c(2012, 2015).  default is
#' 2015.
#' @param calc_for vector of cgp targets to calculate for.
#' @param verbose should warnings about invalid seasons be raised?
#' 
#' @return a named list - targets, and results
#' 
#' @export

calc_cgp <- function(
  measurementscale,
  end_grade,
  growth_window,
  baseline_avg_rit = NA,
  ending_avg_rit = NA,
  norms = 2015,
  calc_for = c(1:99),
  verbose = TRUE
) {
  #cant have a calc_for value 0 or below, or above 100 - those aren't valid growth %iles.
  calc_for %>%
    ensurer::ensure_that(
      min(.) > 0, max(.) < 100,
      fail_with = function(...) {
        stop("valid calc_for values are between 1 and 99", call. = FALSE)
      }
    )
  
  if (norms == 2012) {
    active_norms <- sch_growth_norms_2012
  } else if (norms == 2015) {
    active_norms <- sch_growth_norms_2015
  } 
  
  #valid terms
  vt <- active_norms[, c('measurementscale', 'end_grade', 'growth_window')]
  in_study <- paste(measurementscale, end_grade, growth_window, sep = '@') %in% paste(
    vt$measurementscale, vt$end_grade, vt$growth_window, sep = '@'
  )
  if (!in_study) {
    if (verbose) warning("measurementscale/grade/growth window combination isn't in school growth study.")
    return(list("targets" = NA_real_, "results" = NA_real_))
    
  }
  
  #start of growth window
  start_season <- stringr::str_sub(
    growth_window, 1, stringr::str_locate(growth_window, ' ')[1]-1
  )
  
  #TARGETS
  targets <- cohort_expectation(
    measurementscale,
    end_grade,
    growth_window,
    baseline_avg_rit,
    calc_for,
    norms
  )

  #RESULTS
  #lookup expectation
  grw_expect <- sch_growth_lookup(
    measurementscale,
    end_grade,
    growth_window,
    baseline_avg_rit,
    norms = norms
  )

  #actual - typical over sd
  act = ending_avg_rit - baseline_avg_rit
  typ = grw_expect$typical_cohort_growth
  sdev = grw_expect$sd_of_expectation
  
  z_score = (act - typ) / sdev
  cgp = pnorm(z_score) * 100
  
  #include observed baseline in expectations
  grw_expect$observed_baseline <- baseline_avg_rit
  #include implied start grade_level_season in expectations
  if (grw_expect$growth_window == 'Fall to Spring') {
    grw_expect$start_grade_level_season <- grw_expect$end_grade - 0.8
  } else if (grw_expect$growth_window == 'Spring to Spring') {
    grw_expect$start_grade_level_season <- grw_expect$end_grade - 1
  } else {
    grw_expect$start_grade_level_season <- NA_real_
  }
  
  return(
    list("targets" = targets, "results" = cgp, "expectations" = grw_expect)
  )
}



#' @title cohort_expectation
#' 
#' @description wrapper function to get cohort growth expectations for the lookup method
#' 
#' @param measurementscale a MAP subject
#' @param end_grade the ENDING grade level for the growth window.  ie, if this calculation
#' crosses school years, use the grade level for the END of the term, per the example on p. 7
#' of the 2012 school growth study
#' @param growth_window the growth window to calculate CGP over
#' @param baseline_avg_rit mean rit at the START of the growth window
#' @param calc_for what CGPs to calculate for?
#' @param norms which school growth study to use.  c(2012, 2015).  default is
#' 2015.
#' 
#' @export

cohort_expectation <- function(
  measurementscale,
  end_grade,
  growth_window,
  baseline_avg_rit,
  calc_for,
  norms = 2015
) {
  
  if (norms == 2012) {
    active_norms <- sch_growth_norms_2012
  } else if (norms == 2015) {
    active_norms <- sch_growth_norms_2015
  }   
  
  #get expectation
  grw_expect <- sch_growth_lookup(
    measurementscale,
    end_grade,
    growth_window,
    baseline_avg_rit,
    norms
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
#' 
#' @export


rit_gain_needed <- function(percentile, sd_gain, mean_gain) {
  z <- qnorm((percentile/100))
  (z * sd_gain) + mean_gain
}



#' @title sch_growth_lookup
#' 
#' @description get cohort growth expectations via lookup from growth study
#' 
#' @param measurementscale MAP subject
#' @param end_grade grade students will be in at the end of the window
#' @param growth_window desired growth window for targets (fall/spring, spring/spring, fall/fall)
#' @param baseline_avg_rit the baseline mean rit for the group of students
#' @param norms which school growth study to use.  c(2012, 2015).  default is
#' 2015.
#' 
#' @export

sch_growth_lookup <- function(  
  measurementscale,
  end_grade,
  growth_window,
  baseline_avg_rit,
  norms = 2015
) {
  #nse
  measurementscale_in <- measurementscale
  grade_in <- end_grade
  growth_window_in <- growth_window
  
  if (norms == 2012) {
    active_norms <- sch_growth_norms_2012
  } else if (norms == 2015) {
    active_norms <- sch_growth_norms_2015
  }  
  
  norm_match <- active_norms %>%
    dplyr::filter(
      measurementscale == measurementscale_in, 
      growth_window == growth_window_in, 
      end_grade == grade_in
    ) 
  
  norm_match$diff <- norm_match$rit - baseline_avg_rit
  
  best_match <- rank(abs(norm_match$diff), ties.method = c("first"))
  
  as.list(norm_match[best_match == 1, ])
}



##' @title rit_to_npr
#' 
#' @description given a RIT score, return the best match percentile rank.
#' (assumes the subject is a student, not a school/cohort.)
#' 
#' @param measurementscale MAP subject
#' @param current_grade grade level
#' @param season fall winter spring
#' @param RIT rit score
#' @param norms which school growth study to use.  c(2012, 2015).  default is
#' 2015.
#' 
#' @return a integer vector length one

rit_to_npr <- function(measurementscale, current_grade, season, RIT, norms = 2015) {
  
  if (norms == 2011) {
    active_norms <- student_status_norms_2011
  } else if (norms == 2015) {
    active_norms <- status_norms_2015
  }  
  measurementscale_in <- measurementscale
  grade_in <- current_grade
  rit_in <- RIT
  
  matches <- active_norms %>%
    dplyr::filter(
      measurementscale == measurementscale_in & 
        grade == grade_in & 
        fallwinterspring == season &
        round(RIT, 0) == rit_in     
    ) %>%
    dplyr::select(student_percentile)
  
  if (nrow(matches) == 0) {
    out <- NA_integer_
  } else{
    out <- matches %>% unlist() %>% unname()
  }
  
  return(out)
}



#' @title npr_to_rit
#' 
#' @description given a percentile rank, return the best match RIT
#' (assumes the subject is a student, not a school/cohort.)
#' 
#' @param measurementscale MAP subject
#' @param current_grade grade level
#' @param season fall winter spring
#' @param npr a percentile rank, between 1-99
#' @param norms which school growth study to use.  c(2012, 2015).  default is
#' 2015.
#' 
#' @return a integer vector length one

npr_to_rit <- function(measurementscale, current_grade, season, npr, norms = 2015) {
  
  measurementscale_in <- measurementscale
  grade_in <- current_grade
  
  if (norms == 2011) {
    active_norms <- student_status_norms_2011_dense_extended
  } else if (norms == 2015) {
    active_norms <- student_status_norms_2015_dense_extended
  }  
  
  matches <- active_norms %>%
    dplyr::filter(
      measurementscale == measurementscale_in & 
        grade == grade_in & 
        fallwinterspring == season &
        student_percentile == npr     
    ) %>%
    dplyr::select(RIT)
  
  if (nrow(matches) == 0) {
    out <- NA_integer_
  } else{
    out <- matches %>% unlist() %>% unname() %>% magrittr::extract(1)
  }
  
  return(out)
}


#' @title mapvizieR interface to simplify CGP calculations, for one target term
#' 
#' @description given an explicit growth term (start/end), will calculate CGP
#' 
#' @param mapvizieR_obj mapvizieR object
#' @param studentids target students
#' @param measurementscale target subject
#' @param start_fws starting season
#' @param start_academic_year starting academic year
#' @param end_fws ending season
#' @param end_academic_year ending academic year
#' @param norms which school growth study to use.  c(2012, 2015).  default is
#' 2015.
#' 
#' @export

mapviz_cgp <- function(
  mapvizieR_obj, 
  studentids,
  measurementscale,
  start_fws, 
  start_academic_year, 
  end_fws, 
  end_academic_year,
  norms = 2015
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
  #summarize
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
        end_grade = approx_grade,
        growth_window = paste(start_fallwinterspring, 'to', end_fallwinterspring),
        baseline_avg_rit = avg_start_rit,
        ending_avg_rit = avg_end_rit,
        norms = norms
      )[['results']] 
  ) %>%
  as.data.frame
  
  return(df)
}


#' @title wrapper to simplify CGP simulations
#'
#' @description helps simulate what happens if a cohort grows at a constant CGP.
#'
#' @param measurementscale target subject
#' @param start_rit mean starting rit
#' @param end_grade starting grade (not grade level season, just grade)
#' @param cgp target cgp.  can be single target or vector
#' @param growth_window what growth window to step
#' @param norms which school growth study to use.  c(2012, 2015).  default is
#' 2015.
#' 
#' @export

one_cgp_step <- function(
  measurementscale, 
  start_rit, 
  end_grade, 
  cgp, 
  growth_window = 'Spring to Spring',
  norms = 2015
) {
  calc_cgp(
    measurementscale, 
    end_grade,
    growth_window, 
    start_rit,
    calc_for = cgp,
    norms = norms
  )[['targets']]$growth_target
}


#' simulate school growth at a constant CGP
#'
#' @param measurementscale target subject
#' @param start_rit RIT the cohort started at
#' @param cgp what CGP to simulate growth at
#' @param sim_over 'ES', 'MS' or a vector of grade levels, at least length 2
#' @param norms which school growth study to use.  c(2012, 2015).  default is
#' 2015.
#'
#' @return a named list, with grades and rits
#' @export

cgp_sim <- function(
  measurementscale, 
  start_rit, 
  cgp, 
  sim_over = 'MS',
  norms = 2015
  ) {
  #ms or es
  if (is.numeric(sim_over)) {
    start_grade <- sim_over[1]
    iterate_over <- sim_over[-1]
  } else if (sim_over == 'MS') {
    start_grade <- 4.2
    iterate_over <- c(5:8)
  } else if (sim_over == 'ES') {
    start_grade <- -0.8
    iterate_over <- c(0:8)
  } 
  
  #running rit starts at input value
  rit <- start_rit
  
  #store the values
  running_rits <- c(rit)
  grades <- c(start_grade)
  
  for (i in iterate_over) {
    #entry
    if (i %in% c(0, 5)) {
      sim_wind <- 'Fall to Spring'
    } else {
      sim_wind <- 'Spring to Spring'
    }
    
    rit <- one_cgp_step(measurementscale, rit, i, cgp, sim_wind, norms) + rit
    grades <- c(grades, i)
    running_rits <- c(running_rits, rit)
  }
  
  list('grade_seq' = grades, 'rit_seq' = running_rits)  
}


#' CDF to CGP summary
#'
#' @param cdf conforming cdf file
#' @param grouping what column to group on.  default is implicit_cohort
#' @param norms which school growth study to use.  c(2012, 2015).  default is
#' 2015.
#'
#' @return a data frame with summary start/end rit, and cgps
#' @export

cdf_to_cgp <- function(cdf, grouping = 'implicit_cohort', norms = 2015) {
  
  grouped <- cdf %>%
    dplyr::group_by_(
      grouping, quote(measurementscale), 
      quote(fallwinterspring),
      quote(grade_level_season),
      quote(grade)
    ) %>%
    dplyr::summarize(
      mean_rit = mean(testritscore, na.rm = TRUE),
      mean_npr = mean(consistent_percentile, na.rm = TRUE),
      n = n()
    ) %>%
    dplyr::arrange(
      measurementscale, grade_level_season
    ) 
  grouped$psuedo_id <- row.names(grouped) %>% as.numeric()
  
  grouped <- grouped %>%
    dplyr::group_by_(grouping, quote(measurementscale)) %>%
    dplyr::arrange(psuedo_id) %>%
    dplyr::mutate(
      end_fallwinterspring = lead(fallwinterspring),
      end_grade = lead(grade),      
      end_grade_level_season = lead(grade_level_season),
      end_mean_rit = lead(mean_rit),
      end_mean_npr = lead(mean_npr)
    ) %>% 
    dplyr::rename(
      start_fallwinterspring = fallwinterspring,
      start_grade = grade,
      start_grade_level_season = grade_level_season,
      start_mean_rit = mean_rit,
      start_mean_npr = mean_npr
    ) 
    
  grouped <- grouped %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      cgp = calc_cgp(
        measurementscale = measurementscale,
        end_grade = end_grade,
        growth_window = paste(start_fallwinterspring, 'to', end_fallwinterspring),
        baseline_avg_rit = start_mean_rit,
        ending_avg_rit = end_mean_rit,
        norms = norms,
        verbose = FALSE
      )[['results']] 
    )
  
  return(grouped)
}


#' composite / preferred cdf baseline
#' 
#' @description given a vector of preferred baselines, will return
#' one row per student
#'
#' @param cdf conforming cdf
#' @param start_fws two or more seasons 
#' @param start_year_offset vector of integers. 
#' 0 if start season is same, -1 if start is prior year.
#' @param end_fws ending season
#' @param end_academic_year ending academic year
#' @param start_fws_prefer which term is preferred?
#' 
#' @return cdf with one row per student/subject
#' @export

preferred_cdf_baseline <- function(
  cdf, 
  start_fws, 
  start_year_offset, 
  end_fws, 
  end_academic_year, 
  start_fws_prefer
)  {
  #munging
  cdf <- cdf %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      temp_year_season = paste(fallwinterspring, map_year_academic, sep = '_')
    )
  academic_years <- end_academic_year + start_year_offset
  filter_year_seasons <- paste(start_fws, academic_years, sep = '_')
  
  #preferred row and filter
  cdf <- cdf %>%
    dplyr::filter(
      temp_year_season %in% filter_year_seasons
    ) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      is_preferred = grepl(pattern = start_fws_prefer, x = temp_year_season),
      for_filter = is_preferred %>% sum()
    ) %>% 
    dplyr::arrange(studentid, measurementscale, desc(for_filter)) %>% 
    dplyr::group_by(studentid, measurementscale) %>%
    dplyr::mutate(
      for_filter = rank(-for_filter)
    ) %>% 
    dplyr::filter(
      for_filter == 1
    )
  
  return(cdf)
}


#' @title mapvizieR interface to simplify growth goal calculations
#' 
#' @description given an explicit window, or a composite baseline, will calculate
#' CGP targets
#' 
#' @param mapvizieR_obj mapvizieR object
#' @param studentids target students
#' @param measurementscale target subject
#' @param start_fws one academic season (if known); 
#' pass vector of two and mapviz_cgp_targets will pick
#' @param start_year_offset 0 if start season is same, -1 if start is prior year.
#' @param end_fws ending season
#' @param end_academic_year ending academic year
#' @param end_grade specify the ending grade for the growth (this can't be reliably
#' inferred from data).
#' @param start_fws_prefer which term is preferred? not required if only one start_fws is passed
#' @param calc_for passed through to calc_cgp, what values to calculate targets for?
#' @param returns 'targets' or 'expectations'?
#' @param norms which school growth study to use.  c(2012, 2015).  default is
#' 2015.
#' 
#' @return data frame of cgp targets
#' @export

mapviz_cgp_targets <- function(
  mapvizieR_obj, 
  studentids,
  measurementscale,
  start_fws,
  start_year_offset,
  end_fws,
  end_academic_year,
  end_grade,
  start_fws_prefer = NA,
  calc_for = c(1:99),
  returns = 'targets',
  norms = 2015
) {
  #data validation and unpack
  mv_opening_checks(mapvizieR_obj, studentids, 1)

  #unpack the mapvizieR object and limit to desired students
  df <- mv_limit_cdf(mapvizieR_obj, studentids, measurementscale)

  #one term passed
  if (length(start_fws) == 1) {
    df <- df %>%
      dplyr::filter(
        fallwinterspring == start_fws &
        map_year_academic == end_academic_year + start_year_offset
      )
    df$is_preferred <- TRUE

  #multiple terms passed
  } else if (length(start_fws) > 1) {
    df <- preferred_cdf_baseline(
      df, 
      start_fws, 
      start_year_offset, 
      end_fws, 
      end_academic_year, 
      start_fws_prefer
    ) 
  }
  
  start_window <- df %>%
    dplyr::ungroup() %>%
    dplyr::filter(is_preferred) %>%
    dplyr::select(
      fallwinterspring
    ) %>%
    unique() %>% unlist() %>% unname()

  baseline_rit <- df %>%
    dplyr::ungroup() %>%
    dplyr::summarize(
      baseline_rit = mean(testritscore, na.rm = TRUE)
    ) %>% unlist() %>% unname()
  
  out <- calc_cgp(
    measurementscale = measurementscale,
    end_grade = end_grade,
    growth_window = paste(start_window, 'to', end_fws),
    baseline_avg_rit = baseline_rit,
    calc_for = calc_for,
    norms = norms
  )[[returns]]
  
  return(out)
}