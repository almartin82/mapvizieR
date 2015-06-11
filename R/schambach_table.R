#' @title schambach_table
#' 
#' @description Given grade level, shows summary table for provided subgroups.
#' 
#' @param mapvizieR_obj mapvizieR object
#' @param measurementscale_is target subject
#' @param grade target grade(s)
#' @param subgroup_cols what subgroups to explore, default is by school
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
  measurementscale_is,
  grade,
  subgroup_cols = c('end_schoolname'),
  pretty_names = c('School Name'),
  start_fws,
  start_academic_year,
  end_fws,
  end_academic_year,
  complete_obsv = FALSE
) {
  
  #data validation and unpack
  assertthat::assert_that(length(subgroup_cols) == length(pretty_names))
  
  tables <- vector('list',length(grade))
  for (gr in grade) {
    #unpack the mapvizieR object and limit to desired students
    roster <- mapvizieR_obj[['roster']]
  
    #limit to desired grade level
    growth_df <- mapvizieR_obj[['growth_df']]
    growth_df <- growth_df %>% 
      dplyr::filter(
        end_grade == gr,
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
    
    group_summary <- function(grouped_df) {
      
      df <- grouped_df %>%
        summarize(
          end_rit = round(mean(end_testritscore, na.rm=TRUE), digits=1),
          start_top75 = round(100 * sum(start_testpercentile >= 75) / n(), digits=1),
          end_top75 = round(100 * sum(end_testpercentile >= 75) / n(), digits=1),
          avg_pg = round(mean((end_testpercentile - start_testpercentile), na.rm=TRUE), digits=1),
          p_ku = round(100 * sum(met_typical_growth, na.rm=TRUE) / n(), digits=1),
          p_rr = round(100 * sum(met_accel_growth, na.rm=TRUE) / n(), digits=1),
          n = n()
        ) %>% 
        as.data.frame
      
      df
    }
    
    sub_tables <- list()
    for (i in 1:length(subgroup_cols)) {
      subgroup <- subgroup_cols[i]
      
      #join roster and data
      if (subgroup == 'end_schoolname') {
        minimal_roster <- roster[, c('studentid', 'map_year_academic', 
                                     'fallwinterspring')]
      } else {
        minimal_roster <- roster[, c('studentid','map_year_academic',
                                     'fallwinterspring','end_schoolname',subgroup)]
      }
      
      combined_df <- dplyr::inner_join(
        x = this_growth,
        y = minimal_roster,
        by = c('studentid' = 'studentid', 
               'start_map_year_academic' = 'map_year_academic', 
               'start_fallwinterspring' = 'fallwinterspring')
      )
      
      #first row: summary of entire grade level
      row1 <- c(
        paste('Total: Grade',gr),
        round(mean(combined_df$end_testritscore, na.rm=TRUE), digits=1),
        round(100 * sum(combined_df$start_testpercentile >= 75) / nrow(combined_df), digits=1),
        round(100 * sum(combined_df$end_testpercentile >= 75) / nrow(combined_df), digits=1),
        round(mean((combined_df$end_testpercentile - combined_df$start_testpercentile), na.rm=TRUE), digits=1),
        round(100 * sum(combined_df$met_typical_growth, na.rm=TRUE) / nrow(combined_df), digits=1),
        round(100 * sum(combined_df$met_accel_growth, na.rm=TRUE) / nrow(combined_df), digits=1),
        nrow(combined_df)
      )
      
      #now group by subgroup and summarize
      grouped_df <- dplyr::group_by_(combined_df, subgroup)
      this_summary <- group_summary(grouped_df)
      names(this_summary) <- c(pretty_names[i],'Avg. Ending RIT', 'Percent Started in Top 75%',
                               'Percent Ended in Top 75%', 'Avg. Percentile Growth',
                               'Percent Meeting KU', 'Percent Meeting RR','Number of Students')
      
      sub_tables[[i]] <- rbind(row1,this_summary)
      for (c in 2:ncol(sub_tables[[i]])) {
        sub_tables[[i]][,c] <- as.numeric(sub_tables[[i]][,c])
      }
    }
    names(sub_tables) <- tolower(gsub(' ', '_', pretty_names))
    if (length(grade) == 1) {
      return(sub_tables)
    } else {
      tables[[match(gr,grade)]] <- sub_tables
    }
  }
  names(tables) <- paste0('grade_',grade)
  tables
}