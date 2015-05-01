#' @title Chris Haid's Waterfall-Rainbow-Arrow Chart
#'
#' @description \code{haid_plot} returns a ggplot object showing student MAP performance 
#' for a group of students
#'
#' @details This function builds and prints a graphic that plots MAP performance 
#' over one or two seasons. RIT scores are color coded by percentile. 
#'  
#' @param mapvizieR_obj mapvizieR object
#' @param studentids target students
#' @param measurementscale target subject
#' @param start_fws starting season
#' @param start_academic_year starting academic year
#' @param end_fws ending season
#' @param end_academic_year ending academic year
#' @param p_growth_colors vector of colors passed to ggplot.
#' @param p_growth_tiers vector of colors passed to ggplot.
#' @param p_quartile_colors vector of colors passed to ggplot.
#' @param p_name_size sets point size of student names.
#' @param p_alpha sets level fo transparency for goals. 
#' @param p_name_offset percentage to offset for negative names.  make bigger if plot 
#' is smaller.
#' 
#' @return prints a ggplot object
#' 
#' @export

haid_plot <- function(
  mapvizieR_obj,
  studentids,
  measurementscale,
  start_fws,
  start_academic_year,
  end_fws,
  end_academic_year,
  sort_column = 'start_testritscore',
  #look and feel
  p_growth_colors = c("tan4", "snow4", "gold", "red"),
  p_growth_tiers = c("Positive", "Typical", "College Ready", "Negative"),
  p_quartile_colors = c('#f3716b', '#79ac41', '#1ebdc2', '#a57eb8'),
  p_name_size = 3,
  p_alpha = 1,
  p_name_offset = 0.04
) {
  
  #data validation and unpack
  mv_opening_checks(mapvizieR_obj, studentids, 1)

  #unpack the mapvizieR object and limit to desired students
  growth_df <- mv_limit_growth(mapvizieR_obj, studentids, measurementscale)

  #data processing ----------------------------------------------------------
  #just desired terms
  df <- growth_df %>%
    dplyr::filter(
      start_map_year_academic == start_academic_year,
      start_fallwinterspring == start_fws,
      end_map_year_academic == end_academic_year,
      end_fallwinterspring == end_fws
    )
  
  #get student name onto growth df
  minimal_roster <- mapvizieR_obj[['roster']]
  minimal_roster <- minimal_roster[, 
    c('studentid', 'map_year_academic', 'fallwinterspring', 'studentfirstlast',
      'studentlastfirst')]
  
  df <- dplyr::inner_join(
    x = df,
    y = minimal_roster,
    by = c('studentid' = 'studentid', 
      'start_map_year_academic' = 'map_year_academic', 
      'start_fallwinterspring' = 'fallwinterspring')
  )
  
  #if a student doesn't have a base rit, plot will break
  ommitted_count <- sum(is.na(df$start_testritscore))
  df <- df[!is.na(df$start_testritscore), ]
  num_stu <- nrow(df)
  stopifnot(
    length(df$start_testritscore) > 0
  )
  
  #is this ONE SEASON or TWO SEASON?
  if (any(df$complete_obsv)) {
    single_season_flag <- FALSE  
  } else {
    single_season_flag <- TRUE 
  }
  
  #thematic stuff
  pointsize <- 3
  segsize <- 1
  annotate_size <- 5
  x_min <- round_to_any(min(c(df$start_testritscore, df$end_testritscore)), 5, f = floor)
  x_max <- round_to_any(max(c(df$start_testritscore, df$end_testritscore)), 5, f = ceiling) 
  name_offset <- p_name_offset * (x_max - x_min)      
  
  #make a psuedo-axis by ordering based on one variable
  df$y_order <- rank(
    x = df[ , sort_column]
    ,ties.method = "first"
    ,na.last = FALSE
  )
  
  #make growth status an ordered factor
  df$growth_status = factor(
    x = df$growth_status,
    levels = p_growth_tiers,
    ordered = TRUE
  )
  
  #tag rows pos / neg change
  if(single_season_flag) {
    df$neg_flag <- 0
  } else {
    df$neg_flag <- ifelse(df$end_testritscore <= df$start_testritscore, 1, 0)
  }
  
  #tag names
  df$student_name_format <- ifelse(
    df$neg_flag == 1, 
    df$studentfirstlast, 
    paste0(df$studentfirstlast, " ", df$start_testritscore, " ", "(", df$start_testpercentile, ") ")
  )
  
  #NAs
  df$student_name_format <- ifelse(is.na(df$student_name_format), df$studentfirstlast, df$student_name_format)    
  
  #composite name position vector - if growth is NEGATIVE, use the endpoint
  df$name_x <- ifelse(df$neg_flag == 1, df$end_testritscore - name_offset, df$start_testritscore - 0.25)
  #NAs
  df$name_x <- ifelse(is.na(df$name_x), df$start_testritscore - 0.25, df$name_x)
  
  df$rit_xoffset <- ifelse(df$neg_flag == 1, -.25, .25)
  df$rit_hjust <- ifelse(df$neg_flag == 1, 1, 0)
  
  #colors for identity! 
  growth_colors <- data.frame(
    status = p_growth_tiers,
    color = p_growth_colors,
    stringsAsFactors = FALSE
  )
  #cribbing off of 'subscripting' http://rwiki.sciviews.org/doku.php?id=tips:data-frames:merge
  df$growth_color_identity <- growth_colors$color[match(df$growth_status, growth_colors$status)]

  #start/end quartile colors
  quartile_colors <- data.frame(
    quartile = c(1,2,3,4),
    color = p_quartile_colors,
    stringsAsFactors = FALSE
  )
  df$baseline_color <- quartile_colors$color[match(df$start_testquartile, quartile_colors$quartile)]
  df$endpoint_color <- quartile_colors$color[match(df$end_testquartile, quartile_colors$quartile)]
  
    #massage df so that no quartiles get dropped
  df$start_testquartile_format <- paste('Quartile', as.factor(df$start_testquartile))

  start_qs <- unique(na.omit(df$start_testquartile))
  end_qs <- unique(na.omit(df$end_testquartile))
  missing_qs <- end_qs[!(end_qs %in% start_qs)]
  if(length(end_qs)==0) missing_qs <- start_qs  

  #loop over missing qs and insert an empty row into the data frame
    #dummy row
    foo <- df[1, ]  
    foo[1, ] <- NA
    
  if (length(missing_qs) > 0) {
    for (i in missing_qs) {
      foo[ , c('start_testquartile', 'end_testquartile')] <- i
      foo[ , c('start_testquartile_format')] <- paste('Quartile', i) 
      
      #if 1 is missing, insert at y=1
      if (i == 1) {
        insert_point <- 1
      #otherwise insert at max of i-1
      } else {
        insert_point <- max(df[df$start_testquartile < i, 'y_order'], na.rm=T) + 1
      }
      
      df[df$y_order >= insert_point, 'y_order'] <- df[df$y_order >= insert_point, 'y_order'] + 1
      
      foo[ , 'y_order'] <- insert_point
      foo[ , 'start_testritscore'] <- min(df$start_testritscore, na.rm=T)
      foo[ , 'student_name_format'] <- ' '
      
      df <- rbind(df, foo)
    }
  }
  
  #make placeholders white
  if (sum(df$student_name_format == ' ') > 0) {
    df[df$student_name_format == ' ', 'baseline_color'] <- 'white'
    df[df$student_name_format == ' ', 'endpoint_color'] <- 'white'    
  }
  
  #make chart ----------------------------------------------------------
  #capture environment to use variables inside of ggplot calls
  .e <- environment()
  
  #base ggplot object
  p <- ggplot(
    data = df
    ,aes(
      x = start_testritscore,
      y = y_order
    ),
    environment = .e
  )
  
  #typical and college ready goal lines (want these behind segments)
  p <- p + 
  geom_point(
    aes(x = start_testritscore + reported_growth),
    size = pointsize - 0.5,
    shape = '|',
    color = '#CFCCC1',
    alpha = p_alpha
  ) + 
  geom_point(
    aes(x = start_testritscore + accel_growth),
    size = pointsize - 0.5,
    shape = '|',
    color = '#FEBC11',
    alpha = p_alpha
  )  

  #typical and college ready goal labels
  p <- p +
  geom_text(
    data = df[df$student_name_format != ' ', ]
   ,aes(
      x = start_testritscore + reported_growth
     ,label = start_testritscore + reported_growth
    ),
    color = "#CFCCC1",
    size = pointsize - 0.5,
    hjust = 0.5,
    vjust = 0,
    alpha = p_alpha
  ) + 
  geom_text(
    data = df[df$student_name_format != ' ', ]
   ,aes(
      x = start_testritscore + accel_growth
     ,label = start_testritscore + accel_growth
    ), 
    color = "#FEBC11",
    size = pointsize - 0.5,
    hjust = 0.5,
    vjust = 0,
    alpha = p_alpha
  ) +  
  scale_color_identity()  

  #only do the following if we have SOME end rit data
  if (any(df$complete_obsv)) {
    #add segments showing change
    p <- p + geom_segment(
      aes(
        xend = end_testritscore,
        yend = y_order,
        group = growth_color_identity,
        color = growth_color_identity
      ),
      arrow = arrow(length = unit(0.1,"cm"))
    ) 
    
    #add RIT text
    p <- p +
      geom_text(
        aes(
          x = end_testritscore + rit_xoffset,
          group = endpoint_color,
          color = endpoint_color,
          label = paste0(end_testritscore, " (", end_testpercentile, ")"),
          hjust = rit_hjust
        ),
        size = p_name_size
      )    
  }

  #add name labels
  p <- p +
    geom_text(
      aes(
        x = name_x,
        label = student_name_format,
        color = growth_color_identity
      ),
      size = p_name_size,
      vjust = 0.5,
      hjust = 1
    )

  #negative students start rit is not part of name string.  print to right of baseline
  if (nrow(df[df$neg_flag == 1 & !is.na(df$neg_flag), ]) > 0) {
    p <- p + geom_text(
      data = df[df$neg_flag == 1 & !is.na(df$neg_flag) & df$student_name_format != ' ', ],
      aes(
        x = start_testritscore + 0.4 * name_offset,
        label = start_testritscore,
        group = baseline_color,
        color = baseline_color
      ),
      size = p_name_size
    )
  }  

  #add season 1 start point
  p <- p +
  geom_point(
    aes(
      group = baseline_color,
      color = baseline_color
    ),
    size = pointsize
  )
  
  #theme stuff
  p <- p + 
  theme(
    panel.background = element_rect(
      fill = "transparent",
      colour = NA
    ),
    plot.background = element_rect(
      fill = "transparent",
      colour = NA
    ),
    panel.grid = element_blank(),
    axis.text.x = element_text(size = 15),
    axis.text.y = element_blank(),
    axis.ticks = element_blank(),
    strip.text.x = element_text(size = 15),
    strip.text.y = element_text(size = 15),
    strip.background = element_rect(
      fill = "#F4EFEB",
      colour = NA),
    plot.title = element_text(size = 18),
    legend.position = "none"
  )
  
  #faceting
  p <- p + 
  facet_grid(
    formula(start_testquartile_format ~ .),
    scale="free_y",
    space = "free_y",
    shrink = FALSE,
    as.table = FALSE
  ) 
  
  #scale stuff
  p <- p +
    scale_y_continuous(
      name = " "
      ,breaks = seq(0:max(df$y_order) + 1)
      ,expand = c(0,0.5)
    )

  #titles etc
  p <- p +
    xlab('RIT Score')

  #summary labels
  start_labels <- get_group_stats(
    df = df[!is.na(df$start_testritscore) & df$student_name_format != ' ', ]
    ,grp = 'start_testquartile'
    ,RIT = 'start_testritscore'
    ,dummy_y =  'y_order'
  )  
  start_labels$start_testquartile_format <- paste('Quartile', start_labels$start_testquartile)
  
  #repeat for end quartile
  end_labels <- get_group_stats(
    df = df[!is.na(df$end_testritscore) & df$student_name_format != ' ', ]
    ,grp = 'end_testquartile'
    ,RIT = 'end_testritscore'
    ,dummy_y =  'y_order'
  )
  
  if (length(na.omit(end_labels$end_testquartile)) > 0) {
    end_labels$quartile_label_pos <- NA
    end_labels$start_testquartile_format <- paste('Quartile', end_labels$end_testquartile)
  }
  
  #calculate x position
  if(single_season_flag){
    calc_df <- df[!is.na(df$start_testritscore), ]
    quartile_label_min <- round_to_any(min(calc_df$start_testritscore) - 10, 10, floor) + 10
    quartile_label_max <- round_to_any(max(calc_df$start_testritscore) + 10, 10, ceiling) - 10 
  } else {
    calc_df <- df[!is.na(df$start_testritscore) & !is.na(df$end_testritscore), ]
    quartile_label_min <- round_to_any(min(c(calc_df$start_testritscore, calc_df$end_testritscore)) - 10, 10, floor) + 10
    quartile_label_max <- round_to_any(max(c(calc_df$start_testritscore, calc_df$end_testritscore)) + 10, 10, ceiling) - 10     
  }
  
  #add x position to summary dfs
  start_labels$quartile_label_pos <- NA
  start_labels$start_testquartile <- as.numeric(start_labels$start_testquartile)
  end_labels$end_testquartile <- as.numeric(end_labels$end_testquartile)
  
  if (length(na.omit(start_labels$start_testquartile) <= 2) > 0) {
    start_labels[start_labels$start_testquartile <= 2, 'quartile_label_pos'] <- quartile_label_max
  }

  if (length(na.omit(start_labels$start_testquartile) >= 3) > 0) {
    start_labels[start_labels$start_testquartile >= 3, 'quartile_label_pos'] <- quartile_label_min
  }


  
  if (length(na.omit(end_labels$end_testquartile) <= 2) > 0) {
    end_labels[end_labels$end_testquartile <= 2, 'quartile_label_pos'] <- quartile_label_max
  }

  if (length(na.omit(end_labels$end_testquartile) >= 3) > 0) {
    end_labels[end_labels$end_testquartile >= 3, 'quartile_label_pos'] <- quartile_label_min
  }

  start_labels$count_label <- paste0(
    start_fws, ': ', start_labels$count_students, 
      " students (", round(start_labels$pct_of_total * 100), "%)"
  )
  
  end_labels$count_label <- paste0(
    end_fws, ': ', end_labels$count_students, 
      " students (", round(end_labels$pct_of_total * 100), "%)"
  )
    
  #make annotation lables so that season 2 is after season 1
  #god this is the absolute worst.
  #begin by flipping back to data frame  
  start_labels <- as.data.frame(start_labels, stringsAsFactors = FALSE)
  end_labels <- as.data.frame(end_labels, stringsAsFactors = FALSE)
  #grab everything in the start that matches the end
  #this is necessary when there are quartiles present in the end data not present in the start
  matched_label = start_labels[start_labels$start_testquartile_format %in% end_labels$start_testquartile_format, 'start_testquartile_format']
  matched_ypos = start_labels[start_labels$start_testquartile_format %in% end_labels$start_testquartile_format, 'avg_y_dummy']
  
  #make it a df
  label_match_df <- data.frame(
    label = matched_label
    #offset lower; if n is small, only offset by 1.
    ,ypos = matched_ypos - (1 +  floor(num_stu / 30))
    ,stringsAsFactors = FALSE
  )
  
  #for the ones you can match, replace with the adjusted start, so they print below
  #unmatched will remain in the avg/middle position
  end_labels[end_labels$start_testquartile_format %in% label_match_df$label, 'avg_y_dummy'] <- label_match_df$ypos
  
  #backmatch
    #IN START but NOT END?
    missing_start <- end_qs[!(end_qs %in% start_qs)]
    
    #IN END but NOT START?
    missing_end <- start_qs[!(start_qs %in% end_qs)]
  
    if (length(missing_start) > 0) {
      foo <- start_labels[0, ]
      foo[1, ] <- NA

      for (i in missing_start) {
        foo$start_testquartile <- i
        foo[, 'start_testquartile_format'] <- paste('Quartile', i)
        foo[, 'count_students'] <- 0
        foo[, 'count_label'] <- paste0(start_season_abbrev, ': 0 students (0%)')

        if (i <= 2) {
          foo[, 'quartile_label_pos'] <- quartile_label_max
        } else if (i >= 3) {
          foo[, 'quartile_label_pos'] <- quartile_label_min         
        }

        #if 1 is missing, insert at y=1
        if (i == 1) {
          insert_point <- 1
        #otherwise insert at max of i-1
        } else {
          insert_point <- max(df[df$start_testquartile < i, 'y_order'], na.rm=T) + 1
        }

        foo[, 'avg_y_dummy'] <- insert_point + 1
        
        start_labels <- rbind(start_labels, foo)
        #matching the other way is different
        #they are already in end labels, but we need to fix the avg_y_dummy so it matches insert_point
        end_labels[end_labels$start_testquartile_format == paste('Quartile', i), 'avg_y_dummy'] <- insert_point
      }    
    }    
  
    if (length(missing_end) > 0) {
      foo <- end_labels[0, ]
      foo[1, ] <- NA

      for (i in missing_end) {
        foo$end_testquartile <- i
        foo[, 'start_testquartile_format'] <- paste('Quartile', i)
        foo[, 'count_students'] <- 0
        foo[, 'count_label'] <-  paste0(end_season_abbrev, ': 0 students (0%)')

        if (i <= 2) {
          foo[, 'quartile_label_pos'] <- quartile_label_max
        } else if (i >= 3) {
          foo[, 'quartile_label_pos'] <- quartile_label_min         
        }

        
        #if 1 is missing, insert at y=1
        if (i == 1) {
          insert_point <- 1
        #otherwise insert at max of i-1
        } else {
          if (length(df[df$start_testquartile < i, 'y_order']) > 0) {
            insert_point <- max(df[df$start_testquartile < i, 'y_order'], na.rm=T) + 1
          } else {
            insert_point <- 0
          }
        }

        foo[, 'avg_y_dummy'] <- insert_point + 1
        
        end_labels <- rbind(end_labels, foo)
      }    
    }    
  
  #lookup colors
  annotate_colors <- data.frame(
    quartile = c('Quartile 1', 'Quartile 2', 'Quartile 3', 'Quartile 4')
    ,color = p_quartile_colors
    ,stringsAsFactors = FALSE
  )
  
  start_labels$color_identity <- annotate_colors$color[match(start_labels$start_testquartile_format, annotate_colors$quartile)]
  end_labels$color_identity <- annotate_colors$color[match(end_labels$start_testquartile_format, annotate_colors$quartile)]
  
  #add to plot
  #base students
  if (nrow(start_labels[start_labels$start_testquartile <= 2, ]) > 0) {
    p <- p + geom_text(
      data = start_labels[start_labels$start_testquartile <= 2, ]
     ,aes(
        x = quartile_label_pos
       ,y = avg_y_dummy
       ,label = count_label
       ,group = start_testquartile_format
       ,color = color_identity
      )
      ,vjust = 0.5
      ,hjust = 1
      ,size = annotate_size
    )    
  }

  if (nrow(start_labels[start_labels$start_testquartile >= 3, ]) > 0) {
    p <- p + geom_text(
      data = start_labels[start_labels$start_testquartile >= 3, ]
     ,aes(
        x = quartile_label_pos
       ,y = avg_y_dummy
       ,label = count_label
       ,group = start_testquartile_format
       ,color = color_identity
      )
      ,vjust = 0.5
      ,hjust = 0
      ,size = annotate_size
    )
  }
  
  if(!single_season_flag){
    if (nrow(end_labels[end_labels$end_testquartile <= 2, ]) > 0) {
      p <- p + geom_text(
        data = end_labels[end_labels$end_testquartile <= 2, ]
        ,aes(
          x = quartile_label_pos
          ,y = avg_y_dummy
          ,label = count_label
          ,group = start_testquartile_format  
          ,color = color_identity
        )
        ,vjust = 0.5
        ,hjust = 1
        ,size = annotate_size
      )
    }
    
    if (nrow(end_labels[end_labels$end_testquartile >= 3, ]) > 0) {
      p <- p + geom_text(
        data = end_labels[end_labels$end_testquartile >= 3, ]
        ,aes(
          x = quartile_label_pos
          ,y = avg_y_dummy
          ,label = count_label
          ,group = start_testquartile_format  
          ,color = color_identity
        )
        ,vjust = 0.5
        ,hjust = 0
        ,size = annotate_size
      )
    }
  }
  
  return(p)  
}



