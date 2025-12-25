#' @title roster_to_cdf
#' 
#' @description  when you need to put a roster object onto a cdf.  reasonably easy because this is 
#' point in time data.
#' 
#' @param target_df the df you want to put stuff on
#' @param mapvizieR_obj a conforming mapvizieR object
#' @param roster_cols roster column names you want to move over. to move 'studentgender', pass 
#' the character string.  to move multiple columns, pass as
#' a vector: c('studentgender', 'studentethnicgroup')
#' @param by_measurementscale boolean, when you have student demographics that are specific to a 
#' particular assessment - eg course enrollment, but the match is specific to student AND
#' measurementscale, not just student.  if TRUE your roster object must contain a field
#' called measurementscale.
#' 
#' @export
#' @return a cdf data frame with the roster objects

roster_to_cdf <- function(
  target_df,
  mapvizieR_obj,
  roster_cols,
  by_measurementscale = FALSE
) {
  #opening checks
  if ('end_fallwinterspring' %in% names(target_df)) {
    cli::cli_abort("you provided a growth df, but this function is designed for the cdf. try roster_to_growth_df()")
  }
  if (!all(c('studentid', 'map_year_academic', 'fallwinterspring') %in% names(target_df))) {
    cli::cli_abort("c(studentid, map_year_academic, fallwinterspring) are minimum requirements for roster_to_cdf")
  }  
  
  #get the roster
  roster <- mapvizieR_obj$roster
  
  #collisions
  mask <- roster_cols %in% names(target_df)
  if (any(mask)) {
    target_df <- target_df %>% as.data.frame()
    inner_mask <- ! names(target_df) %in% roster_cols
    target_df <- target_df[, inner_mask]
  }
  
  #trim to basic cols (studentid, year, term, possibly measurementscale)
  basic_cols <- c('studentid', 'map_year_academic', 'fallwinterspring')
  if (by_measurementscale) basic_cols <- c(basic_cols, 'measurementscale')
  all_cols <- c(basic_cols, roster_cols)
  #this gets into the weeds, but:
  #per issue #175, *if the user provides* dupe stu enrollments (for instance,
  #if the student has dual/concurrent enrollment at two schools) we don't want
  #mapvizieR to rule that out.  but if we're in that world and NOT looking at 
  #the school attribute, we don't want to create duplicate rows.  so, unique()
  slim <- roster[, names(roster) %in% all_cols] %>% unique()
  
  #join
  target_df <- target_df %>%
    dplyr::ungroup() %>%
    dplyr::left_join(
      slim %>% dplyr::ungroup(),
      by = basic_cols
    )
  
  class(target_df) <- c("mapvizieR_cdf", class(target_df))

  return(target_df)
}




#' @title roster_to_growth_df
#'
#' @description when you need to put a roster object onto a growth data frame.
#' growth data frames are tricky, because they cover a time *span*, not a single point in time.
#' if a student changes school / grade / teacher (common) or if any of the other demographic attributes
#' of a student change (IEP status / lunch status / gender / etc.) you need to have a consistent rule for
#' attribution.  roster_to_growth_df implements that.
#'
#' @param target_df the df you want to put stuff on
#' @param mapvizieR_obj a conforming mapvizieR object
#' @param roster_cols roster column names you want to move over.
#' @param join_by c('start', 'end', 'both')
#' @param disambiguation_method how to disambiguate?  default is 'last'.
#' @param by_measurementscale boolean, when you have student demographics that are specific to a 
#' particular assessment - eg course enrollment, but the match is specific to student AND
#' measurementscale, not just student.  if TRUE your roster object must contain a field
#' called measurementscale.
#' 
#' @export
#' @return a growth data frame with the roster objects

roster_to_growth_df <- function(
  target_df,
  mapvizieR_obj,
  roster_cols,
  join_by = 'end', 
  disambiguation_method = 'last',
  by_measurementscale = FALSE
) {
  #opening checks
  if ('fallwinterspring' %in% names(target_df)) {
    cli::cli_abort("you provided a regular cdf, but this function is designed for the growth_df. try roster_to_cdf()")
  }
  
  #get the roster
  roster <- mapvizieR_obj$roster
  
  #what student year season pairs are in the target df?
  pairs <- target_df %>%
    dplyr::ungroup() %>%
    dplyr::select(
      studentid, start_map_year_academic, start_fallwinterspring,
      end_map_year_academic, end_fallwinterspring
    ) %>%
    unique() %>%
    as.data.frame(stringsAsFactors = FALSE)
  
  pairs$start_sort <- numeric_nwea_seasons(pairs$start_fallwinterspring) + pairs$start_map_year_academic
  pairs$end_sort <- numeric_nwea_seasons(pairs$end_fallwinterspring) + pairs$end_map_year_academic
  
  #get them in LONG format
  if (join_by == 'start') {
    pairs <- pairs[, c('studentid', 'start_sort')] %>%
      reshape2::melt(id.vars = 'studentid')
  } else if (join_by == 'end') {
    pairs <- pairs[, c('studentid', 'end_sort')] %>%
      reshape2::melt(id.vars = 'studentid')
  } else if (join_by == 'both') {
    pairs <- pairs[, c('studentid', 'start_sort', 'end_sort')] %>%
      reshape2::melt(id.vars = 'studentid')
  }
  
  #now subset the roster to only have the values 
  #first make year field
  roster$year_sort <- numeric_nwea_seasons(roster$fallwinterspring) + roster$map_year_academic
  roster$student_year_key <- paste0(roster$studentid, '@', roster$year_sort)
  #using that key we can limit our roster down to terms that exist in our incoming
  #growth df
  roster <- roster[roster$student_year_key %in% paste0(pairs$studentid, '@', pairs$value), ]
  
  #PREP FOR JOIN
  #now trim our roster to basic ids and roster_cols
  cols <- c('studentid', 'year_sort', roster_cols)
  if (by_measurementscale) cols <- c(cols, 'measurementscale')
  slim <- roster[, names(roster) %in% cols]
  
  #disambiguation - add rn tags by last, first
  slim <- slim %>%
    unique() %>%
    tibble::as_tibble()
  
  if (by_measurementscale) {
    slim <- slim
      dplyr::group_by(studentid, measurementscale)
  } else {
    slim <- slim %>%
      dplyr::group_by(studentid)
  }
  
  slim <- slim %>%
    dplyr::mutate(
      last_rn = rank(year_sort),
      first_rn = rank(-year_sort)
    )
  
  if (disambiguation_method == 'last') {
    slim <- slim %>% dplyr::filter(last_rn == 1)
  }
  if (disambiguation_method == 'first') {
    slim <- slim %>% dplyr::filter(first_rn == 1)
  }
  
  #NOW JOIN AND RETURN
  slim <- slim %>% dplyr::select(dplyr::one_of(cols)) %>%
    dplyr::select(-year_sort)
  
  if (by_measurementscale) {
    out <- target_df %>%
      dplyr::left_join(
        slim,
        by = c('measurementscale', 'studentid')
      )
  } else {
    out <- target_df %>%
      dplyr::left_join(
        slim,
        by = c('studentid')
      )
  }
  
  class(out) <- c("mapvizieR_growth", class(out)) %>% unique()
  
  return(out)
  
}