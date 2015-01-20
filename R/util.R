#' @title lower_df_names
#'
#' @description
#' \code{lower_df_names} a utility function to take a data frame and return it with 
#' lowercase names
#'
#' @param x a data frame
#' 
#' @return data frame with modified names

lower_df_names <- function(x) {
  
  names(x) <- tolower(names(x))
  
  return(x)
}



#' @title extract_academic_year
#'
#' @description
#' \code{extract_academic_year} break up the termname field into year and fallwinterspring
#'
#' @param x a data frame
#' 
#' @return data frame with disambiguated termname and map_year_academic
#' 
extract_academic_year <- function(x) {
  
  prep1 <- do.call(
    what = rbind,
    args = strsplit(x = x$termname, split = " ", fixed = T)
  )
  
  x$fallwinterspring <- prep1[ ,1]

  #the academic year of the test date
  prep2 <- do.call(
    what = rbind,
    args = strsplit(x = prep1[ , 2], split = "-", fixed = T)
  )
  
  x$map_year_academic <- prep2[ ,1]
  
  return(x)
}