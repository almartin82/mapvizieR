#' @title makes data a mapvizieR_data object
#' 
#' @description I have absolutely no idea what I am doing.gif
#' 
#' @param df a data frame 
#' @export

mapvizieR_data <- function(df) UseMethod("mapvizieR_data")

#' @export
mapvizieR_data.default <- function(df) {

  class(df) <- c('mapvizieR_data', class(df))
  df
}


#' group_by wrapper
#'
#' @description wrapper for group_by that preserves classes of data frames
#' @param df data.frame
#' @param ... additional args
#' @rdname group_by
#' 
#' @return data.frame
#' @export

group_by_.mapvizieR_data <- function(df, ...) {
  
  #store the incoming class info
  old_classes <- class(df)
  
  #strip mavpvizieR_data class so that method dispatch doesn't lead to 
  #infinite calls back to group_by_.mapvizieR_data
  class(df) <- old_classes[!old_classes == 'mapvizieR_data']
  
  #call normal group_by (should go to dplyr)
  out <- group_by_(df, ...)
  
  #restore class info
  new_classes <- class(out)
  class(out) <- c(new_classes, old_classes) %>% unique()
  
  out
}
