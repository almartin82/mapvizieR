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
#' @param .data data.frame
#' @param ... additional args
#' @param .add see \code{\link[dplyr]{group_by}}
#' @param .drop see \code{\link[dplyr]{group_by}}
#' @rdname group_by
#'
#' @return data.frame
#' @export
#' @method group_by mapvizieR_data

group_by.mapvizieR_data <- function(.data, ..., .add = FALSE, .drop = dplyr::group_by_drop_default(.data)) {

 #store the incoming class info
 old_classes <- class(.data)

 #strip mapvizieR_data class so that method dispatch doesn't lead to
 #infinite calls back to group_by.mapvizieR_data
 class(.data) <- old_classes[!old_classes == 'mapvizieR_data']

 #call normal group_by (should go to dplyr)
 out <- dplyr::group_by(.data, ..., .add = .add, .drop = .drop)

 #restore class info - prepend mapvizieR_data but keep dplyr classes
 new_classes <- class(out)
 class(out) <- c('mapvizieR_data', old_classes[old_classes %in% c('mapvizieR_cdf', 'mapvizieR_growth')],
                 new_classes[!new_classes %in% c('mapvizieR_data', 'mapvizieR_cdf', 'mapvizieR_growth')])

 out
}



#' ungroup wrapper
#'
#' @description wrapper for ungroup that preserves classes of data frames
#' @param x data.frame
#' @param ... additional args
#' @rdname ungroup
#'
#' @return data.frame
#' @export
#' @method ungroup mapvizieR_data

ungroup.mapvizieR_data <- function(x, ...) {

 #store the incoming class info
 old_classes <- class(x)

 #strip mapvizieR_data class so that method dispatch doesn't lead to
 #infinite calls
 class(x) <- old_classes[!old_classes == 'mapvizieR_data']

 #call normal ungroup (should go to dplyr)
 out <- dplyr::ungroup(x, ...)

 #restore class info - prepend mapvizieR_data but keep dplyr classes
 new_classes <- class(out)
 class(out) <- c('mapvizieR_data', old_classes[old_classes %in% c('mapvizieR_cdf', 'mapvizieR_growth')],
                 new_classes[!new_classes %in% c('mapvizieR_data', 'mapvizieR_cdf', 'mapvizieR_growth')])

 out
}


#' select wrapper
#'
#' @description wrapper for select that preserves classes of data frames
#' @param .data data.frame
#' @param ... additional args
#' @rdname select
#'
#' @return data.frame
#' @export
#' @method select mapvizieR_data

select.mapvizieR_data <- function(.data, ...) {

 #store the incoming class info
 old_classes <- class(.data)

 #strip mapvizieR_data class so that method dispatch doesn't lead to
 #infinite calls back to select.mapvizieR_data
 class(.data) <- old_classes[!old_classes == 'mapvizieR_data']

 #call normal select (should go to dplyr)
 out <- dplyr::select(.data, ...)

 #restore class info - prepend mapvizieR_data but keep dplyr classes
 new_classes <- class(out)
 class(out) <- c('mapvizieR_data', old_classes[old_classes %in% c('mapvizieR_cdf', 'mapvizieR_growth')],
                 new_classes[!new_classes %in% c('mapvizieR_data', 'mapvizieR_cdf', 'mapvizieR_growth')])

 out
}


#' filter wrapper
#'
#' @description wrapper for filter that preserves classes of data frames
#' @param .data data.frame
#' @param ... additional args
#' @param .by see \code{\link[dplyr]{filter}}
#' @param .preserve see \code{\link[dplyr]{filter}}
#' @rdname filter
#'
#' @return data.frame
#' @export
#' @method filter mapvizieR_data

filter.mapvizieR_data <- function(.data, ..., .by = NULL, .preserve = FALSE) {

 #store the incoming class info
 old_classes <- class(.data)

 #strip mapvizieR_data class so that method dispatch doesn't lead to infinite calls
 class(.data) <- old_classes[!old_classes == 'mapvizieR_data']

 #call normal filter (should go to dplyr)
 out <- dplyr::filter(.data, ..., .by = {{ .by }}, .preserve = .preserve)

 #restore class info - prepend mapvizieR_data but keep dplyr classes
 new_classes <- class(out)
 class(out) <- c('mapvizieR_data', old_classes[old_classes %in% c('mapvizieR_cdf', 'mapvizieR_growth')],
                 new_classes[!new_classes %in% c('mapvizieR_data', 'mapvizieR_cdf', 'mapvizieR_growth')])

 out
}



#' arrange wrapper
#'
#' @description wrapper for arrange that preserves classes of data frames
#' @param .data data.frame
#' @param ... additional args
#' @param .by_group see \code{\link[dplyr]{arrange}}
#' @rdname arrange
#'
#' @return data.frame
#' @export
#' @method arrange mapvizieR_data

