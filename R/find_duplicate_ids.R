#' Find's duplicate roster ids and attempts to fix them by collapsing
#'
#' @param students_by_school the StudentsBySchool roster as a data.frame
#'
#' @return a data.frame if collapsible, otherwise a message
#' @export

# Looking at PCA data for problematic names

# load data ####

# map_pca <- 
#   read_cdf("~/Dropbox (Personal)/NumberSense LLC/Projects/PCA/data")
# 
# map_pca$students_by_school %>% 
#   group_by(StudentID, TermName) %>% 
#   summarize(N=n()) %>% 
#   filter(N>1)
# 
# map_pca$students_by_school %>% 
#   filter(StudentID == 5613) %>%
#   select(TermName, StudentID, StudentFirstName, StudentLastName, Grade)

find_duplicate_ids <- function(students_by_school) {
  
  
  df <- students_by_school
  names(df) <- tolower(names(df))
  
  # find all duplicate term_ids
  
  get_duplicate_counts <- function(x) {
    x %>% 
      dplyr::group_by(termname, studentid) %>%
      dplyr::summarize(N = n()) %>%
      dplyr::filter(N > 1)
  }
  
  duplicates <- get_duplicate_counts(df)
  
  # if duplicates > 0 then see if any can be eliminated by unique 
  # and inform user
  if (nrow(duplicates) > 0) {
    df_duplicates <- df %>% 
      dplyr::filter(studentid %in% duplicates$studentid)
    
    
    n_duplicates <- nrow(df_duplicates)
    
    df_duplicates_collapsed <- df_duplicates %>% unique
    
    n_collapsed <- nrow(df_duplicates_collapsed)
    
    problem_duplicates_counts <- get_duplicate_counts(df_duplicates_collapsed) %>%
      dplyr::filter(N > 1) 
    
    
    
    df_problem_duplicates <- df %>% 
      dplyr::inner_join(problem_duplicates_counts %>%
                          dplyr::select(-N),
                        by=c("studentid", "termname"))
    
    
    
    
    n_problems <- nrow(df_problem_duplicates)
    
    if (n_problems == 0 ) {
      message(sprintf(
        "There are %s duplicates, but they all can be collapsed.",
        n_collapsed))
      
      return()
    
      } else {
        message(sprintf("These data have %s duplicated rows.", n_duplicates))
        message(sprintf("There are %s collapsable duplicates.", n_collapsed))
        warning(sprintf("%s duplicate records with conflicting data. They are:", n_problems))
        
        df_problem_duplicates
        }
  }
}