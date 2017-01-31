#' group_by wrapper
#'
#' @description wrapper for group_by that preserves classes of data frames
#' @param df data.frame
#' @param ... additional args
#'
#' @return data.frame
#' @export

group_by.mapvizieR_data <- function(df, ...) {

  cat('foo')
  old_classes <- class(df)
  out <- dplyr::group_by(df, ...)
  new_classes <- class(out)
  
  class(out) <- c(new_classes, old_classes) %>% unique()
  
  out
}