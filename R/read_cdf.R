#' @title Reads CDF csv files from a director
#'
#' @description utility function to read in multiple NWEA files, if dir is known.
#'
#' @param path the path to the CSV files as character vector
#' @param verbose defaults is TRUE
#' @param bad_students StudentIDs to ignore
#'
#' @return a list holding data frames with of stacked longitudinal MAP data.  
#' There are slots for each CSV provided in a test session by NWEA: 
#' `assessment_results`, `students_by_school`, `class_assignments`, 
#' `accommodation_assignments`, and `program_assignments`.
#' 
#' @export
#' @examples
#' \dontrun{
#' cdf <- read_cdf("data/")
#' 
#' str(cdf)
#' }

read_cdf <- function(
  path = ".",
  verbose = TRUE,
  bad_students = NA
) {
  
  # Read in assessmentResults and StudentsBy school filenames
  if (verbose) message("Reading path names to CDF files")
  assessment_files <- dir(path = path, 
                          pattern = "AssessmentResults",
                          ignore.case = TRUE,
                          recursive = TRUE,
                          full.names = TRUE)
  
  student_files <- dir(path = path, 
                       pattern = "StudentsBySchool",
                       ignore.case = TRUE,
                       recursive = TRUE,
                       full.names = TRUE)
 
  
  class_files <- dir(path = path, 
                       pattern = "ClassAssignments",
                       ignore.case = TRUE,
                       recursive = TRUE,
                       full.names = TRUE)
  
  accommodation_files <- dir(path = path, 
                     pattern = "AccommodationAssignment",
                     ignore.case = TRUE,
                     recursive = TRUE,
                     full.names = TRUE)
  
 
  program_files <- dir(path = path, 
                             pattern = "ProgramAssignments",
                             ignore.case = TRUE,
                             recursive = TRUE,
                             full.names = TRUE)
   
  
  # Write files to list objects
  if (verbose) message("Reading CSV files.")
  assessments_list <- lapply(
    assessment_files, read.csv, stringsAsFactors = FALSE, colClasses = 'character'
  )
  students_list <- lapply(
    student_files, read.csv, stringsAsFactors = FALSE, colClasses = 'character'
  )
  class_list <- lapply(
    class_files, read.csv, stringsAsFactors = FALSE, colClasses = 'character'
  )
  accommodation_list <- lapply(
    accommodation_files, read.csv, stringsAsFactors = FALSE, colClasses = 'character'
  )
  programs_list <- lapply(
    program_files, read.csv, stringsAsFactors = FALSE, colClasses = 'character'
  )
 
  
  # rbind_list each list
  if (verbose) message("Stacking separate CDF tables into single data frames")
  
  assessement_results <- dplyr::bind_rows(assessments_list)
  if (nrow(assessement_results) == 0) message("Your AssessmentResults files lack data.")
    
  students_by_school <- dplyr::bind_rows(students_list)
  if (nrow(students_by_school) == 0) message("Your StudentsBySchool files lack data.")
  
  class_assignments <- dplyr::bind_rows(class_list)
  if (nrow(class_assignments) == 0) message("Your ClassAssignments files lack data.")
  
  accommodation_assignments <- dplyr::bind_rows(accommodation_list)
  if (nrow(accommodation_assignments) == 0) message("Your AccommodationAssignments files lack data.")
  
  program_assignments <- dplyr::bind_rows(programs_list)
  if (nrow(program_assignments) == 0) message("Your ProgramAssignments files lack data.")
  
  #clean up types on assessment and students by school
  assessement_results <- readr::type_convert(
    df = assessement_results, 
    col_types = readr::cols(
      TestStartDate = readr::col_date(format = '%m/%d/%Y'), 
      TestStartTime = readr::col_character()
    )
  )
  
  students_by_school <- readr::type_convert(
    df = students_by_school
  )
  
  #drop students if given a list of bad studentids
  if (class(bad_students) == 'numeric') {
    if (verbose) message("Filtering bad studentids from data frames.")

    bad_stu_filter <- function(df, studentid_vector) {
      if(nrow(df) > 0) {
        df %>% dplyr::filter(!StudentID %in% studentid_vector)
      } else { df }
    }
    
    assessement_results <- bad_stu_filter(assessement_results, bad_students)
    students_by_school <- bad_stu_filter(students_by_school, bad_students)
    class_assignments <- bad_stu_filter(class_assignments, bad_students)
    accommodation_assignments <- bad_stu_filter(accommodation_assignments, bad_students)
    program_assignments <- bad_stu_filter(program_assignments, bad_students)
  }

  
  #Construct output object with each set of files as member of list
  cdf_out <- list(assessement_results = assessement_results, 
                 students_by_school = students_by_school,
                 class_assignments = class_assignments,
                 accommodation_assignments = accommodation_assignments,
                 program_assignments = program_assignments)
 
  #return object
  cdf_out
}



