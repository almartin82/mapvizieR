#' @title create_mapvizier_object
#' 
#' @description
#' \code{create_mapvizier_object} is a workhorse workflow function that
#' calls a sequence of cdf and roster prep functions, given a raw cdf and raw roster
#' 
#' @param raw_cdf a NWEA AssessmentResults.csv or CDF
#' @param raw_roster a NWEA students


create_mapvizier_object <- function(raw_cdf, raw_roster) {
  
  prepped_cdf <- prep_cdf_long(raw_cdf)
  prepped_roster <- prep_roster(raw_roster)
  
  #do more processing on the cdf now that we have the roster
  prepped_cdf$grade <- grade_levelify_cdf(prepped_cdf, prepped_roster)
  
  processed_cdf <- prepped_cdf %>%
    grade_level_seasonify() %>%
    grade_season_labelify() %>%
    grade_season_sortify()
  
  return(
    list(
      'cdf'=processed_cdf
     ,'roster'=prepped_roster
     #todo: add some analytics about matched/unmatched kids
    )  
  )
}


#' @title grade_levelify_cdf
#'
#' @description
#' \code{grade_levelify_cdf} adds a student's grade level at test time to
#' the cdf.  grade level is required for a variety of growth calculations.
#'
#' @param prepped_cdf a cdf file that passes the checks in \code{check_cdf_long}
#' @param roster a roster that passes the checks in \code{check_roster}
#'
#' @return a vector of grades
#' 
#' @export

grade_levelify_cdf <- function(prepped_cdf, roster) {
  
  slim_roster <- unique(roster[, c('studentid', 'termname', 'grade')])
  #first match on a student's EXACT termname
  matched_cdf <- left_join(prepped_cdf, slim_roster, by=c('studentid', 'termname'))

  exact_count <- nrow(!is.na(matched_cdf$grade))
  
  #if there are still unmatched students, attempt to match on map_year_academic
  if (nrow(matched_cdf[is.na(matched_cdf$grade), ]) > 0) {
    
    slim_roster <- unique(roster[, c('studentid', 'map_year_academic', 'grade')])
    
    secondary_match <- left_join(
      prepped_cdf, 
      slim_roster, by=c('studentid', 'map_year_academic') 
    )
    
    matched_cdf$grade <- ifelse(
      is.na(matched_cdf$grade), secondary_match$grade, matched_cdf$grade
    )
  } 
  
  return(matched_cdf$grade)
}

#' @title grade_season_labelify
#'
#' @description
#' \code{grade_season_labelify} returns an abbreviated label ('5S') that is useful when
#' labelling charts  
#'
#' @param x a cdf that has 'grade_level_season' (eg product of grade_level_seasonify)
#' \code{grade_levelify()}
#' 
#' @return a data frame with a grade_season_labels

grade_season_labelify <- function(x) {
  
  assert_that('grade_level_season' %in% names(x))
  
  prepped <- x %>% 
    rowwise() %>%
    mutate(
      grade_season_label = fall_spring_me(grade_level_season)
    )
  
  return(as.data.frame(prepped))
}



#' @title grade_season_sortify
#'
#' @description
#' \code{grade_season_sortify} returns a sortable grade season label
#'
#' @param x a cdf that has 'grade_level_season' (eg product of grade_level_seasonify)
#' \code{grade_levelify()}
#' 
#' @return a data frame with a grade_season_sorted

grade_season_sortify <- function(x) {
  
  assert_that('grade_level_season' %in% names(x))
  
  prepped <- x %>% 
    rowwise() %>%
    mutate(
      grade_season_label = fall_spring_sort_me(grade_level_season)
    )
  
  return(as.data.frame(prepped))
}

#' @title match assessment results with students by school roster. 
#'
#' @description
#' \code{cdf_roster_match} performs an inner join on a prepped, long cdf (Assesment Results)
#' a prepped long roster (i.e. StudentsBySchool).  
#'
#' @param assessment_results a cdf file that passes the checks in \code{\link{check_cdf_long}}
#' @param roster a roster that passes the checks in \code{\link{check_roster}}
#'
#' @return a merged data frame with \code{nrow(prepped_cdf)}
#' 
#' @export

