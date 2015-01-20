#' @title lower_df_names
#'
#' @description
#' \code{lower_df_names} a utility function to take any cdf and return it with 
#' lowercase names
#'
#' @param x a data frame
#' 
#' @return data frame with modified names

lower_df_names <- function(x) {
  
  names(x) <- tolower(names(x))
  
  return(x)
}
