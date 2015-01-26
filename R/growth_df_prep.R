#' @title generate_growth_df
#'
#' @description
#' \code{generate_growth_df} takes a CDF and given two seasons (start and end) saturates
#' all possible growth calculations for a student and returns a long data frame with the
#' results.
#'
#' @details 
#' This function returns a growth data frame, with one row per student per test per 
#' valid 'growth_window', such as 'Fall to Spring'. 
#' 
#' @param processed_cdf a conforming processed_cdf data frame
#' @param norm_df defaults to norms_students_2011.  if you have a conforming norms object,
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
  norm_df=norms_students_2011,
  include_unsanctioned_windows=FALSE
){  
  #input validation
  assert_that(
    is.data.frame(processed_cdf),
    is.data.frame(norm_df),
    is.logical(include_unsanctioned_windows),
    check_processed_cdf(processed_cdf)$boolean
  )

  #generate a scaffold of students/terms/windows
  f2s <- student_scaffold(processed_cdf, 'Fall', 'Spring', 0)
  f2w <- student_scaffold(processed_cdf, 'Fall', 'Winter', 0)
  w2s <- student_scaffold(processed_cdf, 'Winter', 'Spring', 0)  
  s2s <- student_scaffold(processed_cdf, 'Spring', 'Spring', 1)
  scaffolds <- rbind(f2s, f2w, w2s, s2s)
  
  #extract scores from long cdf for start and end data
  start_data <- scores_by_testid(scaffolds$start_testid, processed_cdf, 'start')
  end_data <- scores_by_testid(scaffolds$end_testid, processed_cdf, 'end')
  
  with_scores <- cbind(scaffolds, start_data, end_data)
  
  growth_dfs <- list(
    headline=with_scores
    #TODO: long goal df here
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
  assert_that(
    is.data.frame(processed_cdf),
    start_season %in% c("Fall", "Spring", "Winter"), 
    end_season %in% c("Fall", "Spring", "Winter"),
    check_processed_cdf(processed_cdf)$boolean
  )
  
  #make a simplified df
  cols <- c("studentid", "measurementscale", "testid", 
    "map_year_academic", "fallwinterspring", "grade", "grade_level_season", "schoolname"           
  )
  simple <- processed_cdf[ ,cols]
  simple$hash <- with(simple,
    paste(studentid, measurementscale, fallwinterspring, simple$map_year_academic, sep='_')
  )
  
  #we want kids with EITHER start OR end
  start <- simple[simple$fallwinterspring==start_season, ]
  end <- simple[simple$fallwinterspring==end_season, ]
  
  #namespace stuff
    #normally I avoid reference by index number since, uh, inputs change, but
    #we are hard coding the columns above, so it is OK.
  start_prefixes <- c(rep("",2), rep("start_", 7))
  end_prefixes <- c(rep("",2), rep("end_", 7))

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
  only_start <- anti_join(
    x=start, y=matched_df, by=c("start_hash" = "start_hash")
  )
  only_start$match_status <- rep('only start', nrow(only_start))
  only_start$complete_obsv <- rep(FALSE, nrow(only_start))
  
  #what rows are ONLY found in the end df?
  only_end <- anti_join(
    x=end, y=matched_df, by=c("end_hash"="matching_end_hash")
  )
  only_end$match_status <- rep('only end', nrow(only_end))
  only_end$complete_obsv <- rep(FALSE, nrow(only_end))
  
  #build the df to return
  final <- rbind_all(list(matched_df, only_start, only_end))
  
  #discard some helpers
  final <- final[ ,!names(final) %in% c('start_hash', 'end_hash', 'matching_end_hash')]
  
  final$growth_window <- paste0(start_season, ' to ', end_season)
  
  #reorder
  final <- final[ ,names(final)[c(1:2, 17:15, 3:14)]]
  return(as.data.frame(final))
}



#' @title scores_by_testid
#' 
#' @description helper function for \code{generate_growth_df}. given a test id, 
#' returns df with all the scores.
#' 
#' @param testids
#' @param processed_cdf
#' @param start_or_end
#' 
#' 
#' 
#' @return one row data frame.

scores_by_testid <- function(testid, processed_cdf, start_or_end) {
  #input validation
  assert_that(
    #testids should all an integer
    #testid %% 1 == 0,
    is.data.frame(processed_cdf),
    check_processed_cdf(processed_cdf)$boolean,
    start_or_end %in% c('start', 'end')
  )

  matched <- left_join(as.data.frame(testid), processed_cdf, by="testid")
  
  matching_slim <- matched[ , c(names(matched)[c(7:14, 19:21, 62:64)])]
  #prefix it
  names(matching_slim) <- paste0(start_or_end, '_', names(matching_slim))
  
  return(matching_slim)  
}