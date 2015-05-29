utils::globalVariables(
  c("%>%", "mutate", "end_testritscore", "start_testritscore",
  "rit_growth", "reported_growth", "end_testpercentile",
  "start_testpercentile", "std_dev_of_expectation", "cgi")
)

#' @title generate_growth_df
#'
#' @description
#' \code{generate_growth_df} takes a CDF and given two seasons (start and end) saturates
#' all possible growth calculations for a student and returns a long data frame with the
#' results.
#'
#' @details
#' A workflow wrapper that calls a variety of growth_df prep functions.
#' Given a mapvizieR processed cdf, this function will return a a growth
#' data frame, with one row per student per test per valid 'growth_window',
#' eg 'Fall to Spring'.
#'
#' @param processed_cdf a conforming processed_cdf data frame
#' @param norm_df_long defaults to norms_students_2011.  if you have a conforming norms object,
#' you can use generate_growth_df to produce a growth data frame for those norms.
#' example usage: calculate college ready growth norms, and use generate_growth_df to see
#' if students met them.
#' @param include_unsanctioned_windows if TRUE, generate_growth_df will
#' return some additional growth windows like 'Spring to Winter', which aren't in the
#' official norms (but might be useful for progress monitoring).
#'
#' @return a data frame with all rows where the student had at least ONE matching
#' test event (start or end)
#'
#' @export

generate_growth_dfs <- function(
  processed_cdf,
  norm_df_long = norms_students_wide_to_long(norms_students_2011),
  include_unsanctioned_windows = FALSE
){
  #input validation
  assertthat::assert_that(
    is.data.frame(processed_cdf),
    is.data.frame(norm_df_long),
    is.logical(include_unsanctioned_windows),
    check_processed_cdf(processed_cdf)$boolean
  )

  #generate a scaffold of students/terms/windows
  scaffold <- build_growth_scaffolds(processed_cdf)

  #match start/end testids to cdf data
  with_scores <- growth_testid_lookup(scaffold, processed_cdf)

  #look up norms and add growth metrics
  with_norms <- growth_norm_lookup(
    with_scores, processed_cdf, norm_df_long, include_unsanctioned_windows
    ) %>%
    calc_rit_growth_metrics

  #todo: GOAL scores here

  growth_dfs <- list(
    headline = with_norms
    #TODO: return goal scores df here
  )

  return(growth_dfs)
}



#' @title student_scaffold
#'
#' @description which student/test/season rows have valid data?
#'
#' @param processed_cdf a conforming processed_cdf data frame
#' @param start_season the start of the growth window ("Fall", "Winter", or "Spring")
#' @param end_season the end of the growth window ("Fall", "Winter", or "Spring")
#' @param year_offset start_year + ? = end_year.  if same academic_year (eg fall to spring)
#' this is 0  if spring to spring, this is 1
#'
#' @return a data frame to pass back generate_growth_df that has kids, and the relevant
#' student/test/seasons to calculate growth records on