arrange.mapvizieR_data <- function(.data, ..., .by_group = FALSE) {

 #store the incoming class info
 old_classes <- class(.data)

 #strip mapvizieR_data class so that method dispatch doesn't lead to infinite calls
 class(.data) <- old_classes[!old_classes == 'mapvizieR_data']

 #call normal arrange (should go to dplyr)
 out <- dplyr::arrange(.data, ..., .by_group = .by_group)

 #restore class info - prepend mapvizieR_data but keep dplyr classes
 new_classes <- class(out)
 class(out) <- c('mapvizieR_data', old_classes[old_classes %in% c('mapvizieR_cdf', 'mapvizieR_growth')],
                 new_classes[!new_classes %in% c('mapvizieR_data', 'mapvizieR_cdf', 'mapvizieR_growth')])

 out
}



#' mutate wrapper
#'
#' @description wrapper for mutate that preserves classes of data frames
#' @param .data data.frame
#' @param ... additional args
#' @rdname mutate
#'
#' @return data.frame
#' @export
#' @method mutate mapvizieR_data

mutate.mapvizieR_data <- function(.data, ...) {

 #store the incoming class info
 old_classes <- class(.data)

 #strip mapvizieR_data class so that method dispatch doesn't lead to infinite calls
 class(.data) <- old_classes[!old_classes == 'mapvizieR_data']

 #call normal mutate (should go to dplyr)
 out <- dplyr::mutate(.data, ...)

 #restore class info - prepend mapvizieR_data but keep dplyr classes
 new_classes <- class(out)
 class(out) <- c('mapvizieR_data', old_classes[old_classes %in% c('mapvizieR_cdf', 'mapvizieR_growth')],
                 new_classes[!new_classes %in% c('mapvizieR_data', 'mapvizieR_cdf', 'mapvizieR_growth')])

 out
}



#' summarize wrapper
#'
#' @description wrapper for summarize that preserves classes of data frames
#' @param .data data.frame
#' @param ... additional args
#' @param .by see \code{\link[dplyr]{summarize}}
#' @param .groups see \code{\link[dplyr]{summarize}}
#' @rdname summarize
#'
#' @return data.frame
#' @export
#' @method summarize mapvizieR_data

summarize.mapvizieR_data <- function(.data, ..., .by = NULL, .groups = NULL) {

 #store the incoming class info
 old_classes <- class(.data)

 #strip mapvizieR_data class so that method dispatch doesn't lead to infinite calls
 class(.data) <- old_classes[!old_classes == 'mapvizieR_data']

 #call normal summarize (should go to dplyr)
 out <- dplyr::summarize(.data, ..., .by = {{ .by }}, .groups = .groups)

 #restore class info - prepend mapvizieR_data but keep dplyr classes
 new_classes <- class(out)
 class(out) <- c('mapvizieR_data', old_classes[old_classes %in% c('mapvizieR_cdf', 'mapvizieR_growth')],
                 new_classes[!new_classes %in% c('mapvizieR_data', 'mapvizieR_cdf', 'mapvizieR_growth')])

 out
}

# Additional wrappers for mapvizieR_growth and mapvizieR_cdf classes
# These classes don't always inherit from mapvizieR_data

#' @export
#' @method group_by mapvizieR_growth
group_by.mapvizieR_growth <- function(.data, ..., .add = FALSE, .drop = dplyr::group_by_drop_default(.data)) {
  old_classes <- class(.data)
  class(.data) <- old_classes[!old_classes %in% c('mapvizieR_growth', 'mapvizieR_data')]
  out <- dplyr::group_by(.data, ..., .add = .add, .drop = .drop)
  new_classes <- class(out)
  class(out) <- c('mapvizieR_growth', new_classes[!new_classes == 'mapvizieR_growth'])
  out
}

#' @export
#' @method group_by mapvizieR_cdf
group_by.mapvizieR_cdf <- function(.data, ..., .add = FALSE, .drop = dplyr::group_by_drop_default(.data)) {
  old_classes <- class(.data)
  class(.data) <- old_classes[!old_classes %in% c('mapvizieR_cdf', 'mapvizieR_data')]
  out <- dplyr::group_by(.data, ..., .add = .add, .drop = .drop)
  new_classes <- class(out)
  class(out) <- c('mapvizieR_cdf', new_classes[!new_classes == 'mapvizieR_cdf'])
  out
}

#' @export
#' @method ungroup mapvizieR_growth
ungroup.mapvizieR_growth <- function(x, ...) {
  old_classes <- class(x)
  class(x) <- old_classes[!old_classes %in% c('mapvizieR_growth', 'mapvizieR_data')]
  out <- dplyr::ungroup(x, ...)
  new_classes <- class(out)
  class(out) <- c('mapvizieR_growth', new_classes[!new_classes == 'mapvizieR_growth'])
  out
}

#' @export
#' @method ungroup mapvizieR_cdf
ungroup.mapvizieR_cdf <- function(x, ...) {
  old_classes <- class(x)
  class(x) <- old_classes[!old_classes %in% c('mapvizieR_cdf', 'mapvizieR_data')]
  out <- dplyr::ungroup(x, ...)
  new_classes <- class(out)
  class(out) <- c('mapvizieR_cdf', new_classes[!new_classes == 'mapvizieR_cdf'])
  out
}