cdf_roster_match <- function(assessment_results, roster) {
  # Validation
  assert_that(check_cdf_long(assessment_results)$boolean, 
              check_roster(roster)$boolean
  )
  
  # inner join of roster and assessment results by id, subject, and term name
  matched_df <-  dplyr::inner_join(roster, 
                                   assessment_results %>% filter(growthmeasureyn=TRUE),
                                   by=c("studentid", "termname", "schoolname")
  ) %>%
    select(-ends_with(".y")) %>% # drop repeated columns
    as.data.frame
  
  # drop .x join artifact from colun names (we dropped .y in select above )
  names(matched_df)<-gsub("(.+)(\\.x)", "\\1", names(matched_df))
  
  
  #check that number of rows of assessment_results = nrow of matched_df
  input_rows <- nrow(assessment_results)
  output_rows <- nrow(matched_df)
  if(input_rows!=output_rows){
    cdf_name<-substitute(assessment_results)
    msg <- paste0("The number of rows in ", cdf_name, " is ", input_rows, 
                  ", while the number of rows in the matched data frame\n",
                  "returned by this function is ", output_rows, ".\n\n",
                  "You might want to check your data.")
    warning(msg)
  }
  
  #return 
  matched_df
}

#' @title Create a data frame of all requested NWEA MAP growth norms. 
#'
#' @description
#' \code{nwea_growth} takes three vectors for grade-level, (starting) RIT Score, and Measurement Scale
#'  (usually from a CDF) and return a returns data.frame of typical growth
#'  calculations from the NWEA 2011 MAP Norms tables for each grade-RIT-measurement scale triplet. 
#'  
#' @details 
#' User can indicate which calculted nomrs (typical mean, reported mean, and standard deviation) and 
#'  any growth period by using the letter+two digit NWEA 2011 Growth Norms indicator (i.e. for 
#'  Reported spring to spring growth user will provide R22, for typical fall to winter growth user provides
#'  T41, and for the the standard deviation of fall to spring growth user will provide S42). Providing no list
#'  of norms indicators results in every norm and season returned. All passed vectors must be the same length
#'
#' 
#' @param start.grade vector of student start (or pre-test) grade levels
#' @param start.rit vector of student start (or pre-test) RIT scores
#' @param measurementscale vector of measurement scales for the RIT scores in \code{start.rit}
#' @param \code{...} arguments passed to dplyr:select, used to select the requested norms data.  You pass indicators like 
#' T42, S22, R12 as unevaluated args (i.e. as unquoted strings).  For examples, passing R42 causes the 
#' function to return a single vector of reported fall-to-spring growth norms; passing R42, S42, R22 would 
#' return a data.frame with 3 columns for reported fall-to-spring growth, the standard deviation of fall-to-spring
#' growth and reported spring-spring-growth, respectively
#' 
#' @return a vector of \code{length(start.grade)} or data.frame with \code{nrow(start.grade)} and \code{ncols(x)==length(...)}.
#' @export
#' @examples 
#' nwea_growth(start.grade = 5, 
#'             start.rit = 190, 
#'             measurementscale = "Reading")
#'             
#' # example with CDF
#' cdf<- ex_CombinedAssessmentResults %>%
#'         prep_cdf_long 
#' roster <- prep_roster(ex_CombinedStudentsBySchool)
#' cdf$grade <-  grade_levelify_cdf(cdf, roster)
#' 
#' growth<-nwea_growth(start.grade = cdf$grade, 
#'                     start.rit = cdf$testritscore,
#'                     measurementscale = cdf$measurementscale
#' )
#' cdf_2<-cbind(cdf, growth)
#' 
#' glimpse(cdf_2)
#' 
#' # get spring to spring growth stats only
#' growth_s2s<-nwea_growth(start.grade = cdf$grade, 
#'                         start.rit = cdf$testritscore,
#'                         measurementscale = cdf$measurementscale,
#'                         'contains("22")'
#' )
#' cdf_3<-cbind(cdf, growth_s2s) 
#' glimpse(cdf_3)
#'
nwea_growth<- function(start.grade, 
                       start.rit, 
                       measurementscale, 
                       ...){
  
  stopifnot(all.equal(length(start.grade), 
                      length(start.rit), 
                      length(measurementscale)
  )
  )
  
  subs<-list(...)  
  #data(norms_students_2011, envir=environment())
  
  norms<-select(norms_students_2011, 
                Grade=StartGrade,
                TestRITScore=StartRIT,
                MeasurementScale,
                T41:S12)
  
  df<-data.frame(Grade=as.integer(start.grade), 
                 TestRITScore=as.integer(start.rit), 
                 MeasurementScale=as.character(measurementscale),
                 stringsAsFactors = FALSE)
  
  df2 <- dplyr::left_join(df, 
                          norms, 
                          by=c("MeasurementScale", "Grade", "TestRITScore")) %>%
    select(-Grade, -TestRITScore, -MeasurementScale)
  
  df2<-df2[,names(df2)[order(names(df2))]]
  
  if(length(subs)>=1) df2<-dplyr::select_(df2, ...)
  
  df2
}