student_scaffold <- function(
  processed_cdf,
  start_season,
  end_season,
  year_offset
) {
  #input validation
  assertthat::assert_that(
    is.data.frame(processed_cdf),
    start_season %in% c("Fall", "Spring", "Winter"),
    end_season %in% c("Fall", "Spring", "Winter"),
    check_processed_cdf(processed_cdf)$boolean
  )

  #make a simplified df
  cols <- c("studentid", "measurementscale", "testid",
    "map_year_academic", "fallwinterspring", "grade", "grade_level_season", "schoolname"
  )
  simple <- processed_cdf[ ,cols] %>% as.data.frame()
  simple$hash <- with(simple,
    paste(studentid, measurementscale, fallwinterspring, map_year_academic, sep='_')
  )

  #we want kids with EITHER start OR end
  start <- simple[simple$fallwinterspring==start_season, ]
  end <- simple[simple$fallwinterspring==end_season, ]

  #define target columns now, in case we need to step out
  target_cols <- c("studentid", "measurementscale", "end_schoolname", "end_grade_level_season",
    "end_grade", "growth_window", "complete_obsv", "match_status",
    "start_testid", "start_map_year_academic", "start_fallwinterspring",
    "start_grade", "start_grade_level_season", "start_schoolname",
    "end_testid", "end_map_year_academic", "end_fallwinterspring"
  )

  empty <- data.frame(
    matrix(vector(), 0, length(target_cols), dimnames=list(c(), target_cols)),
    stringsAsFactors=F
  )

  #if there's no data, don't worry about matching; just return a zero row df
  if (nrow(start) == 0 | nrow(end) == 0) {
    return(empty)
  }

  #namespace stuff
    #normally I avoid reference by index number since, uh, inputs change, but
    #we are hard coding the columns above, so it is OK.
  start_prefixes <- c(rep("", 2), rep("start_", 7))
  end_prefixes <- c(rep("", 2), rep("end_", 7))

  names(start) <- paste0(start_prefixes, names(start))
  names(end) <- paste0(end_prefixes, names(end))

  #a valid observation has BOTH start AND end AND the years match
    #first build a match hash to find out what to match on
  start$matching_end_hash <- with(start,
      paste(studentid, measurementscale, end_season,
        #this is the magic here - build the term you are looking for IN end ON start.
        #then use in the inner_join below
        start_map_year_academic + year_offset, sep='_'
      )
  )

  #a dplyr inner join will return the *matching* rows
  matched_rows <- dplyr::inner_join(
    x=start, y=end[, c(3:9)], by=c("matching_end_hash" = "end_hash")
  )

  #dplyr returns a barfy order. reorder.
  col_order <- c("studentid", "measurementscale",       #constants
    "start_testid", "start_map_year_academic",          #start cols
    "start_fallwinterspring", "start_grade",
    "start_grade_level_season", "start_schoolname",
    "end_testid", "end_map_year_academic",              #end cols
    "end_fallwinterspring", "end_grade",
    "end_grade_level_season", "end_schoolname",
    "start_hash", "matching_end_hash"                   #hashes
  )
  matched_df <- matched_rows[ ,col_order]
  matched_df$match_status <- rep('start and end', nrow(matched_df))
  matched_df$complete_obsv <- rep(TRUE, nrow(matched_df))

  #what rows are ONLY found in the start df?
  only_start <- dplyr::anti_join(
    x=start, y=matched_df, by=c("start_hash" = "start_hash")
  )
  if (nrow(only_start) > 0) {
    only_start$match_status <- rep('only start', nrow(only_start))
    only_start$complete_obsv <- rep(FALSE, nrow(only_start))
    #ensure that we always return FWS and year, even if unmatched on end.
    only_start$end_fallwinterspring <- end_season
    only_start$end_map_year_academic <- only_start$start_map_year_academic + year_offset
  }

  #what rows are ONLY found in the end df?
  only_end <- dplyr::anti_join(
    x=end, y=matched_df, by=c("end_hash"="matching_end_hash")
  )
  if (nrow(only_end) > 0) {
    only_end$match_status <- rep('only end', nrow(only_end))
    only_end$complete_obsv <- rep(FALSE, nrow(only_end))
    #ensure that we always return FWS and year, even if unmatched on start
    only_end$start_fallwinterspring <- start_season
    only_end$start_map_year_academic <- only_end$end_map_year_academic - year_offset
  }

  #build the df to return
  final <- dplyr::rbind_all(list(matched_df, only_start, only_end))

  #discard some helpers
  final <- final[ ,!names(final) %in% c('start_hash', 'end_hash', 'matching_end_hash')]

  final$growth_window <- paste0(start_season, ' to ', end_season)

  #reorder
  final <- final[ , target_cols]

  return(as.data.frame(final))
}



#' @title scores_by_testid
#'
#' @description helper function for \code{generate_growth_df}. given a test id,
#' returns df with all the scores.
#'
#' @param testid a vector of testids
#' @param processed_cdf a conforming processed_cdf data frame
#' @param start_or_end either c('start', 'end')
#'
#' @return one row data frame.

scores_by_testid <- function(testid, processed_cdf, start_or_end) {
  #input validation
  assertthat::assert_that(
    #testids can't be null
    is.data.frame(processed_cdf),
    check_processed_cdf(processed_cdf)$boolean,
    start_or_end %in% c('start', 'end')
  )

  matched <- dplyr::left_join(
    as.data.frame(testid), processed_cdf, by="testid"
  )

  target_cols <- c("growthmeasureyn", "testtype", "testname", "teststartdate",
    "testdurationminutes", "testritscore", "teststandarderror", "testpercentile",
    "consistent_percentile", "testquartile", "rittoreadingscore", "rittoreadingmin",
    "rittoreadingmax", "teststarttime", "percentcorrect", "projectedproficiency")

  matching_slim <- matched[ , target_cols]
  #prefix it
  names(matching_slim) <- paste0(start_or_end, '_', names(matching_slim))

  return(matching_slim)
}



#' @title build_growth_scaffolds
#'
#' @description a helper function for \code{generate_growth_df}.
#' finds all the student/season growth windows.
#'
#' @param processed_cdf conforming mapvizieR processed cdf