#' @export
#' @method select mapvizieR_growth
select.mapvizieR_growth <- function(.data, ...) {
  old_classes <- class(.data)
  class(.data) <- old_classes[!old_classes %in% c('mapvizieR_growth', 'mapvizieR_data')]
  out <- dplyr::select(.data, ...)
  new_classes <- class(out)
  class(out) <- c('mapvizieR_growth', new_classes[!new_classes == 'mapvizieR_growth'])
  out
}

#' @export
#' @method select mapvizieR_cdf
select.mapvizieR_cdf <- function(.data, ...) {
  old_classes <- class(.data)
  class(.data) <- old_classes[!old_classes %in% c('mapvizieR_cdf', 'mapvizieR_data')]
  out <- dplyr::select(.data, ...)
  new_classes <- class(out)
  class(out) <- c('mapvizieR_cdf', new_classes[!new_classes == 'mapvizieR_cdf'])
  out
}

#' @export
#' @method filter mapvizieR_growth
filter.mapvizieR_growth <- function(.data, ..., .by = NULL, .preserve = FALSE) {
  old_classes <- class(.data)
  class(.data) <- old_classes[!old_classes %in% c('mapvizieR_growth', 'mapvizieR_data')]
  out <- dplyr::filter(.data, ..., .by = {{ .by }}, .preserve = .preserve)
  new_classes <- class(out)
  class(out) <- c('mapvizieR_growth', new_classes[!new_classes == 'mapvizieR_growth'])
  out
}

#' @export
#' @method filter mapvizieR_cdf
filter.mapvizieR_cdf <- function(.data, ..., .by = NULL, .preserve = FALSE) {
  old_classes <- class(.data)
  class(.data) <- old_classes[!old_classes %in% c('mapvizieR_cdf', 'mapvizieR_data')]
  out <- dplyr::filter(.data, ..., .by = {{ .by }}, .preserve = .preserve)
  new_classes <- class(out)
  class(out) <- c('mapvizieR_cdf', new_classes[!new_classes == 'mapvizieR_cdf'])
  out
}

#' @export
#' @method mutate mapvizieR_growth
mutate.mapvizieR_growth <- function(.data, ...) {
  old_classes <- class(.data)
  class(.data) <- old_classes[!old_classes %in% c('mapvizieR_growth', 'mapvizieR_data')]
  out <- dplyr::mutate(.data, ...)
  new_classes <- class(out)
  class(out) <- c('mapvizieR_growth', new_classes[!new_classes == 'mapvizieR_growth'])
  out
}

#' @export
#' @method mutate mapvizieR_cdf
mutate.mapvizieR_cdf <- function(.data, ...) {
  old_classes <- class(.data)
  class(.data) <- old_classes[!old_classes %in% c('mapvizieR_cdf', 'mapvizieR_data')]
  out <- dplyr::mutate(.data, ...)
  new_classes <- class(out)
  class(out) <- c('mapvizieR_cdf', new_classes[!new_classes == 'mapvizieR_cdf'])
  out
}

#' @export
#' @method arrange mapvizieR_growth
arrange.mapvizieR_growth <- function(.data, ..., .by_group = FALSE) {
  old_classes <- class(.data)
  class(.data) <- old_classes[!old_classes %in% c('mapvizieR_growth', 'mapvizieR_data')]
  out <- dplyr::arrange(.data, ..., .by_group = .by_group)
  new_classes <- class(out)
  class(out) <- c('mapvizieR_growth', new_classes[!new_classes == 'mapvizieR_growth'])
  out
}

#' @export
#' @method arrange mapvizieR_cdf
arrange.mapvizieR_cdf <- function(.data, ..., .by_group = FALSE) {
  old_classes <- class(.data)
  class(.data) <- old_classes[!old_classes %in% c('mapvizieR_cdf', 'mapvizieR_data')]
  out <- dplyr::arrange(.data, ..., .by_group = .by_group)
  new_classes <- class(out)
  class(out) <- c('mapvizieR_cdf', new_classes[!new_classes == 'mapvizieR_cdf'])
  out
}

#' @export
#' @method summarize mapvizieR_growth
summarize.mapvizieR_growth <- function(.data, ..., .by = NULL, .groups = NULL) {
  old_classes <- class(.data)
  class(.data) <- old_classes[!old_classes %in% c('mapvizieR_growth', 'mapvizieR_data')]
  out <- dplyr::summarize(.data, ..., .by = {{ .by }}, .groups = .groups)
  new_classes <- class(out)
  class(out) <- c('mapvizieR_growth', new_classes[!new_classes == 'mapvizieR_growth'])
  out
}

#' @export
#' @method summarize mapvizieR_cdf
summarize.mapvizieR_cdf <- function(.data, ..., .by = NULL, .groups = NULL) {
  old_classes <- class(.data)
  class(.data) <- old_classes[!old_classes %in% c('mapvizieR_cdf', 'mapvizieR_data')]
  out <- dplyr::summarize(.data, ..., .by = {{ .by }}, .groups = .groups)
  new_classes <- class(out)
  class(out) <- c('mapvizieR_cdf', new_classes[!new_classes == 'mapvizieR_cdf'])
  out
}
