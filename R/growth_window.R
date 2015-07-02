#' Extract likely growth window 
#' 
#' @description utility function to determine the best growth window from the data presented
#'
#' @param mapvizieR_obj a mapvizier object
#' @param studentids the studentids in question
#' @param measurementscale a NWEA MAP measurementscale
#' @param end_fws desired end of growth term (season)
#' @param end_academic_year desired end of growth term (year)
#' @param candidate_start_fws two seasons to pick from
#' @param candidate_year_offsets if prev spring, -1
#' @param candidate_prefer which one is the 'best' term?
#' @param tolerance revert to the other term if this one is below the tolerance
#'
#' @return  a list with inferred start season and year
#' @export

auto_growth_window <- function(
  mapvizieR_obj, 
  studentids,
  measurementscale,
  end_fws, 
  end_academic_year,
  candidate_start_fws = c('Fall', 'Spring'),
  candidate_year_offsets = c(0, -1),
  candidate_prefer = 'Spring',
  tolerance = 0.5,
  ...
) {
  #data validation
  mv_opening_checks(mapvizieR_obj, studentids, 1)
   
  assertthat::assert_that(length(candidate_start_fws) == 2)

  #NSE problems... :(
  measurementscale_in <- measurementscale
  
  this_growth <- mapvizieR_obj[['growth_df']] %>%
    dplyr::filter(
      studentid %in% studentids & 
        end_map_year_academic == end_academic_year &
        end_fallwinterspring == end_fws &
        start_fallwinterspring %in% candidate_start_fws &
        measurementscale == measurementscale_in &
        complete_obsv == TRUE
    )

  exists_test <- candidate_prefer %in% unique(this_growth$start_fallwinterspring)
  coverage_test <- sum(this_growth$start_fallwinterspring == candidate_prefer) / length(unique(this_growth$studentid))
  
  if (all(exists_test & coverage_test > tolerance)) {
    inferred_start_fws <- candidate_prefer
    inferred_start_academic_year <- end_academic_year + candidate_year_offsets[candidate_start_fws == candidate_prefer]
  } else {
    inferred_start_fws <- candidate_start_fws[candidate_start_fws != candidate_prefer]
    inferred_start_academic_year <- end_academic_year + candidate_year_offsets[candidate_start_fws != candidate_prefer]
  }
   
  return(
    list(inferred_start_fws, inferred_start_academic_year)
  )

}