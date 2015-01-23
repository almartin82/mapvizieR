#' @title Create a mapvizieR object
#' 
#' @description
#' \code{mapvizieR} is a workhorse workflow function that
#' calls a sequence of cdf and roster prep functions, given a raw cdf and raw roster
#' 
#' @param raw_cdf a NWEA AssessmentResults.csv or CDF
#' @param raw_roster a NWEA students
#' @examples
#' data(ex_CombinedAssessmentResults)
#' data(ex_CombinedStudentsBySchool)
#' 
#' cdf_mv <- mapvizieR(ex_CombinedAssessmentResults, 
#'                     ex_CombinedStudentsBySchool)
#'                     
#' is.mapvizieR(cdf_mv)                     
#' 
#' @export
mapvizieR <- function(raw_cdf, raw_roster) UseMethod("mapvizieR")

#' @export
mapvizieR.default <- function(raw_cdf, raw_roster) {
  
  prepped_cdf <- prep_cdf_long(raw_cdf)
  prepped_roster <- prep_roster(raw_roster)
  
  #do more processing on the cdf now that we have the roster
  prepped_cdf$grade <- grade_levelify_cdf(prepped_cdf, prepped_roster)
  
  processed_cdf <- prepped_cdf %>%
    grade_level_seasonify() %>%
    grade_season_labelify() %>%
    grade_season_sortify()
  
  #shit, why not just to all the joins we could ever want on this original data
  # Create Seaason to Season Numbers
  year_list<-as.integer(unique(processed_cdf$map_year_academic))
  
  map.SS<-rbind_all(lapply(year_list, 
                           s2s_match, 
                           .data=processed_cdf, 
                           season1="Spring", 
                           season2="Spring", 
                           typical.growth=T,
                           college.ready=T
  )
  )
  map.FS<-rbind_all(lapply(year_list, 
                           s2s_match,
                           .data=processed_cdf, 
                           season1="Fall", 
                           season2="Spring", 
                           typical.growth=T,
                           college.ready=T
  )
  )
  map.FW<-rbind_all(lapply(year_list, 
                           s2s_match, 
                           .data=processed_cdf, 
                           season1="Fall", 
                           season2="Winter", 
                           typical.growth=T,
                           college.ready=T
  )
  )
  map.WS<-rbind_all(lapply(year_list,
                           s2s_match, 
                           .data=processed_cdf, 
                           season1="Winter", 
                           season2="Spring", 
                           typical.growth=T,
                           college.ready=T
  )
  )
  map.FF<-rbind_all(lapply(year_list, 
                           s2s_match, 
                           .data=processed_cdf, 
                           season1="Fall", 
                           season2="Fall", 
                           typical.growth=T,
                           college.ready=T
  )
  )
  
  map.SW<-rbind_all(lapply(year_list, 
                           s2s_match, 
                           .data=processed_cdf, 
                           season1="Spring", 
                           season2="Winter", 
                           typical.growth=T,
                           college.ready=T
  )
  )
  
  cdf_growth<-rbind_all(list(map.SS, map.FS, map.FW, map.WS, map.FF, map.SW))
  
  
  mapviz <-  list(
      'cdf'=processed_cdf
     ,'roster'=prepped_roster
     ,'cdf_growth'=cdf_growth
     #todo: add some analytics about matched/unmatched kids
     )
  class(mapviz) <- "mapvizieR"
  
  #return 
  mapviz
}

#' @title Reports whether x is a mapvizier object
#'
#' @description
#' Reports whether x is a mapvizier object
#' @param x an object to test
#' @export
is.mapvizieR <- function(x) inherits(x, "mapvizieR")

#' @title print method for \code{mapvizier} class
#'
#' @description
#'  prints to console
#'
#' @details Prints a summary fo the a \code{mapvizier} object. 

#' @param x a \code{mapvizier} object

#' @return some details about the object to the console.
#' @rdname print
#' @export
#' @examples 
#' data(ex_CombinedAssessmentResults)
#' data(ex_CombinedStudentsBySchool)
#' 
#' cdf_mv <- mapvizieR(ex_CombinedAssessmentResults, 
#'                     ex_CombinedStudentsBySchool)
#'                     
#' cdf_mv