#' @title replace known bad studentids with good ones 
#' 
#' @description if you've identified some bad studentids in your map data file, 
#' you'll want to make sure that they are globally updated to good ones.  this function
#' takes the output of read cdf and a data frame of studentids to change, and updates
#' the bad references with good ones.
#' 
#' ultimately you'll want to push these changes upstream to the NWEA site, but in a
#' pinch, clean_cdf can help
#'
#' @param cdf_list the output of read cdf
#' @param ids_df a data frame with the bad studentid, and the good replacement.
#' look at the default parameter value to see how to pass the data.
#' @param verbose default is TRUE
#' 
#' @export
#' @return same output as read_cdf, a list of NWEA MAP data files
 
clean_cdf <- function(
  cdf_list, 
  ids_df = data.frame(
      'bad_id' = c('INCORRECT STUDENTID #1'),
      'good_id' = c('CORRECTED STUDENTID #1')
    ),
  verbose = TRUE
  ) {
  
  #first, take the UNIQUES from students by school
  nrow_before <- nrow(cdf_list$students_by_school)
  cdf_list$students_by_school <- unique(cdf_list$students_by_school)
  nrow_after <- nrow(cdf_list$students_by_school)
  if (verbose) {
    print(
      paste('Dropped', nrow_before - nrow_after, 
          'duplicate students from the students_by_school file.')
    )
  }
  
  #if there's a duplication, 
  sub_studentid <- function(df, bad_id, good_id) {
    if (nrow(df) == 0) {
      df
    } else {
      df[df$StudentID == bad_id, 'StudentID'] <- good_id
      df
    }
  }
  
  for (i in 1:nrow(ids_df)) {
    if (verbose) {
      student <- cdf_list$students_by_school[
        cdf_list$students_by_school$StudentID == ids_df[i, 'bad_id'], 
        c('StudentFirstName', 'StudentLastName')] %>% as.data.frame()
      
      print(
        paste('cleaning bad id for', student[1, 'StudentFirstName'], 
              student[1, 'StudentLastName'])
      )
    }
    
    cdf_list$assessement_results <- sub_studentid(
      cdf_list$assessement_results, ids_df[i, 'bad_id'], ids_df[i, 'good_id']
    )

    cdf_list$students_by_school <- sub_studentid(
      cdf_list$students_by_school, ids_df[i, 'bad_id'], ids_df[i, 'good_id']
    )

    cdf_list$class_assignments <- sub_studentid(
      cdf_list$class_assignments, ids_df[i, 'bad_id'], ids_df[i, 'good_id']
    )

    cdf_list$accommodation_assignments <- sub_studentid(
      cdf_list$accommodation_assignments, ids_df[i, 'bad_id'], ids_df[i, 'good_id']
    )
    
    cdf_list$program_assignments <- sub_studentid(
      cdf_list$program_assignments, ids_df[i, 'bad_id'], ids_df[i, 'good_id']
    )
  }
  
  return(cdf_list)
}
