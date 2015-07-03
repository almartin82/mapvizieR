#' @title quealy_subgroups
#' 
#' @description kevin quealy of the nytimes did a nice job capturing change 
#' in the general population vs change in specific subgroups: http://nyti.ms/1tQrOIl 
#' re: obamacare.
#' let's do the same thing for change in RIT score.
#' 
#' @param mapvizieR_obj mapvizieR object
#' @param studentids target students
#' @param measurementscale target subject
#' @param subgroup_cols what subgroups in mapvizier roster do you want to cut by?  default
#' is starting_quartile
#' @param pretty_names nicely formatted names for the column cuts used above.
#' @param start_fws one academic season (if known); pass vector of two and quealy subgroups will pick
#' @param start_year_offset 0 if start season is same, -1 if start is prior year.
#' @param end_fws ending season
#' @param end_academic_year ending academic year
#' @param start_fws_prefer which term is preferred? not required if only one start_fws is passed
#' @param report_title text grob to put on the report tile
#' @param complete_obsv if TRUE, limit only to students who have BOTH a start
#' and end score. default is FALSE.
#' @param drop_NA_groups should we ignore subgroups with value NA?  default is true
#' @param include_all should the output have plot at the top showing the TOTAL
#' variation?  not recommended for data spanning multiple grade levels.
#' 
#' @return a grob composed of multiple ggplots
#' 
#' @export

quealy_subgroups <- function(
  mapvizieR_obj, 
  studentids, 
  measurementscale,
  subgroup_cols = c('starting_quartile'),
  pretty_names = c('Starting Quartile'),
  start_fws,
  start_year_offset,
  end_fws,
  end_academic_year,
  start_fws_prefer = NA,
  report_title = NA,
  complete_obsv = FALSE,
  drop_NA_groups = TRUE,
  include_all = TRUE
) {
  
  #1. validation
  mv_opening_checks(mapvizieR_obj, studentids, 1)
  assertthat::assert_that(length(subgroup_cols) == length(pretty_names))
  
  #2. limit to kids, endpoint
  #nse problems?
  measurementscale <- measurementscale
  
  df <- mv_limit_growth(mapvizieR_obj, studentids, measurementscale) %>%
    dplyr::filter(
      end_map_year_academic == end_academic_year,
      end_fallwinterspring == end_fws
    )
  if (complete_obsv) {
    df <- df %>% dplyr::filter(complete_obsv == TRUE)
  }
  
  #3. put SUBGROUPS values from roster onto df
  df <- roster_to_growth_df(
    target_df = df,
    mapvizieR_obj = mapvizieR_obj,
    roster_cols = subgroup_cols
  )
  #put rownames back on the df
  df$persistent_names <- rownames(df)
  
  #4. for each SUBGROUP permutation
  all_sub <- subgroup_cols
  if (include_all) {
    #add all_students to df
    df$all_students <- 'All Students'
    #include in subgroups
    all_sub <- c('all_students', all_sub)
  }
  
  #df to hold the result
  window_df <- data.frame(
    subgroup = character(0), perm = character(0), 
    start_fws = character(0), start_year = integer(0), 
    #for global limits/sizes
    min_x = numeric(0), max_x = numeric(0),
    n = integer(0), persist_row_names = character(0),
    stringsAsFactors = FALSE
  )
  counter <- 1
  group_stats <- list()
  
  #...find the GROWTH WINDOW
  #also calc group stats, so we don't have to do it later.
  for (i in all_sub) {
    perms <- df[, i] %>% unique()
    if (drop_NA_groups == TRUE) {perms <- perms[!is.na(perms)]}
    
    for (j in perms) {
      #matching sub/perm students
      mask <- df[, i] == j
      #get the windows
      if (length(start_fws) > 1) {
        #from the data
        auto_windows <- auto_growth_window(
          mapvizieR_obj = mapvizieR_obj,
          studentids = df[mask, 'studentid'],
          measurementscale = measurementscale,
          end_fws = end_fws, 
          end_academic_year = end_academic_year,
          candidate_start_fws = start_fws,
          candidate_year_offsets = start_year_offset,
          candidate_prefer = start_fws_prefer,
          window_tolerance = 0.66
        )
        inferred_start_fws <- auto_windows[[1]]
        inferred_start_academic_year <- auto_windows[[2]]
      } else {
        inferred_start_fws <- start_fws
        inferred_start_academic_year <- end_academic_year + start_year_offset
      }
      
      #limit by windows
      this_stu <- df %>% dplyr::filter(
        studentid %in% df[mask, 'studentid'] &
        start_fallwinterspring == inferred_start_fws &
        start_map_year_academic == inferred_start_academic_year
      )
      
      #calc subgroup stats
      perm_stats <- quealy_permutation_stats(this_stu, i, measurementscale)
      perm_stats %>% ensurer::ensure_that(
        nrow(.) == 1 ~ 'there should only be one group!')
      
      #give the group name a consistent variable name
      names(perm_stats)[names(perm_stats) == i] <- 'facet_me'
 
      #put the stats on the list for use below
      group_stats[[paste0(i, '@', j)]] <- perm_stats
      
      window_df[counter, ]$subgroup <- i
      window_df[counter, ]$perm <- j
      window_df[counter, ]$start_fws <- inferred_start_fws
      window_df[counter, ]$start_year <- inferred_start_academic_year
      window_df[counter, ]$min_x <- min(perm_stats$start_rit, perm_stats$end_rit)
      window_df[counter, ]$max_x <- max(perm_stats$start_rit, perm_stats$end_rit)
      window_df[counter, ]$n <- perm_stats$n
      window_df[counter, ]$persist_row_names <- paste(this_stu$persistent_names, collapse = ',')
      
      counter <- counter + 1
    }
  }
  
  #5. MAKE PLOTS
  
  #global limits
  min_x <- min(window_df$min_x, na.rm = TRUE)
  max_x <- max(window_df$max_x, na.rm = TRUE)
  
  plot_lims <- c(
    round_to_any(min_x - 1, 5, f = floor), 
    round_to_any(max_x + 1, 5, f = ceiling)
  )
  
  n_range <- c(
    min(window_df$n, na.rm = TRUE), 
    max(window_df$n, na.rm = TRUE)
  )
  
  plot_counter <- 1
  plot_list <- list()
  nrow_list <- list()

  if (include_all) {
    ref_line_range <- c(
      group_stats[['all_students@All Students']]$start_rit,
      group_stats[['all_students@All Students']]$end_rit
    )

    #all students
    p_all <- quealy_facet_one_subgroup(
      sum_df = group_stats[['all_students@All Students']], 
      subgroup = 'All Students',
      xlims = plot_lims,
      n_range = n_range,
      ref_lines = ref_line_range
    )
    
    plot_list[[plot_counter]] <- p_all
    nrow_list[[plot_counter]] <- 1.5
    
    plot_counter <- plot_counter + 1
  } else {
    ref_line_range <- NA
  }

  #rest of the subgroups
  for (i in 1:length(subgroup_cols)) {
    #the matching permutations
    this_perms <- window_df[window_df$subgroup == subgroup_cols[i], ]
    #recover the logic of which rows based on auto growth windows
    #per perm
    all_rownames <- this_perms$persist_row_names %>% 
      paste(collapse = ',') %>% strsplit(split = ',') %>% unlist()
    mask <- df$persistent_names %in% all_rownames
    #calc group stats on those stu
    this_sum <- quealy_permutation_stats(df[mask, ], subgroup_cols[i], measurementscale)
    names(this_sum)[names(this_sum) == subgroup_cols[i]] <- 'facet_me'
    
    plot_list[[plot_counter]] <- quealy_facet_one_subgroup(
      sum_df = this_sum, 
      subgroup = pretty_names[i],
      xlims = plot_lims,
      n_range = n_range,
      ref_lines = ref_line_range
    )
      
    nrow_list[[plot_counter]] <- ifelse(
      nrow(this_sum) == 1, 1.5, nrow(this_sum)
    )
    
    plot_counter <- plot_counter + 1
  }
  
  #add named args to plot list for do call
  plot_list[['nrow']] <- length(plot_list)
  plot_list[['heights']] <- unlist(nrow_list)
  
  final <- do.call(
    what = "arrangeGrob",
    args = plot_list,
  )
  
  if (!is.na(report_title)) {
    title <- h_var(report_title, 16)
    
    final <- gridExtra::arrangeGrob(
      title, final, nrow = 2, heights = c(1, 19)
    ) 
  }
  
  return(final)
}