print.mapvizieR <-  function(x, ...) {
  
  #gather some summary stats
  n_df <- length(x)
  n_sy <- length(unique(x$cdf$map_year_academic))
  min_sy <- min(x$cdf$map_year_academic)
  max_sy <- max(x$cdf$map_year_academic)
  n_students <- length(unique(x$cdf$studentid))
  n_schools <- length(unique(x$cdf$schoolname))
  growthseasons <- unique(x$cdf_growth$growth_season)
  n_growthseasons <- length(growthseasons)
  
  cat("A mapvizieR object repesenting:\n- ")
  cat(paste(n_sy))
  cat(" school years from SY")
  cat(paste(min_sy))
  cat(" to SY")
  cat(paste(max_sy))
  cat(";\n- ")
  cat(paste(n_students))
  cat(" students from ")
  cat(paste(n_schools))
  cat(" schools;\n- and, ")
  cat(paste(n_growthseasons))
  cat(" growth seasons:\n    ")
  cat(paste(growthseasons, collapse = ",\n    "))  
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
                                   assessment_results %>% dplyr::filter(growthmeasureyn=TRUE),
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

#' @title Merge two different assessment seasons (by student and measurement scale)
#' from a single long-format MAP assessment data frame
#'
#' @description
#' \code{s2s_match} a dataframe with two season results matched on student-measurement
#' scale basis. 
#'
#' @details 
#' This function returns a data frame that results from subsetting a long-format data MAP assessment
#' data frame (i.e., where every students' test event occupies a single row), \code{.data} into two seasons 
#' and then mergeing the two subsets with an inner join on student id and measurement 
#' scale (via \code{dplyr::inner_join}) for the school year and seasons passed to it. All columns of \code{.data} are replicated, save of student id
#' and measuremen scale (since these are used to merge on) with the later season's column names
#' indicated wiht .2 suffix (i.e., \code{TestRITScore.2}). 
#' 
#' If indicated (by setting the values of the  \code{typical.growth} and \code{college.ready} 
#' parameters to \code{TRUE}) the function will also calculate the amount of growth (i.e. number of RIT points) and 
#' growth target (i.e., RIT score to attain) college ready growth.  
#' 
#' Note well that for \code{typical.growth=TRUE} the original 
#' data frame, \code{.data}, must have reported norms for the requried growth season.  The reported norm column 
#' must be named using the 2011 NWEA Norms table convention of the season (winter through fall) indicated by corresponding
#' integers (1-4);  For example fall to spring requires \code{.data} has a field names
#' \code{R42} and spring to spring wourld be \code{R22}.  These columns can be easily 
#' added to a CDF by using the \code{\link{nwea_growth}} function. 
#' 
#' Also note that calculating college ready growth and growth targets
#' requires that \code{.data} has a column named \code{KIPPTieredGrowth} containing 
#' a KIPP tiered multiplier for each student-assessment.  These data can be generated
#' using the \code{\link{tiered_growth}} function. 
#' 
#' @param .data a data frame with assessment data, in long-format (i.e., one student-assessment per row).
#' @param season1 a string of either "Fall", "Winter", or "Spring" for the first assessment season by which to subset \code{.data} and join on.
#' @param season2 a string of either "Fall", "Winter", or "Spring" for the first assessment season by which to subset \code{.data} and join on. 
#' Note that if "Spring" to "Fall" is  a valid combination but norms cannot be calcualted for it.
#' @param sy an integer indicating the (second half school year.  For example, enter 2014 for the 2013-2104 school year. For assessment combinations that are ambiguious like 
#' spring to spring, the school year is taken to be the the school year for season 2 and season 1 is taken from 
#' the prior year. 
#' @param typical.growth boolean indicating if typical growth, typical growth target, and typical growth met/exceeded inditor are to be calculted. Requires that \code{.data} have norm columns.
#' @param college.ready boolean indicating if college ready growth, college ready growth target, and college ready growth met/exceeded inditor are to be calculted. Requires that \code{.data} have KIPPTieredGrowth column.
#' 
#' @return a data.frame ith at least 2(m-1) columns (and as many as $(m-1) + 6) and 
#' a row for every student-assessment that occured in both season 1 and season 2. 
#' @export
#' @examples 
#' 
#' data(ex_CombinedAssessmentResults)
#' data(ex_CombinedStudentsBySchool)
#' 
#'require(dplyr) 
#' cdf<- ex_CombinedAssessmentResults %>%
#' prep_cdf_long 
#' 
#' roster <- prep_roster(ex_CombinedStudentsBySchool)
#' 
#' cdf$grade <-  grade_levelify_cdf(cdf, roster)
#' 
#' cdf_growth_ss<-s2s_match(cdf, 
#'                          season1 = "Spring", 
#'                          season2 = "Spring", 
#'                          sy = 2013)
#' glimpse(cdf_growth_ss)




s2s_match <- function(.data, 
                      season1="Fall", 
                      season2="Spring", 
                      sy=2013,
                      typical.growth=TRUE,
                      college.ready=TRUE){
  
  # input validation
  assert_that(season1 %in% c("Fall", "Spring", "Winter"), 
            season2 %in% c("Fall", "Spring", "Winter"),
            is.numeric(sy),
            is.data.frame(.data),
            is.logical(typical.growth),
            is.logical(college.ready)
            )
  
  check_cdf_long(.data)
  
  .data$testquartile <- kipp_quartile(.data$testpercentile)
  
  growth_norms <- nwea_growth(start.grade = .data$grade,
                              start.rit = .data$testritscore,
                              measurementscale = .data$measurementscale
                              )
  
  .data <- cbind(.data, growth_norms)
  
  .data$tiered_growth_factor <- tiered_growth_factors(quartile = .data$testquartile,
                                                      grade = .data$grade
                                                     )
  
  
  
  # filter to Season1
  # If season1=season2, i.e., spring-spring, roll Year2 back one year
  sy1<-sy
  if(season1==season2) sy1 <- sy-1
  
  # special check for spring to winter growth
  if(season1=="Spring" & season2=="Winter") sy1 <- sy-1
  m.1<-dplyr::filter(.data, 
                     fallwinterspring==season1, 
                     map_year_academic==as.character(sy1))
  
  # filter to Season2
  m.2<-dplyr::filter(.data, 
                     fallwinterspring==season2, 
                     map_year_academic==as.character(sy))
  
  
  # Join on ID and MeasurementScale
  m.12<-dplyr::inner_join(m.1, m.2, by=c("studentid", "measurementscale"))
  
  # growth calculations
  if(typical.growth | college.ready){
    # construct and substitute names
    seasons <-paste0(season1,season2)
    norm.season <- as.name(switch(seasons,
                                  "FallFall"     = "R44.x", #appended x because these appear twice after the join
                                  "FallSpring"   = "R42.x",
                                  "FallWinter"   = "R41.x",
                                  "WinterSpring" = "R12.x",
                                  "SpringSpring" = "R22.x",
                                  "SpringWinter" = "R22.x" #notice that spring winter uses spring to spring norms, these cut in half below
                                  )
    )
    if(!as.character(norm.season) %in% names(m.12)) stop(paste(".data is missing a column named", 
                                                               gsub(".x","", norm.season),
                                                               ". You can fix this error by running nwea_growth(). See ?nwea_growth for more details"
    )
    )
    if(typical.growth){
      q<-substitute(norm.season)
      m.12<-with(m.12, mutate(m.12, 
                              typical_growth=eval(q), 
                              typical_target=typical_growth+testritscore.x,
                              met_typical=testritscore.y>=typical_target, 
                              growth_season=paste(fallwinterspring.x, fallwinterspring.y, sep=" - ")
                              )
                 )
    }
    if(college.ready) {
      if(!"tiered_growth_factor.x" %in% names(m.12)) stop(paste(".data is missing a column named", 
                                                            "tiered_growth_factor",
                                                            ". You can fix this error by running tiered_growth_factors().\n", 
                                                            "See ?tiered_growth for more details"
      )
      )
      q<-substitute(norm.season * tiered_growth_factor.x)
      m.12 <- with(m.12, mutate(m.12, 
                                college_ready_growth=eval(q),
                                college_ready_target=testritscore.x+college_ready_growth,
                                met_college_ready=testritscore.y>=college_ready_target
      )
      )
    }
    # Adjust Spring-to-winter growth to be half of spring to spring and 
    # adjust typical and CR goals and targets
    if(seasons=="SpringWinter"){
      m.12 <- m.12 %>%
        mutate(typical_growth = round(typical_growth/2),
               college_ready_growth = round(college_ready_growth/2),
               typical_target = testritscore.x+typical_growth,
               college_ready_target=testritscore.x+college_ready_growth,
               met_typical=testritscore.y>=typical_target,
               met_college_ready=testritscore.y>=college_ready_target
        )
    }
  }  
  
  # Rename columns with .x or .y suffixes ot have no suffix for season 1
  #  and .2 for season 2 suffixes
  names(m.12)<- gsub("\\.x","",names(m.12))
  names(m.12) <- gsub("\\.y",".2",names(m.12))
  
  # return
  m.12
}