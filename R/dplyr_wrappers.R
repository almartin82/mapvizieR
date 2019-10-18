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
#' @export group_by_.mapvizieR_data

group_by_.mapvizieR_data <- function(df, ...) {
  
  #store the incoming class info
  old_classes <- class(df)
  
  #strip mavpvizieR_data class so that method dispatch doesn't lead to 
  #infinite calls back to group_by_.mapvizieR_data
  class(df) <- old_classes[!old_classes == 'mapvizieR_data']
  
  #call normal group_by (should go to dplyr)
  out <- dplyr::group_by_(df, ...)
  
  #restore class info
  class(out) <- old_classes
  
  out
}



#' ungroup wrapper
#'
#' @description wrapper for ungroup that preserves classes of data frames
#' @param df data.frame
#' @param ... additional args
#' @rdname ungroup
#' 
#' @return data.frame
#' @export ungroup.mapvizieR_data


ungroup.mapvizieR_data <- function(df, ...) {
  
  #store the incoming class info
  old_classes <- class(df)
  
  #strip mavpvizieR_data class so that method dispatch doesn't lead to 
  #infinite calls
  class(df) <- old_classes[!old_classes == 'mapvizieR_data']
  
  #call normal ungroup (should go to dplyr)
  out <- dplyr::ungroup(df, ...)
  
  #restore class info
  class(out) <- old_classes
  
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
#' @export select_.mapvizieR_data

select_.mapvizieR_data <- function(df, ...) {
  
  #store the incoming class info
  old_classes <- class(df)
  
  #strip mavpvizieR_data class so that method dispatch doesn't lead to 
  #infinite calls back to group_by_.mapvizieR_data
  class(df) <- old_classes[!old_classes == 'mapvizieR_data']
  
  #call normal group_by (should go to dplyr)
  out <- dplyr::select_(df, ...)
  
  #restore class info
  class(out) <- old_classes
  
  out
}


#' filter wrapper
#'
#' @description wrapper for filter that preserves classes of data frames
#' @param df data.frame
#' @param ... additional args
#' @rdname filter
#' 
#' @return data.frame
#' @export filter_.mapvizieR_data

filter_.mapvizieR_data <- function(df, ...) {
  
  #store the incoming class info
  old_classes <- class(df)
  
  #strip mavpvizieR_data class so that method dispatch doesn't lead to infinite calls
  class(df) <- old_classes[!old_classes == 'mapvizieR_data']
  
  #call normal (should go to dplyr)
  out <- dplyr::filter_(df, ...)
  
  #restore class info
  class(out) <- old_classes
  
  out
}



#' arrange wrapper
#'
#' @description wrapper for arrange that preserves classes of data frames
#' @param df data.frame
#' @param ... additional args
#' @rdname arrange
#' 
#' @return data.frame
#' @export arrange_.mapvizieR_data

arrange_.mapvizieR_data <- function(df, ...) {
  
  #store the incoming class info
  old_classes <- class(df)
  
  #strip mavpvizieR_data class so that method dispatch doesn't lead to infinite calls
  class(df) <- old_classes[!old_classes == 'mapvizieR_data']
  
  #call normal (should go to dplyr)
  out <- dplyr::arrange_(df, ...)
  
  #restore class info
  class(out) <- old_classes
  
  out
}



#' mutate wrapper
#'
#' @description wrapper for mutate that preserves classes of data frames
#' @param df data.frame
#' @param ... additional args
#' @rdname mutate
#' 
#' @return data.frame
#' @export mutate_.mapvizieR_data

mutate_.mapvizieR_data <- function(df, ...) {
  
  #store the incoming class info
  old_classes <- class(df)
  
  #strip mavpvizieR_data class so that method dispatch doesn't lead to infinite calls
  class(df) <- old_classes[!old_classes == 'mapvizieR_data']
  
  #call normal (should go to dplyr)
  out <- dplyr::mutate_(df, ...)
  
  #restore class info
  class(out) <- old_classes
  
  out
}



#' summarize wrapper
#'
#' @description wrapper for summarize that preserves classes of data frames
#' @param df data.frame
#' @param ... additional args
#' @rdname summarize
#' 
#' @return data.frame
#' @export summarize_.mapvizieR_data

summarize_.mapvizieR_data <- function(df, ...) {
  
  #store the incoming class info
  old_classes <- class(df)
  
  #strip mavpvizieR_data class so that method dispatch doesn't lead to infinite calls
  class(df) <- old_classes[!old_classes == 'mapvizieR_data']
  
  #call normal (should go to dplyr)
  out <- dplyr::summarize_(df, ...)
  
  #restore class info
  class(out) <- old_classes
  
  out
}