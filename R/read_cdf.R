#' Reads CDF csv files from a director
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
#'
#' @examples
#' \dontrun{
#' cdf<-read_cdf("data/")
#' 
#' str(cdf)
#' }
#' 
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
  assessments_list <- lapply(assessment_files, read.csv, stringsAsFactors = FALSE)
  
  students_list <- lapply(student_files, read.csv, stringsAsFactors = FALSE)
  
  class_list <- lapply(class_files, read.csv, stringsAsFactors = FALSE)
  
  accommodation_list <- lapply(accommodation_files, read.csv, stringsAsFactors = FALSE)
  
  programs_list <- lapply(program_files, read.csv, stringsAsFactors = FALSE)
 
  
  # rbind_list each list
  if (verbose) message("Stacking separate CDF tables into single data frames")
  
  assessemnt_results <- dplyr::rbind_all(assessments_list)
  if (nrow(assessemnt_results) == 0) warning("Your AssessmentResults files lack data.")
    
  students_by_school <- dplyr::rbind_all(students_list)
  if (nrow(students_by_school) == 0) warning("Your StudentsBySchool files lack data.")
  
  class_assignments <- dplyr::rbind_all(class_list)
  if (nrow(class_assignments) == 0) message("Your ClassAssignments files lack data.")
  
  accommodation_assignments <- dplyr::rbind_all(accommodation_list)
  if (nrow(accommodation_assignments) == 0) message("Your AccommodationAssignments files lack data.")
  
  program_assignments <- dplyr::rbind_all(programs_list)
  if (nrow(program_assignments) == 0) message("Your ProgramAssignments files lack data.")
  
  
  #drop students if given a list of bad studentids
  if (class(bad_students) == 'numeric') {

    bad_stu_filter <- function(df, studentid_vector) {
      if(nrow(df) > 0) {
        df %>% dplyr::filter(!StudentID %in% studentid_vector)
      } else { df }
    }
    
    assessemnt_results <- bad_stu_filter(assessemnt_results, bad_students)
    students_by_school <- bad_stu_filter(students_by_school, bad_students)
    class_assignments <- bad_stu_filter(class_assignments, bad_students)
    accommodation_assignments <- bad_stu_filter(accommodation_assignments, bad_students)
    program_assignments <- bad_stu_filter(program_assignments, bad_students)
  }

  
  #Construct output object with each set of files as member of list
  cdf_out <- list(assessemnt_results = assessemnt_results, 
                 students_by_school = students_by_school,
                 class_assignments = class_assignments,
                 accommodation_assignments = accommodation_assignments,
                 program_assignments = program_assignments)
 
  #return object
  cdf_out
}