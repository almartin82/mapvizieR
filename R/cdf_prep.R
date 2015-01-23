#' @title prep_cdf_long
#'
#' @description
#' \code{prep_cdf_long} a wrapper around several cdf prep functions
#'
#' @param cdf_long a map assessmentresults.csv file.  can be one term, or many terms
#' together in one file.
#' 
#' @return a prepped cdf file
#' 
#' @export

prep_cdf_long <- function(cdf_long) {
  
  cdf_long <- cdf_long %>% 
    #names
    lower_df_names() %>%
    #fallwinterspring, academic_year
    extract_academic_year()  
  
  assert_that(check_cdf_long(cdf_long)$boolean)
  
  return(cdf_long)
}



#' @title dedupe_cdf
#'
#' @description
#' \code{dedupe_cdf} makes sure that the cdf only contains one row student/subject/term 
#'
#' @param prepped_cdf conforming prepped cdf file.
#' @param method can choose between c('NWEA', 'high RIT', 'most recent').  
#' Default is NWEA method.
#' 
#' @return a data frame with one row per kid
#' 
#' @export

dedupe_cdf <- function(prepped_cdf, method="NWEA") {
  #verify inputs
  assert_that(
    is.data.frame(prepped_cdf),
    method %in% c("NWEA", "high RIT", "most recent"),
    check_cdf_long(prepped_cdf)$boolean
  )

  #reminder: if you want the highest value for an element to rank 1, 
    #throw a negative sign in front of the variable
    #if you want the lowest to rank 1, leave as is.
  rank_methods <- list(
    "NWEA" = "-growthmeasureyn, teststandarderror",
    "high RIT" = "-testritscore",
    "most recent" = "-teststartdate"
  )
  
  #pull the method off the list
  use_method <- rank_methods[[method]]
  do_call_rank_with_method <- paste0("do.call(rank, list(", use_method, "))")  
  
  #dedupe using dplyr mutate
  dupe_tagged <- prepped_cdf %>%
    group_by(studentid, measurementscale, map_year_academic, fallwinterspring) %>%
    #using mutate_ because we want to hand our function to mutate as a string. 
    mutate_(
      rn=do_call_rank_with_method
    )  
  deduped <- dupe_tagged[dupe_tagged$rn==1, ]
  
  return(deduped)
}