build_growth_scaffolds <- function(processed_cdf){
  f2s <- student_scaffold(processed_cdf, 'Fall', 'Spring', 0)
  f2w <- student_scaffold(processed_cdf, 'Fall', 'Winter', 0)
  w2s <- student_scaffold(processed_cdf, 'Winter', 'Spring', 0)
  s2s <- student_scaffold(processed_cdf, 'Spring', 'Spring', 1)
  scaffolds <- rbind(f2s, f2w, w2s, s2s)

  return(scaffolds)
}



#' @title growth_testid_lookup
#'
#' @description a helper function for \code{generate_growth_df}
#' given a scaffold of student/season growth windows, finds the
#' matching test data in the cdf
#'
#' @param scaffold output of \code{build_growth_scaffolds}
#' @param processed_cdf conforming mapvizieR processed cdf

growth_testid_lookup <- function(scaffold, processed_cdf) {
  start_data <- scores_by_testid(scaffold$start_testid, processed_cdf, 'start')
  end_data <- scores_by_testid(scaffold$end_testid, processed_cdf, 'end')
  with_scores <- cbind(scaffold, start_data, end_data)

  return(with_scores)
}



#' @title growth_norm_lookup
#'
#' @description called by \code{generate_growth_df} to return
#' growth norms for growth data frames in process
#'
#' @param incomplete_growth_df a growth df in process.  needs to have growth
#' windows, start_grade, and start_testritscore.
#' @param processed_cdf conforming mapvizieR processed cdf.  needed for
#' unsanctioned windows.
#' @param norm_df_long a data frame of normative expectations
#' @param include_unsanctioned_windows check generate_growth_df for a
#' description.
#' @param ... currently not used.

growth_norm_lookup <- function(
  incomplete_growth_df,
  processed_cdf,
  norm_df_long,
  include_unsanctioned_windows,
  ...
) {

  if (include_unsanctioned_windows) {
    #spring to winter
    scaffold <- student_scaffold(processed_cdf, 'Spring', 'Winter', 1)
    s2w <- growth_testid_lookup(scaffold, processed_cdf)

    #half of spring to spring for the norms
    temp_norms <- norm_df_long[norm_df_long$growth_window == 'Spring to Spring', ]
    temp_norms$growth_window <- 'Spring to Winter'
    temp_norms$typical_growth <- temp_norms$typical_growth / 2
    temp_norms$reported_growth <- temp_norms$reported_growth / 2
    #we don't know what the standard deviation is.
    temp_norms$std_dev_of_expectation <- NA

    #put back on dfs
    incomplete_growth_df <- rbind(incomplete_growth_df, s2w)
    norm_df_long <- rbind(norm_df_long, temp_norms)

    #todo: spring to fall (?)
  }

  with_matched_norms <- dplyr::left_join(
    x=incomplete_growth_df, y=norm_df_long,
    by=c("measurementscale" = "measurementscale",
      "growth_window" = "growth_window",
      "start_grade" = "startgrade",
      "start_testritscore" = "startrit")
  )

  return(with_matched_norms)
}


#' @title Calculate growth metrics (RIT growth, meeting indicators, conditional
#' change in test percentile, growth index, student growth percentile).
#'
#' @description a helper function  for \code{generate_growth_df}
#' which adds columns to a growth CDF for variuos growth statistics.
#'
#' @param normed_df a data frame that has matched growth windows for
#' each student/subject/season triplet.
#' @return a data frame the same as growth_df, with additional calcs

calc_rit_growth_metrics <- function(normed_df){

  out <- normed_df %>%
    dplyr::mutate(
      rit_growth = end_testritscore - start_testritscore,
      met_typical_growth = rit_growth >= reported_growth,
      change_testpercentile = end_testpercentile - start_testpercentile,
      cgi = (rit_growth-reported_growth) / std_dev_of_expectation,
      sgp = pnorm(cgi)
    ) %>%
    as.data.frame

  return(out)
}



#' @title determine growth status
#'
#' @description last thing that runs after accelerated growth is calculated
#'
#' @param df output of add accelerated growth

determine_growth_status <- function(df) {

  #growth status
  df$growth_status <- ifelse(df$met_accel_growth, 'College Ready', NA)

  df$growth_status <- ifelse(
    is.na(df$growth_status) & !df$met_accel_growth & df$met_typical_growth,
    'Typical', df$growth_status
  )
  df$growth_status <- ifelse(
    is.na(df$growth_status) & df$rit_growth <= 0,
    'Negative', df$growth_status
  )
  df$growth_status <- ifelse(
    is.na(df$growth_status) & df$rit_growth > 0 & !df$met_typical_growth,
    'Positive', df$growth_status
  )

  return(df)
}
