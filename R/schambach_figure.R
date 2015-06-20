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
#' @param report title text grob to put on report
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
  report_title = NA, 
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
      df[, i] <- paste0(df[, i], '%')
    }
    df
  }
  
  if (!is.na(report_title)) {
    title <- h_var(report_title, 16)
  } else {
    title <- h_var('Provide a Title', 16)
  }
  
  tables <- list()
#   if (length(schambach_dflist) == 1) {
    for (i in 1:length(schambach_dflist)) {
      df <- schambach_dflist[[i]]
      df <- formatter(df)
      
      col <- c(paste(pretty_names[[i]]), 'Avg. Ending\n RIT', 'Percent Started\n in Top 75%',
               'Percent Ended\n in Top 75%', 'Avg. Percentile\n Growth', 'Percent Met\n Typical Growth',
               'Percent Met\n Accel Growth', 'Number of\n Students')
      t <- gridExtra::tableGrob(df,
                                gpar.corefill = grid::gpar(fill = 'lightgreen', alpha = 0.5, col = NA),
                                h.even.alpha = 1,
                                h.odd.alpha = 0.5,
                                v.even.alpha = 1,
                                v.odd.alpha = 1,
                                core.just = 'center',
                                rows = c(),
                                cols = col,
                                col.just = 'center',
                                gpar.coretext = grid::gpar(fontsize = 10),
                                gpar.coltext = grid::gpar(fontsize = 12, fontface = 'bold', separator = 'black'),
                                gpar.rowtext = grid::gpar(fontsize = 12, fontface = 'bold', separator = 'black'),
                                show.box = TRUE
      )
     tables[[i]] <- gridExtra::arrangeGrob(grob_justifier(title, 'center', 'bottom'),
                                           grob_justifier(t, 'center', 'top'),
                                           nrow = 2,
                                           heights = c(1, 4)
                                           )
    }
    return(tables)
}