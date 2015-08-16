impute_rit <- function(
  mapvizieR_object, 
  studentids, 
  measurementscale, 
  impute_method = 'simple_average'
  ) {
 
  #unpack the mapvizieR object and limit to desired students
  this_cdf <- mv_limit_cdf(mapvizieR_obj, studentids, measurementscale) %>%
    dplyr::tbl_df()

  if (impute_method == 'simple_average') {
    out <- impute_rit_simple_average(this_cdf)
  }
   
  out
}


impute_rit_simple_average <- function(df, interpolate_only = TRUE) {
  
  #cartesian product of students, terms and measurementscales
  unq_terms <- df$grade_level_season %>% unique()
  unq_stu <- df$studentid %>% unique()
  unq_subj <- df$measurementscale %>% unique()
  
  scaffold <- expand.grid(unq_stu, unq_terms, unq_subj)
  names(scaffold) <- c('studentid', 'grade_level_season', 'measurementscale')
  
  
  #join back
  scaffold <- scaffold %>%
    dplyr::left_join(df, by = c('studentid', 'grade_level_season', 'measurementscale')) %>%
    dplyr::arrange(
      studentid, measurementscale, grade_level_season
    ) %>%
    dplyr::tbl_df()
  
  
  scaffold$row_number <- rownames(scaffold) %>% as.numeric()
  for (i in 1:nrow(scaffold)) {
    #only the nas
    if (is.na(scaffold[i, 'testritscore'])) {
      mask_stu_subj <- scaffold$studentid == scaffold[['studentid']][i] & 
        scaffold$measurementscale == scaffold[['measurementscale']][i]
      
      print(i)
    }
  }
  
  scaffold %>%
    dplyr::group_by(
      studentid, measurementscale
    ) %>%
    dplyr::mutate(
      foo = 1+1
    ) %>%
    dplyr::arrange(
      studentid, measurementscale, grade_level_season
    ) %>%
    dplyr::select(
      studentid, grade_level_season, testritscore, foo
    )
  
}