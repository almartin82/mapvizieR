#' @title Create a mapvizieR object
#' 
#' @description
#' \code{mapvizieR} is a workhorse workflow function that
#' calls a sequence of cdf and roster prep functions, given a cdf and roster
#' 
#' @param cdf a NWEA AssessmentResults.csv or CDF
#' @param roster a NWEA students
#' @param verbose should mapvizieR print status updates?  default is FALSE.
#' @param ... additional arguments to pass to constructor functions called by mapvizieR
#' @examples
#'\dontrun{
#' cdf_mv <- mapvizieR(ex_CombinedAssessmentResults, 
#'                     ex_CombinedStudentsBySchool)
#'                     
#' is.mapvizieR(cdf_mv)                     
#' }
#' @export

mapvizieR <- function(cdf, roster, verbose = FALSE, ...) UseMethod("mapvizieR")

#' @export
mapvizieR.default <- function(cdf, roster, verbose = FALSE, ...) {

  cdf_status <- try(check_processed_cdf(cdf)$boolean, silent = TRUE)
  cdf_status <- all(!class(cdf_status)=="try-error" & cdf_status == TRUE)
  
  #prep the cdf, if necessary.
  if (cdf_status) {
    
    processed_cdf <- cdf
    
    if (verbose) {print('your CDF is ready to go!')}
  } else {
    
    if (verbose) {print('preparing and processing your CDF...')}
    
    #FIRST, prep the cdf and the roster
    prepped_cdf <- prep_cdf_long(cdf)
    roster <- prep_roster(roster)
    
    #SECOND, given a roster and cdf, grade level-ify the cdf
    prepped_cdf$grade <- grade_levelify_cdf(prepped_cdf, roster)
  
    #THIRD, process the cdf
    processed_cdf <- process_cdf_long(prepped_cdf)
  
    #check to see that result conforms
    assertthat::assert_that(check_processed_cdf(processed_cdf)$boolean)  
  }
  
  #headline growth df
  if (verbose) {print('calculating growth scores for students...')}
  growth_df <- generate_growth_dfs(processed_cdf, ...)$headline
  
  #TODO: goal growth df
  
  #make a list and return it
  mapviz <-  list(
    'cdf'=processed_cdf,
    'roster'=roster,
    'growth_df'=growth_df
    #todo: also return a goal/strand df
    #todo: add some analytics about matched/unmatched kids
  )
  
  class(mapviz) <- "mapvizieR"
  
  # the next step runs the accelerated growth calculations with the
  # default of KIPP Tiered growth.  This step must come after the 
  # class assignement since add_accelerated_growth can only be run 
  # on a mapvizieR class object by design (simplifies code and can be
  # run after creating a mapvizieR object to increas goal objects attached).
  
  mapviz <- mapviz %>% 
    add_accelerated_growth(
      goal_function = goal_kipp_tiered,  
      goal_function_args = list(iterations=1),
      update_growth_df = TRUE
  )
  
  mapviz[['growth_df']] <- determine_growth_status(mapviz[['growth_df']])
   
  return(mapviz)
}



#' @title Reports whether x is a mapvizier object
#'
#' @description
#' Reports whether x is a mapvizier object
#' @param x an object to test
#' @export

is.mapvizieR <- function(x) inherits(x, "mapvizieR")



#' @title ensure_is_mapvizieR
#' 
#' @description a contract that ensures that an object is a mapvizieR object at runtime.
#' 
#' @param . dot-placeholder, per ensurer doc.

ensure_is_mapvizieR <- ensurer::ensures_that(
  is.mapvizieR(.) ~ paste0("The object you passed is not a conforming mapvizieR object.\n",
     "Look at the examples in the mapvizieR() to see more about generating\n",
     "a valid mapvizieR object.")
)



#' @title print method for \code{mapvizier} class
#'
#' @description
#'  prints to console
#'
#' @details Prints a summary fo the a \code{mapvizier} object. 
#' 
#' @param x a \code{mapvizier} object
#' @param ... additional arguments
#' 
#' @return some details about the object to the console.
#' @rdname print
#' @examples 
#'\dontrun{
#' data(ex_CombinedAssessmentResults)
#' data(ex_CombinedStudentsBySchool)
#' 
#' cdf_mv <- mapvizieR(ex_CombinedAssessmentResults, 
#'                     ex_CombinedStudentsBySchool)
#'                     
#' cdf_mv
#' }
#' @export

print.mapvizieR <-  function(x, ...) {
  
  #gather some summary stats
  n_df <- length(x)
  n_sy <- length(unique(x$cdf$map_year_academic))
  min_sy <- min(x$cdf$map_year_academic)
  max_sy <- max(x$cdf$map_year_academic)
  n_students <- length(unique(x$cdf$studentid))
  n_schools <- length(unique(x$cdf$schoolname))
  growthseasons <- unique(x$growth_df$growth_window)
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
  matched_cdf <- dplyr::left_join(prepped_cdf, slim_roster, by=c('studentid', 'termname'))

  exact_count <- nrow(!is.na(matched_cdf$grade))
  
  #if there are still unmatched students, attempt to match on map_year_academic
  if (nrow(matched_cdf[is.na(matched_cdf$grade), ]) > 0) {
    
    slim_roster <- unique(roster[, c('studentid', 'map_year_academic', 'grade')])
    
    secondary_match <- dplyr::left_join(
      prepped_cdf, 
      slim_roster, by=c('studentid', 'map_year_academic') 
    )
    
    matched_cdf$grade <- ifelse(
      is.na(matched_cdf$grade), secondary_match$grade, matched_cdf$grade
    )
  } 
  
  return(matched_cdf$grade)
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
  assertthat::assert_that(
    check_cdf_long(assessment_results)$boolean, 
    check_roster(roster)
  )
  
  # inner join of roster and assessment results by id, subject, and term name
  matched_df <-  dplyr::inner_join(
    roster, 
    assessment_results %>% dplyr::filter(growthmeasureyn == TRUE),
    by = c("studentid", "termname", "schoolname")
  ) %>%
    # drop repeated columns
    dplyr::select(-ends_with(".y")) %>% 
    as.data.frame
  
  # drop .x join artifact from colun names (we dropped .y in select above )
  names(matched_df) <- gsub("(.+)(\\.x)", "\\1", names(matched_df))
  
  #check that number of rows of assessment_results = nrow of matched_df
  input_rows <- nrow(assessment_results)
  output_rows <- nrow(matched_df)
  
  if (input_rows != output_rows) {
    cdf_name <- substitute(assessment_results)
    msg <- paste0("The number of rows in ", cdf_name, " is ", input_rows, 
                  ", while the number of rows in the matched data frame\n",
                  "returned by this function is ", output_rows, ".\n\n",
                  "You might want to check your data.")
    warning(msg)
  }
  
  #return 
  matched_df
}
