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
#' @param start_fws_prefer which term is preferred? 
#' @param end_fws ending season
#' @param end_academic_year ending academic year
#' @param report_title text grob to put on the report tile
#' @param complete_obsv if TRUE, limit only to students who have BOTH a start
#' and end score. default is FALSE.
#' @param drop_NA should we ignore subgroups with value NA?  default is true
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
  drop_NA = TRUE,
  include_all = TRUE
) {
  #1| DATA PROCESSING

  #data validation and unpack
  mv_opening_checks(mapvizieR_obj, studentids, 1)
  assertthat::assert_that(length(subgroup_cols) == length(pretty_names))
  
  #unpack the mapvizieR object and limit to desired students
  roster <- mapvizieR_obj[['roster']]
  growth_df <- mv_limit_growth(mapvizieR_obj, studentids, measurementscale)

  #data processing
  #just desired terms
  this_growth <- growth_df %>%
    dplyr::filter(
      end_map_year_academic == end_academic_year,
      end_fallwinterspring == end_fws
    )
  
  
  #put starting quartile on the roster and rename
  #if we add other 'out of the box' cuts that look at  
  roster <- dplyr::left_join(
    x = roster,
    y = this_growth[ ,c('studentid', 'start_testquartile')],
    by = 'studentid'
  )
  roster$start_testquartile <- ifelse(
    !is.na(roster$start_testquartile),
    paste('Quartile', roster$start_testquartile),
    NA
  )
  
  names(roster)[names(roster) == 'start_testquartile'] <- 'starting_quartile'
  
  #require that all subgroups match names of the roster.
  roster %>% 
    ensurer::ensure_that(
      all(subgroup_cols %in% names(roster)) ~ "subgroup_cols must match column names in your mapvizieR roster."
    )
  
  #complete observations?
  if (complete_obsv == TRUE) {
    this_growth <- this_growth %>%
      dplyr::filter(
        complete_obsv == TRUE  
      )
  }
  
  #2| INTERNAL FUNCTIONS
  group_summary <- function(growth_df, subgroup) {
    
    #get uniques
    growth_df <- growth_df %>% as.data.frame()
    unq_sub <- unique(growth_df[,subgroup])
    unq_sub <- unq_sub[!is.na(unq_sub)]
    
    #loop over uniques
    #we have to do this because the determiniation of growth windows
    #is *per group*
    target_df <- growth_df[0, ]
    
    for (i in unq_sub) {
      mask <- growth_df[, subgroup] == i
      this_stu <- growth_df[mask, ]$studentid %>% unique()

      if (length(start_fws) > 1) {
        auto_windows <- auto_growth_window(
          mapvizieR_obj = mapvizieR_obj,
          studentids = this_stu,
          measurementscale = measurementscale,
          end_fws = end_fws, 
          end_academic_year = end_academic_year,
          candidate_start_fws = start_fws,
          candidate_year_offsets = start_year_offset,
          candidate_prefer = start_fws_prefer,
          tolerance = 0.65
        )
        inferred_start_fws <- auto_windows[[1]]
        inferred_start_academic_year <- auto_windows[[2]]
      } else {
        inferred_start_fws <- start_fws
        inferred_start_academic_year <- end_academic_year + start_year_offset
      }
      
      #filter using id'd start term
      filtered_subgroup <- growth_df %>% dplyr::filter(
        studentid %in% this_stu &
        start_fallwinterspring == inferred_start_fws &
        start_map_year_academic == inferred_start_academic_year
      )
      
      #put back together
      target_df <- rbind(target_df, filtered_subgroup)
    }
    

    #throw a warning if multiple grade levels
    grades_present <- unique(target_df$start_grade)
    if (length(grades_present) > 1) {
      warning(
        sprintf(paste0("%i distinct grade levels present in your data! NWEA ",
          "school growth study tables assume cohorts composed of students ",
          "of the *same grade level*.  quealy_subgroups will use the mean starting grade ",
          "level to calculate growth scores, but you are advised to check your data and  ",
          "attempt to use a cohort composed of students from the same grade."), 
          length(grades_present))
      )
    }
        
    df <- target_df %>%
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
    
    if (drop_NA == TRUE) {
      mask <- !is.na(df[, subgroup])
      df <- df[mask, ]
    }

    names(df)[names(df) == subgroup] <- 'facet_me'
    
    df
  }
    
  facet_one_subgroup <- function(df, subgroup, xlims, n_range, ref_lines) {
    
    if (nrow(df) == 0) {
      stop("your feature/facet df is zero rows long.  check your inputs?")
    }
    
    #add newline breaks to the facet text
    df$facet_format <- unlist(lapply(df$facet_me, force_string_breaks, 15))
    #add the season
    df$start_season <- 
    
    #get the arrow size on a universal scale
    min_width <- 0.2
    max_width <- 0.5
    pct_of_range <- ((df$n - n_range[1]) / (n_range[2] - n_range[1]))
    df$size_scaled <- min_width + (pct_of_range * (max_width - min_width))
        
    all_na_test <- all(is.na(df$cgp))
    
    #cgp labeler
    
    cgp_labeler <- function(n, cgp) {
      if ((unique(df$start_fallwinterspring) == 'Fall' & end_fws == 'Winter') | 
        (unique(df$start_fallwinterspring) == 'Spring' & end_fws == 'Winter')
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
    
    df <- df %>%
      dplyr::rowwise() %>%
      dplyr::mutate(
        cgp_label = cgp_labeler(n, cgp)  
      ) %>%
      as.data.frame()
  
    #make
    p <- ggplot(
      data = df,
      aes(
        x = start_rit,
        xend = end_rit,
        y = 1,
        yend = 1
      ),
      environment = e
    )
    
    if (include_all == TRUE) {
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
      size = 16,
      alpha = 0.1,
      color = 'gray20'
    ) +        
    geom_segment(
      aes(
        size = size_scaled
      ),
     arrow = grid::arrow(length = grid::unit(0.2 + (0.075 * df$size_scaled), "cm"))
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
    
    first_row <- if (nrow(df) <= 2) {1.5} else {1}
    #arrange and return
    gridExtra::arrangeGrob(
      p_title, p,
      nrow = 2, heights = c(first_row, 9)
    )    
  }
  
  #3| DATA CUTS

  #calc constants
  #silly values
  x_min <- 999
  x_max <- -1
  min_n <- 1000000
  max_n <- -1
  
  for (i in subgroup_cols) {
    
    if (length(start_fws) > 1) {
      auto_windows <- auto_growth_window(
        mapvizieR_obj = mapvizieR_obj,
        studentids = unique(this_growth$studentid),
        measurementscale = measurementscale,
        end_fws = end_fws, 
        end_academic_year = end_academic_year,
        candidate_start_fws = start_fws,
        candidate_year_offsets = start_year_offset,
        candidate_prefer = 'Spring',
        tolerance = 0.8
      )
      inferred_start_fws <- auto_windows[[1]]
      inferred_start_academic_year <- auto_windows[[2]]
    } else {
      inferred_start_fws <- start_fws
      inferred_start_academic_year <- end_academic_year + start_year_offset
    }
    
    this_window <- this_growth %>%
      dplyr::filter(
        start_fallwinterspring == inferred_start_fws &
        start_map_year_academic == inferred_start_academic_year
      )

    minimal_roster <- roster[, c('studentid', i)]
    #get uniques
    minimal_roster <- unique(minimal_roster)
    int_df <- dplyr::inner_join(
      x = this_window,
      y = minimal_roster,
      by = c('studentid' = 'studentid')
    )

    int_df <- dplyr::group_by_(
      int_df, i
    ) %>%
    dplyr::summarize(
      start_rit = round_to_any(mean(start_testritscore, na.rm = TRUE), 2, f = floor),
      end_rit = round_to_any(mean(end_testritscore, na.rm = TRUE), 2, f = ceiling),
      n = n()
    ) %>% as.data.frame()
    
    if (drop_NA == TRUE) {
      mask <- !is.na(int_df[, i])
      int_df <- int_df[mask, ]
    }
    
    if (min(int_df$start_rit, na.rm = TRUE) < x_min) x_min <- min(int_df$start_rit, na.rm = TRUE)
    if (max(int_df$end_rit, na.rm = TRUE) > x_max) x_max <- max(int_df$end_rit, na.rm = TRUE)
    if (min(int_df$n, na.rm = TRUE) < min_n) min_n <- min(int_df$n, na.rm = TRUE)
    if (max(int_df$n, na.rm = TRUE) > max_n) max_n <- max(int_df$n, na.rm = TRUE)
  }
  
  plot_lims <- c(x_min, x_max)
  n_range <- c(min_n, max_n)
  
  counter <- 1
  plot_list <- list()
  nrow_list <- list()

  this_growth$all_students <- 'All Students'
  total_change <- group_summary(this_growth, 'all_students')
  
  if (include_all == TRUE) {
    #all students
    p_all <- facet_one_subgroup(
      df = total_change, 
      subgroup = 'All Students',
      xlims = plot_lims,
      n_range = n_range,
      ref_lines = c(total_change$start_rit, total_change$end_rit)
    )
    
    plot_list[[counter]] <- p_all
    nrow_list[[counter]] <- 1.5
    
    counter <- counter + 1
  }

  #iterate over subgroups
  #values for ALL students
  
  
  for (i in 1:length(subgroup_cols)) {
    subgroup <- subgroup_cols[i]
    
    #join roster and data
    minimal_roster <- roster[, c('studentid', subgroup)]
    #get uniques
    minimal_roster <- unique(minimal_roster)
    
    combined_df <- dplyr::inner_join(
      x = this_growth,
      y = minimal_roster,
      by = c('studentid' = 'studentid')
    )
    
    #now pass to group summary
    this_summary <- group_summary(combined_df, subgroup)
    
    plot_list[[counter]] <- facet_one_subgroup(
      df = this_summary, 
      subgroup = pretty_names[i],
      xlims = plot_lims,
      n_range = n_range,
      ref_lines = c(total_change$start_rit, total_change$end_rit)
    )
    nrow_list[[counter]] <- ifelse(nrow(this_summary) == 1, 1.5, nrow(this_summary))
    
    counter <- counter + 1
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
  
  # return 
  final
}



