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
  out <- dplyr::group_by(df, ...)

  #restore class info - prepend mapvizieR_data but keep dplyr classes
  new_classes <- class(out)
  class(out) <- c('mapvizieR_data', new_classes[!new_classes == 'mapvizieR_data'])

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

  #restore class info - prepend mapvizieR_data but keep dplyr classes
  new_classes <- class(out)
  class(out) <- c('mapvizieR_data', new_classes[!new_classes == 'mapvizieR_data'])

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
  #infinite calls back to select_.mapvizieR_data
  class(df) <- old_classes[!old_classes == 'mapvizieR_data']

  #call normal select (should go to dplyr)
  out <- dplyr::select(df, ...)

  #restore class info - prepend mapvizieR_data but keep dplyr classes
  new_classes <- class(out)
  class(out) <- c('mapvizieR_data', new_classes[!new_classes == 'mapvizieR_data'])

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

  #call normal filter (should go to dplyr)
  out <- dplyr::filter(df, ...)

  #restore class info - prepend mapvizieR_data but keep dplyr classes
  new_classes <- class(out)
  class(out) <- c('mapvizieR_data', new_classes[!new_classes == 'mapvizieR_data'])

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

  #call normal arrange (should go to dplyr)
  out <- dplyr::arrange(df, ...)

  #restore class info - prepend mapvizieR_data but keep dplyr classes
  new_classes <- class(out)
  class(out) <- c('mapvizieR_data', new_classes[!new_classes == 'mapvizieR_data'])

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

  #call normal mutate (should go to dplyr)
  out <- dplyr::mutate(df, ...)

  #restore class info - prepend mapvizieR_data but keep dplyr classes
  new_classes <- class(out)
  class(out) <- c('mapvizieR_data', new_classes[!new_classes == 'mapvizieR_data'])

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

  #call normal summarize (should go to dplyr)
  out <- dplyr::summarize(df, ...)

  #restore class info - prepend mapvizieR_data but keep dplyr classes
  new_classes <- class(out)
  class(out) <- c('mapvizieR_data', new_classes[!new_classes == 'mapvizieR_data'])

  out
}