#' @title quealy_permutation_stats
#' 
#' @description calculates group stats for all the permutations of a subroup.  used 
#' to be internal to quealy_subgroups, has been extracted.
#' 
#' @param df a growth data frame
#' @param subgroup the subgroup to group and calculate summary stats for
#' 
#' @return a data frame
#' 
#' @export

quealy_permutation_stats <- function(df, subgroup, measurementscale) {
  start_fws <- unique(df$start_fallwinterspring)[1]
  end_fws <- unique(df$end_fallwinterspring)[1]

  results <- df %>%
    dplyr::group_by_(
      subgroup, quote(start_fallwinterspring), quote(end_fallwinterspring)
    ) %>%
    dplyr::summarize(    
      approximate_grade = round(mean(end_grade, na.rm = TRUE), 0), 
      start_rit = mean(start_testritscore, na.rm = TRUE),
      end_rit = mean(end_testritscore, na.rm = TRUE),
      rit_change = mean(rit_growth, na.rm = TRUE),
      start_npr = mean(start_consistent_percentile, na.rm = TRUE),
      end_npr = mean(end_consistent_percentile, na.rm = TRUE),
      npr_change = mean(end_consistent_percentile - start_consistent_percentile, na.rm = TRUE),
      n = n()
    ) %>%       
    #add cgp
    dplyr::rowwise() %>%
    dplyr::mutate(
      cgp = calc_cgp(
        measurementscale = measurementscale,
        grade = approximate_grade,
        growth_window = paste(start_fws, 'to', end_fws),
        baseline_avg_rit = start_rit,
        ending_avg_rit = end_rit,
        baseline_avg_npr = start_npr,
        ending_avg_npr = end_npr,
        tolerance = 99
      )[['results']] 
    ) %>%
    as.data.frame()
  
  return(results)
}
 


