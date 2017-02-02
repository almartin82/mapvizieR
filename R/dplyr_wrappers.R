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
  out <- dplyr::group_by_(df, ...)
  
  #restore class info
  new_classes <- class(out)
  all_classes <- c(new_classes, old_classes) %>% unique() %>% sort()
  sorted_classes <- wrapper_class_orderer(all_classes)
  class(out) <- sorted_classes
  
  out
}



#' class orderer for dplyr wrappers
#'
#' @param all_classes character vector of class names
#'
#' @return character vector of classes with anything `mapviz` sorted first
#' @export

wrapper_class_orderer <- function(all_classes) {

  #force mapviz classes first
  is_mapviz <- grepl('mapviz', all_classes) 
  
  #starting position
  sort_order <- seq(1:length(all_classes))
  sort_order <- sort_order + 1000
  sort_order[is_mapviz] <- sort_order[is_mapviz] - 50
  
  sorted_classes <- all_classes[rank(sort_order)]
  
  sorted_classes
}


#' ungroup wrapper
#'
#' @description wrapper for ungroup that preserves classes of data frames
#' @param df data.frame
#' @param ... additional args
#' @rdname ungroup
#' 
#' @return data.frame
#' @export

ungroup_.mapvizieR_data <- function(df, ...) {
  
  #store the incoming class info
  old_classes <- class(df)
  
  #strip mavpvizieR_data class so that method dispatch doesn't lead to 
  #infinite calls back to group_by_.mapvizieR_data
  class(df) <- old_classes[!old_classes == 'mapvizieR_data']
  
  #call normal group_by (should go to dplyr)
  out <- dplyr::ungroup(df, ...)
  
  #restore class info
  new_classes <- class(out)
  all_classes <- c(new_classes, old_classes) %>% unique() %>% sort()
  sorted_classes <- wrapper_class_orderer(all_classes)
  class(out) <- sorted_classes
  
  out
}


#' select wrapper
#'
#' @description wrapper for select that preserves classes of data frames
#' @param df data.frame
#' @param ... additional args
#' @rdname select
#' 
#' @return data.frame
#' @export

select_.mapvizieR_data <- function(df, ...) {
  
  #store the incoming class info
  old_classes <- class(df)
  
  #strip mavpvizieR_data class so that method dispatch doesn't lead to 
  #infinite calls back to group_by_.mapvizieR_data
  class(df) <- old_classes[!old_classes == 'mapvizieR_data']
  
  #call normal group_by (should go to dplyr)
  out <- dplyr::select_(df, ...)
  
  #restore class info
  new_classes <- class(out)
  all_classes <- c(new_classes, old_classes) %>% unique() %>% sort()
  sorted_classes <- wrapper_class_orderer(all_classes)
  class(out) <- sorted_classes
  
  out
}