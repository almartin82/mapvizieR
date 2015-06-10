#' @title filter mapvizieR object
#'
#' @description filter a mapvizieR object by academic year, or any variable in the roster.
#' 
#' @param mapvizieR_obj mapvizieR object
#' @param cdf_filter a filter, or filters to apply on fields in the cdf.  wrap it in `quote()`
#' @param roster_filter a filter, or filters to apply on fields in the roster.  will also filter
#' the cdf to only return those students.  wrap it in `quote()`
#'
#' @return a filtered mapvizieR object
#' 
#' @export

mv_filter <- function(mapvizieR_obj, cdf_filter=NA, roster_filter=NA) {
  
  #must pass some kind of filter
  if (!is.language(cdf_filter) & !is.language(roster_filter)) {
    stop('at least one type of filter needed (cdf or roster)')
  }
  
  mapviz <- mapvizieR_obj
  
  #cdf fields
  if (typeof(cdf_filter) == 'language') {
    mapviz[['cdf']] <- mapviz[['cdf']] %>%
      dplyr::filter_(
        cdf_filter
      )
  }

  #roster fields
  if (typeof(roster_filter) == 'language') {
    #filter the roster
    mapviz[['roster']] <- mapviz[['roster']] %>%
      dplyr::filter_(
        roster_filter
      )
    
    target_stu <- mapviz[['roster']]$studentid
    
    #then use those studentids to filter the cdf
    mapviz[['cdf']] <-  mapviz[['cdf']] %>% 
      dplyr::filter(studentid %in% target_stu) 
  }
  
  return(mapviz)
}