#' @title quealy_facet_one_subgroup
#' 
#' @description the plot called by quealy subgroups for each subgroup.  used
#' to be internal to the function, has been extracted.
#' 
#' @param sum_df output of quealy_permutation_stats.  needs to have a header
#' called facet_me.  look at quealy_subgroups to see example use.
#' @param subgroup the subgroup to plot.  quealy_subgroups calls this plot
#' once per element in subgroup_cols (and once for all students)
#' @param xlims the global xlims for the plot.
#' @param n_range the global range of n values.  used to set the width of 
#' the lines
#' @param ref_lines.  if using with all students, the reference lines 
#' showing change in all_students
#' 
#' @return a data frame
#' 
#' @export

quealy_facet_one_subgroup <- function(
  sum_df, subgroup, xlims, n_range, ref_lines = NA
) {
  
  if (nrow(sum_df) == 0) {
    stop("your feature/facet df is zero rows long.  check your inputs?")
  }
  
  #add newline breaks to the facet text
  sum_df$facet_format <- lapply(sum_df$facet_me, force_string_breaks, 30) %>%
    unlist()
  
  #get the arrow size on a universal scale
  min_width <- 0.2
  max_width <- 0.5
  pct_of_range <- ((sum_df$n - n_range[1]) / (n_range[2] - n_range[1]))
  sum_df$size_scaled <- min_width + (pct_of_range * (max_width - min_width))
      
  all_na_test <- all(is.na(sum_df$cgp))
  
  #cgp labeler
  
  cgp_labeler <- function(n, cgp) {
    if ((unique(sum_df$start_fallwinterspring) == 'Fall' & unique(sum_df$end_fallwinterspring) == 'Winter') | 
      (unique(sum_df$start_fallwinterspring) == 'Spring' & unique(sum_df$end_fallwinterspring) == 'Winter')
    ) {
      return(paste(n, 'stu')) 
    }
    if (n < 10) {
      return(paste(n, 'stu')) 
    } else {
      return(paste(n, 'stu', '| CGP:', round(cgp, 0)))
    }
  }
  
  e <- new.env()
  e$xlims <- xlims
  
  sum_df <- sum_df %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      cgp_label = cgp_labeler(n, cgp)  
    ) %>%
    as.data.frame()

  #make
  p <- ggplot(
    data = sum_df,
    aes(
      x = start_rit,
      xend = end_rit,
      y = 1,
      yend = 1
    ),
    environment = e
  )
  
  if (class(ref_lines) == "numeric") {
    p <- p + annotate(
      geom = 'rect',
      xmin = ref_lines[1], xmax = ref_lines[2], ymin = -1, ymax = 3,
      fill = 'dodgerblue',
      alpha = 0.15,
      size = 1.25
    ) 
  }
  
  #labels
  p <- p + geom_text(
    aes(
      x = start_rit + 0.5 * (end_rit - start_rit),
      y = 0.75,
      label = facet_format
    ),
    inherit.aes = FALSE,
    size = 9,
    alpha = 0.4,
    color = 'hotpink'
  ) +        
  geom_segment(
    aes(
      size = size_scaled
    ),
   arrow = grid::arrow(length = grid::unit(0.2 + (0.075 * sum_df$size_scaled), "cm"))
  ) +
  #start rit
  geom_text(
    aes(
      x = start_rit,
      y = 0.7,
      label = paste0(round(start_rit, 1), ' (', substr(start_fallwinterspring, 1, 1), ')')
    ),
    inherit.aes = FALSE,
    size = 4
  ) +
  #end rit
  geom_text(
    aes(
      x = end_rit,
      y = 0.7,
      label = paste0(round(end_rit, 1), ' (', substr(end_fallwinterspring, 1, 1), ')')
    ),
    inherit.aes = FALSE,
    size = 4
  ) +    
  #n stu and CGP
  geom_text(
    aes(
      x = start_rit + 0.5 * (end_rit - start_rit),
      y = 1.35,
      label = cgp_label
    ),
    fontface = 'italic',
    color = 'gray40',
    size = 4
  ) +
  coord_cartesian(
    xlim = c(xlims[1] - 0.5, xlims[2] + 0.5),
    ylim = c(0, 2)
  ) +
  facet_grid(
    facet_format ~ . 
  ) +
  theme_bw() +
  theme(
    axis.title.y = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank(),
    panel.border = element_blank(),
    panel.margin = grid::unit(0, "lines"),
    plot.margin = grid::unit(c(1,1,1,1), "mm")
  ) +
  labs(x = 'RIT') +
  scale_size_identity()

  #title
  p_title <- grob_justifier(
    grid::textGrob(
      subgroup, gp = grid::gpar(fontsize = 18, fontface = 'bold')
    ), 
    "center", "center"
  )
  
  first_row <- if (nrow(sum_df) <= 2) {1.5} else {1}
  #arrange and return
  gridExtra::arrangeGrob(
    p_title, p,
    nrow = 2, heights = c(first_row, 9)
  )    
}