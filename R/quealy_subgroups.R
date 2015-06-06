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
#' @param start_fws starting season
#' @param start_academic_year starting academic year
#' @param end_fws ending season
#' @param end_academic_year ending academic year
#' @param complete_obsv if TRUE, limit only to students who have BOTH a start
#' and end score. default is FALSE.
#' 
#' @export

quealy_subgroups <- function(
  mapvizieR_obj, 
  studentids, 
  measurementscale,
  subgroup_cols = c('starting_quartile'),
  pretty_names = c('Starting Quartile'),
  start_fws,
  start_academic_year,
  end_fws,
  end_academic_year,
  complete_obsv = FALSE
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
      start_map_year_academic == start_academic_year,
      start_fallwinterspring == start_fws,
      end_map_year_academic == end_academic_year,
      end_fallwinterspring == end_fws
    )
  #throw a warning if multiple grade levels
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
  
  names(roster)[names(roster)=='start_testquartile'] <- 'starting_quartile'
  
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
  group_summary <- function(grouped_df, subgroup) {
    
    approximate_grade <- round(mean(grouped_df$start_grade, na.rm=TRUE), 0)  
    
    df <- grouped_df %>%
    summarize(
      start_rit = mean(start_testritscore, na.rm=TRUE),
      end_rit = mean(end_testritscore, na.rm=TRUE),
      rit_change = mean(rit_growth, na.rm=TRUE),
      start_npr = mean(start_consistent_percentile, na.rm=TRUE),
      end_npr = mean(end_consistent_percentile, na.rm=TRUE),
      npr_change = mean(start_consistent_percentile - end_consistent_percentile, na.rm=TRUE),
      n = n()
    ) %>%       
    #add cgp
    rowwise() %>%
    mutate(
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
    as.data.frame
    
    names(df)[names(df) == subgroup] <- 'facet_me'
    
    df
  }
    
  facet_one_subgroup <- function(df, subgroup, xlims, n_range, ref_lines) {
    #add newline breaks to the facet text
    df$facet_format <- unlist(lapply(df$facet_me, force_string_breaks, 15))
    
    #get the arrow size on a universal scale
    min_width <- 0.1
    max_width <- 1.5
    pct_of_range <- ((df$n - n_range[1]) / (n_range[2] - n_range[1]))
    df$size_scaled <- min_width + (pct_of_range * (max_width - min_width))
        
    all_na_test <- all(is.na(df$cgp))
    
    
    #cgp labeler
    cgp_labeler <- function(n, cgp) {
      if((start_fws == 'Fall' & end_fws == 'Winter') | 
        (start_fws == 'Spring' & end_fws == 'Winter')
      ) {
        return(paste(n, 'stu')) 
      }
      if(n < 10) {
        return(paste(n, 'stu')) 
      } else {
        return(paste(n, 'stu', '| CGP:', round(cgp, 0)))
      }
    }
    
    df <- df %>%
      rowwise %>%
      mutate(
        cgp_label = cgp_labeler(n, cgp)  
      ) %>%
      as.data.frame
  
    #make
    p <- ggplot(
      data=df
     ,aes(
        x = start_rit,
        xend = end_rit,
        y = 1,
        yend = 1
      )
    ) +
    annotate(
      geom = 'rect',
      xmin = ref_lines[1], xmax = ref_lines[2], ymin = -1, ymax = 3,
      fill = 'dodgerblue',
      alpha = 0.15,
      size = 1.25
    ) +
    geom_segment(
      aes(
        size = size_scaled
      ),
     arrow = arrow(length = unit(0.2 + (0.075 * df$size_scaled), "cm"))
    ) +
    #start rit
    geom_text(
      aes(
        x = start_rit,
        y = 0.7,
        label = round(start_rit, 1)
      ),
      inherit.aes = FALSE,
      size = 4
    ) +
    #end rit
    geom_text(
      aes(
        x = end_rit,
        y = 0.7,
        label = round(end_rit, 1)
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
      xlim=c(xlims[1] - 0.5, xlims[2] + 0.5),
      ylim=c(0, 2)
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
      panel.margin = unit(0, "lines"),
      plot.margin = unit(c(1,1,1,1), "mm")
    ) +
    labs(x = 'RIT') +
    scale_size_identity()
  
    #title
    p_title <- grob_justifier(
      textGrob(
        subgroup, gp = gpar(fontsize = 18, fontface = 'bold')
      ), 
      "center", "center"
    )
    
    first_row <- if(nrow(df) <= 2) {1.5} else {1}
    #arrange and return
    arrangeGrob(
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
    minimal_roster <- roster[, c('studentid', 'map_year_academic', 'fallwinterspring', i)]
    int_df <- dplyr::inner_join(
      x = this_growth,
      y = minimal_roster,
      by = c('studentid' = 'studentid', 
        'start_map_year_academic' = 'map_year_academic', 
        'start_fallwinterspring' = 'fallwinterspring')
    )

    int_df <- dplyr::group_by_(
      int_df, i  
    ) %>%
    summarize(
      start_rit = round_to_any(mean(start_testritscore, na.rm=TRUE), 2, f=floor),
      end_rit = round_to_any(mean(end_testritscore, na.rm=TRUE), 2, f=ceiling),
      n = n()
    )
    
    if(min(int_df$start_rit) < x_min) x_min <- min(int_df$start_rit)
    if(max(int_df$end_rit) > x_max) x_max <- max(int_df$end_rit)
    if(min(int_df$n) < min_n) min_n <- min(int_df$n)
    if(max(int_df$n) > max_n) max_n <- max(int_df$n)
  }
  
  plot_lims <- c(x_min, x_max)
  n_range <- c(min_n, max_n)
  
  #all students
  this_growth$all_students <- 'All Students'
  total_change <- group_summary(dplyr::group_by(this_growth, all_students), 'all_students')
  p_all <- facet_one_subgroup(
    df = total_change, 
    subgroup = 'All Students',
    xlims = plot_lims,
    n_range = n_range,
    ref_lines = c(total_change$start_rit, total_change$end_rit)
  )
  
  #iterate over subgroups
  plot_list <- list()
  nrow_list <- list()
  #values for ALL students
  plot_list[[1]] <- p_all
  nrow_list[[1]] <- 1.5
  counter <- 2
  
  for (i in 1:length(subgroup_cols)) {
    subgroup <- subgroup_cols[i]
    
    #join roster and data
    minimal_roster <- roster[, c('studentid', 'map_year_academic', 
      'fallwinterspring', subgroup)]
    combined_df <- dplyr::inner_join(
      x = this_growth,
      y = minimal_roster,
      by = c('studentid' = 'studentid', 
        'start_map_year_academic' = 'map_year_academic', 
        'start_fallwinterspring' = 'fallwinterspring')
    )
    
    #now group by subgroup and summarize
    grouped_df <- dplyr::group_by_(combined_df, subgroup)
    this_summary <- group_summary(grouped_df, subgroup)
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
  
  do.call(
    what = "arrangeGrob",
    args = plot_list,
  )

}
