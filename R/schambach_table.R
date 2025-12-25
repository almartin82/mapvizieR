#' @title schambach_table
#' 
#' @description \code{schambach_table} Given grade level(s), shows summary table for provided subgroups.
#' Table includes average ending RIT, percent started in top 75%, percented ended in 75%, average
#' percentile growth, percent meeting "Keep Up", percent meeting "Rutgers Ready", and the number of 
#' students in each subgroup. Named after Lindsay Schambach, who provided initial table.
#' 
#' @param mapvizieR_obj mapvizieR object
#' @param measurementscale_in target subject
#' @param studentids target studentids
#' @param subgroup_cols what subgroups to explore, default is by grade
#' @param pretty_names nicely formatted names for the column cuts used above.
#' @param start_fws starting season
#' @param start_academic_year starting academic year
#' @param end_fws ending season
#' @param end_academic_year ending academic year
#' @param complete_obsv if TRUE, limit only to students who have BOTH a start
#' and end score. default is FALSE.
#' 
#' @export

schambach_table_1d <- function(
  mapvizieR_obj, 
  measurementscale_in,
  studentids,
  subgroup_cols = c('grade'),
  pretty_names = c('Grade'),
  start_fws,
  start_academic_year,
  end_fws,
  end_academic_year,
  complete_obsv = FALSE
) {
  
  #data validation and unpack
  assertthat::assert_that(length(subgroup_cols) == length(pretty_names))
  
  #unpack the mapvizieR object and limit to desired students
  roster <- mapvizieR_obj$roster
  
  #limit to desired studentids and measurementscale
  growth_df <- mv_limit_growth(mapvizieR_obj, studentids, measurementscale_in)
  
  #just desired terms
  this_growth <- growth_df %>%
    dplyr::filter(
      start_map_year_academic == start_academic_year,
      start_fallwinterspring == start_fws,
      end_map_year_academic == end_academic_year,
      end_fallwinterspring == end_fws
    )

  if (!all(subgroup_cols %in% names(roster))) {
    cli::cli_abort("subgroup_cols must match column names in your mapvizieR roster.")
  }

  if (complete_obsv == TRUE) {
    this_growth <- this_growth %>%
      dplyr::filter(
        complete_obsv == TRUE  
      )
  }
  
  tables <- list()
  for (i in 1:length(subgroup_cols)) {
    subgroup <- subgroup_cols[i]
    
    minimal_roster <- roster[, c('studentid', 'map_year_academic', 'fallwinterspring', subgroup)]
    
    combined_df <- roster_to_growth_df(
      target_df = this_growth,
      mapvizieR_obj = mapvizieR_obj,
      roster_cols = subgroup_cols,
      join_by = 'end'
    )
    
    schambach_pipe <- . %>%
      dplyr::summarize(
        end_rit = mean(end_testritscore, na.rm = TRUE) %>% round(1),
        pct_start_75 = mean(start_testpercentile >= 75, na.rm = TRUE) %>% multiply_by(100) %>% round(0),
        pct_end_75 = mean(end_testpercentile >= 75, na.rm = TRUE) %>% multiply_by(100) %>% round(0),
        ptile_change = mean((end_testpercentile - start_testpercentile), na.rm = TRUE) %>% round(1),
        pct_typ = mean(met_typical_growth, na.rm = TRUE) %>% multiply_by(100) %>% round(0),
        pct_accel = mean(met_accel_growth, na.rm = TRUE) %>% multiply_by(100) %>% round(0),
        n = dplyr::n()
      )
    
    #first row: summary of first cut
    row1 <- combined_df %>%
      dplyr::ungroup() %>%
      dplyr::mutate(foo = 'All Students') %>%
      dplyr::group_by(foo) %>%
      schambach_pipe()
    
    names(row1)[1] <- pretty_names[i]
    
    #now group by subgroup and summarize
    this_summary <- combined_df %>%
      dplyr::group_by(.data[[subgroup]]) %>%
      schambach_pipe()
    this_summary[,1] <- as.character(this_summary[[1]])
    names(this_summary)[1] <- pretty_names[i]
    
    this_summary <- dplyr::bind_rows(row1, this_summary)
    
    names(this_summary) <- c(pretty_names[i], 'Avg. Ending RIT', 'Percent Started in Top 75%',
                             'Percent Ended in Top 75%', 'Avg. Percentile Growth',
                             'Percent Met Typical Growth', 'Percent Met Accel Growth', 'Number of Students')
    
    tables[[i]] <- this_summary
  }
  
  tables
}