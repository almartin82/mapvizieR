#' Student growth detail
#'
#' @description calculates longitudinal / summary growth stats for many students,
#' allowing analysis like 'who grew the most'? and 'who had the largest average 
#' conditional growth percentile'?
#' 
#' @param mapvizieR_obj a conforming mapvizieR object
#' @param studentids vector of studentids
#' @param measurementscale target subject
#' @param entry_grade_seasons what grades are considered entry grades
#'
#' @return a data frame with growth data
#' @export

stu_growth_detail <- function(
  mapvizieR_obj,
  studentids,
  measurementscale,
  #first and spring only is presumed to be true
  entry_grade_seasons = c(-0.8, 4.2)
) {
  this_cdf <- mv_limit_cdf(mapvizieR_obj, studentids, measurementscale)
  this_cdf <- valid_grade_seasons(
    this_cdf, FALSE, entry_grade_seasons, 9999
  )
  
  #get testid of next test event
  this_cdf <- this_cdf %>%
    dplyr::group_by(studentid, measurementscale) %>%
    dplyr::mutate(
      join_id = rank(teststartdate)
    ) %>% 
    dplyr::ungroup() %>%
    dplyr::arrange(studentid, measurementscale, join_id) %>%
    dplyr::group_by(studentid, measurementscale) %>%
    dplyr::mutate(
      next_id = lead(join_id)
    )
  
  for_join <- this_cdf %>%
    dplyr::ungroup() %>%
    dplyr::select(
      studentid, testid, join_id
    ) %>%
    dplyr::rename(
      next_testid = testid,
      next_id = join_id
    )
  
  this_cdf <- this_cdf %>% 
    dplyr::ungroup() %>%
    dplyr::left_join(
      for_join, by = c('studentid', 'next_id')
    ) %>%
    dplyr::rename(
      start_testid = testid,
      end_testid = next_testid
    )
  
  #get cgp from the growth
  this_cdf <- this_cdf %>%
    dplyr::left_join(
      mapvizieR_obj$growth_df %>%
        dplyr::ungroup() %>%
        dplyr::select(
          studentid, start_testid, end_testid, growth_window,
          rit_growth, cgi, sgp, met_typical_growth, met_accel_growth
        ),
      by = c('studentid', 'start_testid', 'end_testid')
    ) 
  
  summary_df <- this_cdf %>%
    dplyr::group_by(studentid) %>%
    dplyr::summarize(
      total_cgi = sum(cgi, na.rm = TRUE),
      avg_sgp = mean(sgp, na.rm = TRUE),
      pct_made_typ_growth = mean(met_typical_growth, na.rm = TRUE),
      pct_made_acceL_growth = mean(met_accel_growth, na.rm = TRUE)
    ) %>%
    dplyr::mutate(
      rank_cgi_most = rank(-total_cgi, ties.method = 'first'),
      rank_cgi_least = rank(total_cgi, ties.method = 'first')
    )

  #rit and percentile change
  change_df <- cdf_stu_change(this_cdf)

  summary_df <- summary_df %>%
    dplyr::left_join(
      change_df, by = 'studentid'
    )
  
  summary_df <- summary_df %>%
    dplyr::mutate(
      rank_npr_most = rank(-npr_change, ties.method = 'first'),
      rank_npr_least = rank(npr_change, ties.method = 'first')
    )
  
  #student names
  summary_df <- summary_df %>%
    dplyr::left_join(
      mapvizieR_obj$roster %>%
        dplyr::select(
          studentid, studentfirstlast
        ) %>% unique(),
      by = 'studentid'
    )

  return(summary_df)
}


#' Student Growth Detail Table
#'
#' @description growth detail in printable format.  wrapper around 
#' student_growth_detail
#' 
#' @param mapvizieR_obj a conforming mapvizieR object
#' @param studentids vector of studentids
#' @param measurementscale target subject
#' @param high_or_low_growth should we list most, or least growth?
#' default is high.
#' @param num_stu how many students to show in the table? default is 5.
#' @param entry_grade_seasons what grades are considered entry grades
#' @param title if desired, a title for the table
#' @param ... additional arguments to tableGrob
#'
#' @return a tableGrob 
#' @export

stu_growth_detail_table <- function(
  mapvizieR_obj,
  studentids,
  measurementscale,
  high_or_low_growth = 'high',
  num_stu = 5,
  entry_grade_seasons = c(-0.8, 4.2),
  title = '',
  ...
) {
  
  growth_df <- stu_growth_detail(
    mapvizieR_obj = mapvizieR_obj,
    studentids = studentids,
    measurementscale = measurementscale,
    entry_grade_seasons = entry_grade_seasons
  )
  
  growth_df <- growth_df %>%
    dplyr::ungroup() %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      filter_by = ifelse(
        high_or_low_growth == 'high', rank_npr_most, rank_npr_least
      )
    ) %>%
    dplyr::filter(
      filter_by <= num_stu
    ) %>%
    dplyr::arrange(
      filter_by
    ) %>%
    dplyr::rename(
      rank = filter_by
    )
  
  out <- gridExtra::tableGrob(
    growth_df %>%
      dplyr::select(
        rank, studentfirstlast, rit_change, npr_change
      ),
    rows = NULL,
    cols = c('Rank', 'Student', 'RIT Change', '%ile Change'),
    ...
  )
  
  if (! title == '') {
    table_title <- grid::textGrob(title)
    #table_title <- grid::textGrob(title, gp = gpar(fontsize = 16))
    padding <- unit(0.5, "line")
    out <- gtable::gtable_add_rows(
      out, heights = unit(1, "lines"), pos = 0
    )
    out <- gtable::gtable_add_grob(
      out, table_title,
      t = 1, l = 1, r = ncol(out)
    )
  }
  

  return(out)
}
  
#' find the RIT and NPR change across a cdf
#' 
#' @description looks at a CDF, takes first/last event by stu/subj, reports
#' change in RIT and NPR
#'
#' @param cdf a processed/prepped CDF, limited to the students and time 
#' period desired
#'
#' @return a data frame with studentid, measurementscale, rit start/end,
#' rit change, npr start/end, npr change
#' @export

cdf_stu_change <- function(cdf) {
  cdf <- cdf %>% 
    dplyr::group_by(studentid, measurementscale) %>%
    dplyr::mutate(
      rank_asc = rank(teststartdate),
      rank_desc = rank(-rank_asc)
    ) 
  
  base <- cdf %>%
    dplyr::ungroup() %>%
    dplyr::filter(rank_asc == 1) %>%
    dplyr::select(
      studentid, measurementscale, testritscore, consistent_percentile
    ) %>%
    dplyr::rename(
      first_rit = testritscore,
      first_npr = consistent_percentile
    )
  
  end <- cdf %>%
    dplyr::ungroup() %>%
    dplyr::filter(rank_desc == 1) %>%
    dplyr::select(
      studentid, measurementscale, testritscore, consistent_percentile
    ) %>%
    dplyr::rename(
      end_rit = testritscore,
      end_npr = consistent_percentile
    )
  
  out <- base %>%
    dplyr::left_join(end, by = c('studentid', 'measurementscale'))
  
  out$rit_change <- out$end_rit - out$first_rit
  out$npr_change <- out$end_npr - out$first_npr
  
  return(out)
}