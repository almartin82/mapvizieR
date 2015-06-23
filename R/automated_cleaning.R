#' @title surfaces missing students by school data for a user creating a new mv object
#'
#' @param raw_sbs
#'
#' @return nothing; simply prints out information about the students by school
#'  
#' @export
#'
#' @examples
#' \dontrun{
#' cdf<-read_cdf("data/")
#' 
#' str(cdf)
#' }


sbs_missing <- function(raw_sbs) {
  total_count <- 0
  for (i in seq_along(raw_sbs)) {
    mask <- raw_sbs[, i] == "" | is.na(raw_sbs[, i])
    
    total_count <- total_count + sum(mask)
    
    if (sum(mask) > 0){
      warn_string <- paste(
        'NOTE: there are', sum(mask), 'rows with missing values in the', 
        names(raw_sbs)[[i]], 'column of the students_by_school file'
      )
  
      message(warn_string)
    }
  }
  
  if (total_count == 0) {
    message('Good news: All columns in your students_by_school file have no blank values!')
  }
}
