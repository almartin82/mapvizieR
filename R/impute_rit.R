impute_rit <- function(
  mapvizieR_object, 
  studentids, 
  measurementscale, 
  impute_method = 'average'
  ) {
 
  #unpack the mapvizieR object and limit to desired students
  this_cdf <- mv_limit_cdf(mapvizieR_obj, studentids, measurementscale)

  if (impute_method == 'average') {
    out <- impute_rit_by_average
  }
   
  out
}


impute_rit_by_average <- function(df, impute_only = TRUE) {
  
  #get unique terms
  unq_terms <- df$grade_level_season %>% unique()
  
  
  #join back to students
  df %>%
    left_join
  
  
  
  
  
}