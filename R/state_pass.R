#' calculate new york pass probability
#'
#' @param mapvizieR_obj conforming mapvizieR object
#'
#' @return cdf with predicted pass and predicted level

ny_pass_prob <- function(mapvizieR_obj) {
  
  cdf <- mapvizieR_obj$cdf

  out <- cdf %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      predicted_level = ny_linking(measurementscale, grade, fallwinterspring, testritscore),
      predicted_pass = ny_linking(
        measurementscale, grade, fallwinterspring, testritscore, returns = 'proficient')
    )
  
  out
}


#' state pass probability
#'
#' @param mapvizieR_obj a valid mapvizieR object
#' @param state_test name of the state test to calculate for
#'
#' @return a cdf with predicted pass and predicted level
#' @export

state_pass_prob <- function(mapvizieR_obj, state_test = 'NY') {
 
  valid_state_tests <- c('NY')
  state_test %>% ensurer::ensure_that(
    . %in% valid_state_tests ~ 
      paste0("currently supported state tests are: ", 
             paste(valid_state_tests, collapse = ', '),
             ' file a github issue for your state assessment!'
      )
  )
  
  do.call(
    paste0(tolower(state_test), '_pass_prob'), list('mapvizieR_obj' = mapvizieR_obj)
  )
}