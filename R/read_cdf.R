read_cdf <- function(path = ".",
                     verbose = TRUE) {
  
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
 
  # rbind_list eahc list
  if (verbose) message("Stacking separate CDF tables into single data frames")
  
  assessemnt_results <- dplyr::rbind_all(assessments_list)
 
  students_by_school <- dplyr::rbind_all(students_list)
  
  class_assignments <- dplyr::rbind_all(class_list)
  
  accommodation_assignments <- dplyr::rbind_all(accommodation_list)
  
  program_assignments <- dplyr::rbind_all(programs_list)
 
 # Construct output object with each set of files as member of list
  cdf_out <- list(assessemnt_results = assessemnt_results, 
                 students_by_school = students_by_school,
                 class_assignments = class_assignments,
                 accommodation_assignments = accommodation_assignments,
                 program_assignments = program_assignments)
 
 #return object
 cdf_out
}