#' @title Calculate quartiles stats for \code{haid_plot}
#'
#' @description
#' \code{get_group_stats} calculates counts and percentages used in 
#' \code{haid_plot}
#' 
#' @param df a data frames with individual RIT scores and grouping variable
#' @param grp the variable to group by
#' @param RIT the column in the data frame with RIT scores
#' @param dummy_y column used to establish data placement on \code{haid_plot}
#' 
#' @return A data frame with aggregate values grouped by grp for count 
#' of students, y-axis placement, group average RIT, percent of students
#' in group (relative to total students), and the total count of students. 

get_group_stats <- function(df, grp, RIT, dummy_y) {
  
  #total rows
  dftotal <- nrow(df)
    
  #make a dummy data frame with desired columns  
  dummy <- data.frame(
    dummy_group = df[, grp],
    dummy_rit = df[, RIT],
    dummy_y = df[, dummy_y]
  )
    
  #a list of args to pass to summarize_ 
  #(read http://cran.r-project.org/web/packages/dplyr/vignettes/nse.html)
  dots <- list(
    ~n(),
    ~mean(dummy_y),
    ~mean(dummy_rit),
    ~dftotal
  )
  
  #calc the stats
  group_stats <- dummy %>%
    dplyr::group_by(dummy_group) %>%
    dplyr::summarize_(
      .dots = setNames(
        dots, c('count_students', 'avg_y_dummy', 'avg_rit', 'total_count')
      )
    ) %>% as.data.frame()
  
  group_stats$pct_of_total <- group_stats$count_students / group_stats$total_count
  names(group_stats)[1] <- grp
  
  return(group_stats)
}




test_it <- function() {
  foo2 <- haid_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013
  ) 
  
  print(foo2)  
}
