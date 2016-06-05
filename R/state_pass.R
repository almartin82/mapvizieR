state_pass_prob <- function(mapvizieR_obj, state = 'NY') {
  
  cdf <- mapvizieR_obj$cdf

  cdf %>%
    dplyr::sample_n(50) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      predicted_perf = ny_linking(
        measurementscale, grade, fallwinterspring, testritscore)
    )
        
}