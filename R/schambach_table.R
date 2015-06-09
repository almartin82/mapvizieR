#' @title schambach_table
#' 
#' @description use similar methods in quealy_subgroups to create tables based on tables
#' Lindsay Schambach is making. initial cut will be on schools
#' 
#' @param mapvizieR_obj mapvizieR object
#' @param measurementscale_is target subject
#' @param grade target grade
#' @param subgroup_cols what subgroups, in addition to end_schoolname, in mapvizier roster do you want to cut by?
#' @param pretty_names nicely formatted names for the column cuts used above.
#' @param start_fws starting season
#' @param start_academic_year starting academic year
#' @param end_fws ending season
#' @param end_academic_year ending academic year
#' @param complete_obsv if TRUE, limit only to students who have BOTH a start
#' and end score. default is FALSE.
#' 
#' @export

schambach_table <- function(
  mapvizieR_obj, 
  measurementscale_is,
  grade,
  subgroup_cols,
  pretty_names,
  start_fws,
  start_academic_year,
  end_fws,
  end_academic_year,
  complete_obsv = FALSE
) {
  
  if (missing(subgroup_cols) | missing(pretty_names)) {
    subgroup_cols <- c('end_schoolname')
    pretty_names <- c('School Name')
  } else {
    subgroup_cols <- c('end_schoolname',subgroup_cols)
    pretty_names <- c('School Name',pretty_names)
  }
  
  #data validation and unpack
  assertthat::assert_that(length(subgroup_cols) == length(pretty_names))
  
  #unpack the mapvizieR object and limit to desired students
  roster <- mapvizieR_obj[['roster']]
  
  #limit to desired grade level
  growth_df <- mapvizieR_obj[['growth_df']]
  growth_df <- growth_df %>% 
    dplyr::filter(
      end_grade == grade,
      measurementscale == measurementscale_is
    )
  
  #just desired terms
  this_growth <- growth_df %>%
    dplyr::filter(
      start_map_year_academic == start_academic_year,
      start_fallwinterspring == start_fws,
      end_map_year_academic == end_academic_year,
      end_fallwinterspring == end_fws
    )
  
  grades_present <- unique(this_growth$start_grade)
  
  if(length(grades_present) > 1) {
    warning(
      sprintf(paste0("%i distinct grade levels present in your data! NWEA ",
                     "school growth study tables assume cohorts composed of students ",
                     "of the *same grade level*.  quealy_subgroups will use the mean starting grade ",
                     "level to calculate growth scores, but you are advised to check your data and  ",
                     "attempt to use a cohort composed of students from the same grade."), 
              length(grades_present))
    )
  }
  
  roster <- dplyr::left_join(
    x = roster,
    y = this_growth[ ,c('studentid','end_schoolname')],
    by = 'studentid'
  )
  
  roster %>% 
    ensurer::ensure_that(
      all(subgroup_cols %in% names(roster)) ~ "subgroup_cols must match column names in your mapvizieR roster."
    )
  
  if (complete_obsv == TRUE) {
    this_growth <- this_growth %>%
      dplyr::filter(
        complete_obsv == TRUE  
      )
  }
  
  group_summary <- function(grouped_df, subgroup) {
    
    df <- grouped_df %>%
      summarize(
        end_rit = mean(end_testritscore, na.rm=TRUE),
        start_top75 = sum(start_testpercentile >= 75) / nrow(grouped_df),
        end_top75 = sum(end_testpercentile >= 75) / nrow(grouped_df),
        avg_pg = mean(end_testpercentile - start_testpercentile,na.rm=TRUE),
        p_ku = sum(met_typical_growth, na.rm=TRUE) / nrow(grouped_df),
        p_rr = sum(met_accel_growth, na.rm=TRUE) / nrow(grouped_df),
        n = n()
      ) %>% 
      as.data.frame
    
    #names(df)[names(df) == subgroup] <- 'facet_me'
    
    df
  }
  
  tables <- list()
  for (i in 1:length(subgroup_cols)) {
    subgroup <- subgroup_cols[i]
    #join roster and data
    minimal_roster <- roster[, c('studentid', 'map_year_academic', 
                                 'fallwinterspring','end_schoolname', subgroup)]
    combined_df <- dplyr::inner_join(
      x = this_growth,
      y = minimal_roster,
      by = c('studentid' = 'studentid', 
             'start_map_year_academic' = 'map_year_academic', 
             'start_fallwinterspring' = 'fallwinterspring',
             'end_schoolname' = 'end_schoolname')
    )
    
    #now group by subgroup and summarize
    grouped_df <- dplyr::group_by_(combined_df, subgroup)
    this_summary <- group_summary(grouped_df, subgroup)
    tables[[i]] <- this_summary
  }
  
  tables
}