localizations <- list(
  'default' = list(
    #cuts the ribbons in ACT rainbow/height weight plots
    'act_cuts' = c(11, 16, 18, 22, 25, 29),
    #indicates what act lines to highlight on plots
    'act_trace_lines' = c(11, 16, 18, 22, 25, 29),
    'canonical_colleges' = c(
      '2 year/Community',
      'Local Public',
      'Regional Public',
      'Flagship State',
      'Flagship State (Honors Program)',
      'Top 40'
    ),
    'grad_rates' = c(rep('', 6)),
    'fall_goals_data' = NA
  ),
  'Newark' = list(
    'act_cuts' = c(8, 16, 18, 21, 23, 26, 29),
    'act_trace_lines' = c(8, 16, 18, 21, 23, 26, 29, 32),
    'canonical_colleges' = c(
      'Essex County',
      'Bloomfield College',
      'Caldwell College',
      'Drew University',
      'Rutgers University',
      'Rutgers (Honors Program)',
      'Cornell'
    ),
    'grad_rates' = c('5%', '29%', '52%', '71%', '77%', '85%', '92%'),
    'fall_goals_data' = data.frame(
        report_measurementscale = c('Reading', 'Reading', 'Mathematics', 'Mathematics'),
        report_schooltype = c('ES', 'MS', 'ES', 'MS'),
        verbose_schooltype = c(rep('Elementary', 2), rep('Middle', 2)),
        annotate_x = c(4, 8, 4, 8),
        annotate_y = c(216, 231, 224, 244),
        xmin = c(-1, 3.9, -1, 3.9),
        xmax = c(4.2, 8.2, 4.2, 8.2),
        ymin = c(130, 195, 130, 195),
        ymax = c(230, 245, 230, 250),
        sim_start = c(139, 199, 138, 204),
        stringsAsFactors = FALSE
      )
  )
)

localize <- function(region, verbose = FALSE) {
  final_list <- list()
  #number of items
  loc_var <- names(localizations[['default']])
  #how many
  loc_var_count <- length(loc_var)
  
  counter <- 0
  #iterate over defaults
  for (i in loc_var) {
    #look up the item
    custom <- localizations[[region]][i]
    #if it's null, return the default.  otherwise, the custom value.
    if (is.null(custom)) {
      final_list[i] <- localizations[['default']][i]
      counter <- counter + 1
    } else {
      final_list[i] <- custom
    }
  }
  
  if (verbose == TRUE) {
    if (counter == loc_var_count) {
      cat('Your localization choice did not match any known options!
  To store a localization, add a list to localizations.
  For example:
    localizations[[\'Ridgemont High\']] <- list(
      \'act_cuts\' = c(12, 17, 19, 22, 24, 27, 32)
    )
  ')
    }
    
    if (loc_var_count - counter >= loc_var_count) {
      writeLines(sprintf('Localized %s variables', loc_var_count - counter))
    }
    
  }
    
  return(final_list)
}
