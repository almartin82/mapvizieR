#' @title schambach_fig
#' 
#' @description Produces list of figures from list of data.frames returned by schambach_table_1d
#' 
#' @param mapvizieR_obj mapvizieR object
#' @param measurementscale_in target subject
#' @param studentids_in target studentids
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

schambach_figure <- function(
  mapvizieR_obj, 
  measurementscale_in,
  studentids_in,
  subgroup_cols = c('grade'),
  pretty_names = c('Grade'),
  start_fws,
  start_academic_year,
  end_fws,
  end_academic_year,
  complete_obsv = FALSE
) {
  
  schambach_dflist <- schambach_table_1d(
    mapvizieR_obj,
    measurementscale_in,
    studentids_in,
    subgroup_cols,
    pretty_names,
    start_fws,
    start_academic_year,
    end_fws,
    end_academic_year,
    complete_obsv
  )
  
  formatter <- function(df) {
    for (i in 3:7) {
      df[, i] <- paste0(df[[i]], '%')
    }
    df
  }
  
  tables <- list()
    for (i in 1:length(schambach_dflist)) {
      df <- schambach_dflist[[i]]
      df <- formatter(df)
      
      col_names <- c(paste(pretty_names[[i]]), 'Avg. Ending\n RIT', 'Percent Started\n in Top 75%',
               'Percent Ended\n in Top 75%', 'Avg. Percentile\n Growth', 'Percent Met\n Typical Growth',
               'Percent Met\n Accel Growth', 'Number of\n Students')
      t <- gridExtra::tableGrob(
        df,
        cols = col_names,
        theme = ttheme_default(
          core = list(
            fg_params = list(fontsize = 9, just = "center"),
            bg_params = list(alpha = c(.5,1), fill = 'lightgreen')),
            colhead = list(
              fg_params = list(fontsize = 10, fontface = "bold", col = "black")
            )
        )
      )
                                
     tables[[i]] <- t
    }
  
  out <- do.call(
    what = "grid.arrange", args = c(tables, c(nrow = length(tables)))
  )
  
  return(out)
}