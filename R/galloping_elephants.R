#' @title RIT distribution change (affectionately titled 'Galloping Elephants')
#'
#' @description
#' \code{galloping_elephants} returns ggplot density distributions that show change
#'  in RIT over time
#'
#' @param prepped_cdf_long a conforming cdf_long_prepped data frame. run \code{prep_cdf_long} 
#' to get into proper format.
#' @param prepped_roster a conforming roster data frame.
#' @param first_and_spring_only show all terms, or only entry & spring?  default is TRUE.
#' @param entry_grades  which grades are entry grades?
#' 
#' @return a ggplot object.
#' 
#' @export


galloping_elephants <- function (
  prepped_cdf_long,
  prepped_roster,
  first_and_spring_only=TRUE,
  entry_grades = c(-0.8, 4.2)
  ) {
  #test if the incoming data conforms to specs
  assert_that(check_cdf_long(prepped_cdf_long)$boolean)
  assert_that(check_roster(prepped_roster)$boolean)
  
  #munge data to get desired terms
  
  
  #get counts by term (for labels)
  
  
  #make and return the plot
  
}