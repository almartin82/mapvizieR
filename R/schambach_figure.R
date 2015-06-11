#' @title schambach_fig
#' 
#' @description Produce figures from list of data.frames returned by schambach_table_1d
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

schambach_figure <- function(
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
  
  schambach_dflist <- schambach_table_1d(
    mapvizieR_obj,
    measurementscale_is,
    grade,
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
      df[,i] <- paste0(df[,i], '%')
    }
    df
  }
  
  tables <- list()
  if (length(grade) == 1) {
    for (i in 1:length(schambach_dflist)) {
      df <- schambach_dflist[[i]]
      df <- formatter(df)
      
      col <- c(paste(pretty_names[[i]]), 'Avg. Ending\n RIT', 'Percent Started\n in Top 75%',
               'Percent Ended\n in Top 75%', 'Avg. Percentile\n Growth', 'Percent Meeting\n KU',
               'Percent Meeting\n RR', 'Number of\n Students')
      t <- gridExtra::grid.table(df,
                                 gpar.corefill = gpar(fill = 'lightgreen', alpha = 0.5, col = NA),
                                 h.even.alpha = 1,
                                 h.odd.alpha = 0.5,
                                 v.even.alpha = 1,
                                 v.odd.alpha = 1,
                                 core.just = 'center',
                                 rows = c(),
                                 cols = col,
                                 col.just = 'center',
                                 gpar.coretext = gpar(fontsize = 10),
                                 gpar.coltext = gpar(fontsize = 12, fontface = 'bold', separator = 'black'),
                                 gpar.rowtext = gpar(fontsize = 12, fontface = 'bold', separator = 'black'),
                                 show.box = TRUE
      )
     tables[[i]] <- t
    }
#     final <- do.call('grid.arrange', c(tables, nrow=length(schambach_dflist)))
#     return(final)
    final <- do.call('arrangeGrob', c(tables, nrow = length(schambach_dflist)))
    return(final)
  } else {
    count <- 1
    for (i in 1:length(schambach_dflist)) {
      for (n in 1:length(subgroup_cols)) {
        df <- schambach_dflist[[i]][[n]]
        df <- formatter(df)
        
        col <- c(paste(pretty_names[n]), 'Avg. Ending\n RIT', 'Percent Started\n in Top 75%',
                 'Percent Ended\n in Top 75%','Avg. Percentile\n Growth', 'Percent Meeting\n KU',
                 'Percent Meeting\n RR', 'Number of\n Students')
        t <- gridExtra::grid.table(df,
                                  gpar.corefill = gpar(fill = 'lightgreen', alpha = 0.5, col = NA),
                                  h.even.alpha = 1,
                                  h.odd.alpha = 0.5,
                                  v.even.alpha = 1,
                                  v.odd.alpha = 1,
                                  core.just = 'center',
                                  rows = c(),
                                  cols = col,
                                  col.just = 'center',
                                  gpar.coretext = gpar(fontsize = 10, fontface = 'bold'),
                                  gpar.coltext = gpar(fontsize = 12, fontface = 'bold', separator = 'black'),
                                  gpar.rowtext = gpar(fontsize = 12, fontface = 'bold', separator = 'black'),
                                  show.box = TRUE
        )
        tables[[count]] <- t
        count <- count + 1
      }
#       final <- do.call('grid.arrange', c(tables, nrow = length(subgroup_cols)))
#       tables <- list()
      final <- do.call('arrangeGrob', c(tables, nrow = count-1))
      return(final)
    }
  }
}