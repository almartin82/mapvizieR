#' Makes the base template that shows the RIT space and corresponding
#' percentile rank lines.
#'
#' @param measurementscale c('Reading', 'Mathematics') - there is no linking
#' study for Language or Science
#' @param color_list vector of colors to use to shade the bands.  Default is
#' the output of rainbow_colors().
#' @param ribbon_alpha transparency value for the background ribbons
#' @param annotation_style c('points', 'big numbers', or 'small numbers')
#' @param line_style c('gray lines')
#' @param spring_only fall norms show a 'summer slump' effect; this can be
#' visually distracting.  spring_only won't include those points in the reference
#' lines.
#' @param norms c(2011, 2015).  which norms study to use?
#'
#' @return a ggplot object, to be used as a template for other plots
#' @export

rit_height_weight_npr <- function(
  measurementscale,
  color_list = rainbow_colors(),
  ribbon_alpha = .35,
  annotation_style = 'points',
  line_style = 'none',
  spring_only = TRUE,
  norms = 2015
) {
  measurementscale_in <- measurementscale
  e <- new.env()
  
  if (norms == 2011) {
    e$norms_dense <- student_status_norms_2011_dense_extended %>%
      grade_level_seasonify() %>%
      dplyr::filter(measurementscale == measurementscale_in)
  } else if (norms == 2015) {
    e$norms_dense <- student_status_norms_2015_dense_extended %>%
      grade_level_seasonify() %>%
      dplyr::filter(measurementscale == measurementscale_in)
  }

  #rn up, rn down
  e$norms_dense <- e$norms_dense %>%
    dplyr::group_by(
      measurementscale, fallwinterspring, grade_level_season, student_percentile) %>%
    dplyr::mutate(
      rn_up = rank(RIT),
      rn_down = rank(-RIT)
    ) 
  #add y axis margins - right
  placeholder1 <- e$norms_dense %>%
    dplyr::ungroup() %>%
    dplyr::filter(grade_level_season == max(grade_level_season)
  )
  #arbitrary, just needs to be bigger than max
  placeholder1$grade_level_season <- max(e$norms_dense$grade_level_season) + 2
  placeholder1$grade <- max(e$norms_dense$grade_level_season) + 2
  
  #margins - left
  placeholder2 <- e$norms_dense %>%
    dplyr::ungroup() %>%
    dplyr::filter(grade_level_season == min(grade_level_season)
  )
  #arbitrary, just needs to be smaller than min
  placeholder2$grade_level_season <- min(e$norms_dense$grade_level_season) - 2
  placeholder2$grade <- min(e$norms_dense$grade_level_season) - 2
  
  e$norms_dense <- dplyr::bind_rows(e$norms_dense, placeholder1, placeholder2)
  
  #only one per percentile
  bottom <- e$norms_dense %>%
    dplyr::ungroup() %>%
    dplyr::filter(student_percentile < 50 & rn_down == 1) 
  top <- e$norms_dense %>%
    dplyr::ungroup() %>%
    dplyr::filter(student_percentile >= 50 & rn_up == 1) 
  e$norms_dense <- rbind(bottom, top)
  
  e$norms_dense <- e$norms_dense %>%
    dplyr::arrange(measurementscale, grade_level_season, RIT)

  if (spring_only) {
    e$norms_dense <- e$norms_dense %>%
      dplyr::ungroup() %>%
      dplyr::filter(fallwinterspring == 'Spring' | 
          grade_level_season %in% c(-0.8, min(grade_level_season))
      )
  }

  #cutting into ribbon bins
  e$npr_grades <- c(
    min(e$norms_dense$grade_level_season), 
    -0.8, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 
    max(e$norms_dense$grade_level_season)
  )
  e$nprs <- c(1, 5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 95, 99)
  
  e$npr_band01 <- subset(e$norms_dense, student_percentile == e$nprs[1])
  e$npr_band05 <- subset(e$norms_dense, student_percentile == e$nprs[2])
  e$npr_band10 <- subset(e$norms_dense, student_percentile == e$nprs[3])
  e$npr_band20 <- subset(e$norms_dense, student_percentile == e$nprs[4])
  e$npr_band30 <- subset(e$norms_dense, student_percentile == e$nprs[5])
  e$npr_band40 <- subset(e$norms_dense, student_percentile == e$nprs[6])
  e$npr_band50 <- subset(e$norms_dense, student_percentile == e$nprs[7])
  e$npr_band60 <- subset(e$norms_dense, student_percentile == e$nprs[8])
  e$npr_band70 <- subset(e$norms_dense, student_percentile == e$nprs[9])
  e$npr_band80 <- subset(e$norms_dense, student_percentile == e$nprs[10])
  e$npr_band90 <- subset(e$norms_dense, student_percentile == e$nprs[11])
  e$npr_band95 <- subset(e$norms_dense, student_percentile == e$nprs[12])
  e$npr_band99 <- subset(e$norms_dense, student_percentile == e$nprs[13])

  #what is needed is a data frame with ribbon, x, ymin, and ymax
  #make them per band, then rbind  
    #first make the top and bottom - custom
    e$df_npr1 <- data.frame(
      rib = rep('below_1', nrow(e$npr_band01)),
      x = e$npr_band01$grade_level_season,
      #dummy value - just needs to be small
      ymin = rep(90, nrow(e$npr_band01)),
      ymax = e$npr_band01$RIT
    )
    e$df_npr99 <- data.frame(
      rib = rep('above_99', nrow(e$npr_band99)),
      x = e$npr_band99$grade_level_season,
      #dummy value - just needs to be big
      ymin = e$npr_band99$RIT,
      ymax = rep(300, nrow(e$npr_band99))
    )
   e$df <- rbind(e$df_npr1, e$df_npr99)
 
   #then generate the others in a loop
   bands <- ls(pattern = "npr_band*", envir = e)
   
   #list to hold ribbon names
   e$ribbons <- rep(NA, 12)
   
   for (i in 1:(length(bands) - 1)) {
     new_df_name <- paste(bands[i], bands[i + 1], sep = '_')
     #remove 'band'
     new_df_name <- gsub('band', '', new_df_name)
     
     #lower and upper df
     lower <- get(bands[i], envir = e)
     upper <- get(bands[i + 1], envir = e)
     
     #make a new df for this ribbon
     inner_df <- data.frame(
       rib = rep(new_df_name, nrow(lower)),
       x = lower$grade_level_season,
       ymin = lower$RIT,
       ymax = upper$RIT
     )
     
     #rbind to existing df
     e$df <- rbind(e$df, inner_df)
     #update list of ribbons
     e$ribbons[i] <- new_df_name
   }
        
  #now make the geom_ribbons
    #first make top & bottom
    e$rib_under_1 <- ggplot2::geom_ribbon(
      data = e$df[e$df$rib == 'below_1', ],
      aes(x = x, ymin = ymin, ymax = ymax),
      fill = color_list[1],
      alpha = ribbon_alpha
    )
    
    e$rib_above_99 <- ggplot2::geom_ribbon(
      data = e$df[e$df$rib == 'above_99', ],
      aes(x = x, ymin = ymin, ymax = ymax),
      fill = color_list[14],
      alpha = ribbon_alpha
    )
 
   for (i in 1:length(e$ribbons)) {
     new_rib_name <- paste('rib', e$ribbons[i], sep = '_')
     #make ribbon
     inner_ribbon <- ggplot2::geom_ribbon(
       data = e$df[e$df$rib == e$ribbons[i], ],
       aes(x = x, ymin = ymin, ymax = ymax),
       fill = color_list[i + 1],
       alpha = ribbon_alpha  
     )
     
     #appropriate df
     assign(new_rib_name, inner_ribbon, envir = e)
   }
 
  #base ggplot 
  p <- ggplot(
    data = e$norms_dense %>% dplyr::filter(student_percentile %in% e$nprs), 
    environment = e
    )
  
  #annotation style options
  if (grepl('points', annotation_style)) {
    npr_annotation <- geom_point(
      aes(x = grade_level_season, y = RIT)
    )
  } else if (grepl('big numbers', annotation_style)) {
    npr_annotation <- geom_text(
      aes(x = grade_level_season, y = RIT, label = student_percentile
      )
    )
  } else if (grepl('small numbers', annotation_style)) {
    npr_annotation <- geom_text(
      aes(x = grade_level_season, y = RIT, label = student_percentile),
      size = 3,  
      fontface = "italic",
      color = 'gray40',
      alpha = 0.8
    ) 
  } else {
    npr_annotation <- NULL
  } 
  
  #lines
  if (grepl('gray lines', line_style)) {
    npr_lines <- geom_line(
        aes(x = grade_level_season, y = RIT, group = student_percentile),
        size = 0.5,
        color = 'gray80'
      )
  } else if (grepl('gray dashed', line_style)) {
     npr_lines <- geom_line(
        aes(x = grade_level_season, y = RIT, group = student_percentile),
        size = 0.5,
        color = 'gray80',
        lty = 'dashed'
      ) 
  } else {
    npr_lines <- NULL
  }
  
  #put it all together
  p <- p + 
  e$rib_under_1 + 
  e$rib_npr_01_npr_05 +
  e$rib_npr_05_npr_10 +
  e$rib_npr_10_npr_20 +
  e$rib_npr_20_npr_30 +
  e$rib_npr_30_npr_40 +
  e$rib_npr_40_npr_50 +
  e$rib_npr_50_npr_60 +
  e$rib_npr_60_npr_70 +
  e$rib_npr_70_npr_80 +
  e$rib_npr_80_npr_90 +
  e$rib_npr_90_npr_95 +
  e$rib_npr_95_npr_99 +
  e$rib_above_99 +   
  npr_annotation +
  npr_lines
  
  return(p)
}


#' Wrapper to make student percentile rank goal sheet templates KIPP NJ style
#'
#' @param measurementscale target subject
#'
#' @return a ggplot template
#' @export

npr_goal_sheet_style <- function(measurementscale) {
  
  p <- rit_height_weight_npr(
    measurementscale = measurementscale,
    ribbon_alpha = .4,
    annotation_style = 'small numbers',
    line_style = 'none' 
  ) + 
  theme_bw() +
  theme(
    panel.grid = element_blank()
  )

  return(p)
}


#' Makes the base template that shows the RIT space and corresponding
#' ACT lines using the original NWEA MAP ACT linking study
#'
#' @param measurementscale c('Reading', 'Mathematics') - there is no linking
#' study for Language or Science
#' @param color_list vector of colors to use to shade the bands.  Default is
#' the output of rainbow_colors().
#' @param annotation_style c('points', 'big numbers', or 'small numbers')
#' @param line_style c('gray lines', 'gray dashed')
#' @param school_type c('ES', 'MS')
#' @param localization controls names/breakpoints for college labels and
#' ACT tiers.  See localization.R for more details
#'
#' @return a ggplot object, to be used as a template for other plots
#' @export

rit_height_weight_ACT <- function(
  measurementscale,
  color_list = rainbow_colors(),
  annotation_style = 'points',
  line_style = 'none',
  school_type = 'MS',
  localization = localize('Newark')
) {
  e <- new.env()
  
  #subset  
  act_df <- act_df[act_df$subject == measurementscale, ]

  chart_settings <- list(
    'MS' = list(
      'y_disp_min' = 180,
      'y_disp_max' = 290,
      'ribbon_alpha' = .3, 
      'college_text_color' = (scales::alpha("gray50", 0.4)),
      'college_name_size' = 4.5,
      'chart_angle' = 27,
      'act_lines_alpha' = .3,
      'act_x' = 10.8,
      'act_grade_for_y' = 11,
      'act_color' = (scales::alpha("gray50", 0.6)),
      'act_size' = 3,
      'act_angle' = 6,
      'act_vjust' = 0.5,
      'act_hjust' = 0.65
    ),
    'ES' = list(
      'y_disp_min' = 130,
      'y_disp_max' = 220,
      'ribbon_alpha' = .3,
      'college_text_color' = (scales::alpha("gray50", 0.4)),
      'college_name_size' = 4.5,
      'chart_angle' = 30,
      'act_lines_alpha' = .3,
      'act_x' = -0.7,
      'act_grade_for_y' = -0.7,
      'act_color' = (scales::alpha("gray50", 0.6)),
      'act_size' = 3,
      'act_angle' = 15,
      'act_vjust' = 0.5,
      'act_hjust' = 0.2   
    )
  )
  
  #what flavor of chart are we making?
  active_settings = chart_settings[[school_type]]
  
  #we have to add some 'margin' above and below the maximum of our plot
  #values are basically arbitrary but needed so that charts don't truncate in a weird way.
    #y axis margin big
    placeholder1 <- act_df[act_df$grade == 11, ]
    #arbitrary, just needs to be bigger than 11
    placeholder1$grade <- 14
    act_df <- rbind(act_df, placeholder1)

    #y axis margin small
    placeholder2 <- act_df[act_df$grade == -0.8, ]
    #arbitrary, just needs to be smaller than -1
    placeholder2$grade <- -3
    act_df <- rbind(act_df, placeholder2)

    e$act_df <- act_df[with(act_df, order(grade)), ]

  #make ribbons and labels here
  #add 1 and 36 to personalized cuts
  act_bands <- c(min(act_df$act), localization$act_cuts, 36)
  
  #store names of everything that gets made
  ribbon_names = c()
    
  #iterate over the list of bands and make stuff
  for (i in 1:(length(act_bands) - 1)) {
    #which cuts
    low_cut <- act_bands[i]
    high_cut <- act_bands[i+1]
    
    #subset the main act df
    lower <- act_df[act_df$act == low_cut, ]
    higher <- act_df[act_df$act == high_cut, ]
    
    #as df
    inner_df <- data.frame(
      x = lower$grade,
      ymin = lower$rit,
      ymax = higher$rit
    )
    
    #now make a ribbon
      #first give it a name
      new_rib_name <- paste0('rib', '_', low_cut, '_', high_cut)
    
      #make it
      inner_ribbon <- ggplot2::geom_ribbon(
        data = inner_df,
        aes(x = x, ymin = ymin, ymax = ymax),
        fill = color_list[i + 1],
        alpha = active_settings$ribbon_alpha
      )
    
      #assign variable name
      assign(new_rib_name, inner_ribbon, envir = e)
      
      #add to list of ribbons
      ribbon_names = c(ribbon_names, new_rib_name)
  }
      
  #base ggplot 
  p <- ggplot(
    data = act_df[act_df$act %in% localization$act_cuts, ],
    environment = e
  ) +
  theme_bw()
  
  #put all the ribbons on it
  for (i in ribbon_names) {
    p <- p + get(i, envir = e)
  }
    
  #annotation style options
  if (grepl('points', annotation_style)) {
    act_annotation <- geom_point(
      aes(
        x = grade,
        y = rit
      )
    )
  } else if (grepl('big numbers', annotation_style)) {
    act_annotation <- geom_text(
      data = act_df[act_df$act %in% localization$act_trace_lines, ],
      aes(
        x = grade,
        y = rit,
        label = act
      )
    )
  } else if (grepl('small numbers', annotation_style)) {
    act_annotation <- geom_text(
      data=act_df[act_df$act %in% localization$act_trace_lines, ],
      aes(
        x = grade,
        y = rit,
        label = act
      ),
      size = 3,
      fontface="italic",
      color = 'gray40',
      alpha = 0.8
    ) 
  } else {
    act_annotation <- NULL
  }
  
  #lines
  if (grepl('gray lines', line_style)) {
    act_lines <- geom_line(
      data = act_df[act_df$act %in% localization$act_trace_lines, ],
      aes(
        x = grade,
        y = rit,
        group = act        
      ),
      size = 0.5,
      color = 'gray80'
    )
  } else if (grepl('gray dashed', line_style)) {
    act_lines <- geom_line(
      data = act_df[act_df$act %in% localization$act_trace_lines, ],
      aes(
        x = grade,
        y = rit,
        group = act        
      ),
      size = 0.5,
      color = 'gray80',
      lty = 'dashed'
    )
  } else {
    act_lines <- NULL
  }
  
  #put it together
  p <- p + act_annotation + act_lines 
  
  #make x axis intelligent
  grade_xs <- act_df[act_df$act %in% localization$act_trace_lines, 'grade']
  
  x_breaks <- sort(unique(grade_xs))
  x_labels <- unlist(lapply(x_breaks, fall_spring_me))
  
  p <- p + scale_x_continuous(breaks = x_breaks, labels = x_labels)
    
  #don't want the grid lines
  p <- p + theme(panel.grid = element_blank()) 
  
  #labels etc
  p <- p + labs(x = 'Grade/Season', y = 'RIT')
  
  return(p)
}


#' creates vector of rainbow colors for student plots
#'
#' @return a vector of colors

rainbow_colors <- function() {
  
  rainbow_all <- rainbow(20)
  rainbow_subset <- c(rainbow_all[2:6], rainbow_all[9:17])
  my_colors <- rainbow_subset   
  
  return(my_colors)
}


#' helper function to calculate plot elements per-student for college plots
#'
#' @param stu_rit_history data frame (with cdf headers) with one student
#' @param decode_ho holdovers create all kinds of funkiness.  decode_ho will
#' find apparent holdover events, and only return the student's second bite
#' at that grade/season apple.
#'
#' @return a list of calculations

stu_RIT_hist_plot_elements <- function(stu_rit_history, decode_ho = TRUE) {
  
  if (decode_ho) {
    stu_rit_history$grade_year <- paste0(
      stu_rit_history$grade, stu_rit_history$map_year_academic) %>% 
        as.integer()
    
    stu_rit_history <- stu_rit_history %>%
      dplyr::group_by(measurementscale, grade) %>%
      dplyr::mutate(
        rn_ho = rank(-grade_year, ties.method = 'min')
      ) %>% 
      dplyr::filter(rn_ho == 1)
  }
  
  #calculate min/max x and y
  min_y <- round_to_any(
    x = min(stu_rit_history$testritscore), accuracy = 10, f = floor
  )
  max_y <- round_to_any(
    x = max(stu_rit_history$testritscore), accuracy = 10, f = ceiling
  )
  min_x <- round_to_any(
    x = min(stu_rit_history$grade_level_season), accuracy = 1, f = floor
  )
  max_x <- round_to_any(
    x = max(stu_rit_history$grade_level_season), accuracy = 1, f = ceiling
  )  
  
  #add a line showing previous scores
  rit_hist_line <- geom_line(
    aes(
      x = grade_level_season,
      y = testritscore
    ),
    data = stu_rit_history,
    size = 1.5
  )
  
  #line that drops non-entry fall
  stu_rit_history_nofall <- stu_rit_history %>% dplyr::filter(
    fallwinterspring %in% c('Spring', 'Winter') | 
    (fallwinterspring == 'Fall' & grade == min(grade))
  )

  rit_hist_line_nofall <- geom_line(
    aes(
      x = grade_level_season,
      y = testritscore
    ),
    data = stu_rit_history_nofall,
    size = 1.5
  )  
  
  #line that drops non-entry fall AND winter
  stu_rit_history_nofall_nowinter <- stu_rit_history %>% dplyr::filter(
    fallwinterspring == 'Spring' | (fallwinterspring == 'Fall' & grade == min(grade))
  )
  
  rit_hist_line_nofall_nowinter <- geom_line(
    aes(
      x = grade_level_season,
      y = testritscore
    ),
    data = stu_rit_history_nofall_nowinter,
    size = 1.5
  )  

  #show test events
  rit_hist_points <- geom_point(
    data = stu_rit_history,
    aes(
      x = grade_level_season, 
      y = testritscore
    ),
    shape = 21,
    color = 'white',
    size = 4,
    fill = 'white',
    alpha = 0.9
  )
  
  #label
  rit_hist_text <- geom_text(
    data = stu_rit_history,
    aes(
      x = grade_level_season,
      y = testritscore,
      label = paste0(
       grade, ' ' , gsub('ing|ter', '', fallwinterspring), ': ',
       testritscore)
    ),
    size = 3,
    color = 'gray30',
    vjust = 1.5
  )
  
  low_grade <- min(stu_rit_history$grade, na.rm = TRUE)
  high_grade <- max(stu_rit_history$grade, na.rm = TRUE)
      
  low_grade_ord <- ifelse(
    low_grade < 1, paste0(low_grade, 'th'), toOrdinal::toOrdinal(low_grade)
  )
  high_grade_ord <- ifelse(
    high_grade < 1, paste0(high_grade, 'th'), toOrdinal::toOrdinal(high_grade)
  )

  out <- list(
    'plot_elements' = list(
      'line' = rit_hist_line,
      'line_nofall' = rit_hist_line_nofall,
      'line_nofall_nowinter' = rit_hist_line_nofall_nowinter,
      'points' = rit_hist_points,
      'text' = rit_hist_text
    ),
    'plot_limits_round' = list(
      'min_x' = min_x, 'max_x' = max_x,
      'min_y' = min_y, 'max_y' = max_y
    ),
    'plot_limits_exact' = list(
      'min_x' = min_x - 0.1, 'max_x' = max_x + 0.1,
      'min_y' = min_y - 1, 'max_y' = max_y + 1
    ),
    'labels' = list(
      'low_grade' = low_grade, 'high_grade' = high_grade,
      'low_grade_ord' = low_grade_ord, 'high_grade_ord' = high_grade_ord
    )
  )
  
  return(out)
}


#' abstract out the logic for writing college labels onto a template.
#' @description this was non-trivial, so it gets its own little function.
#' 
#' @param xy_lim_list student max/min x and y, from stu_RIT_hist_plot_elements
#' @param measurementscale target subject
#' @param labels_at_grade what grade level should the college labels 
#' print at?  Generally the student or cohorts's most recent test 
#' grade_level_season is desirable.
#' @param localization controls names/breakpoints for college labels and
#' ACT tiers.  See localization.R for more details
#' @param aspect_ratio college labels should print at the same
#' angle as the act ribbons.  if the viz is not square, this requires an
#' adjustment.  default value is 1, 0.5 would be a rectangle 2W for 1H.
#' @param label_size text size for the labels.  default is 5.
#'
#' @return a ggplot geom_text object with college labels

college_label_element <- function(
  xy_lim_list,
  measurementscale,
  labels_at_grade = 6,
  localization = localize('Newark'),
  aspect_ratio = 1,
  label_size = 5
) {

  act_bands <- c(localization$act_cuts, max(act_df$act))
  
  labels_df <- act_df[act_df$subject == measurementscale & 
                        act_df$act %in% act_bands &
                        act_df$grade == labels_at_grade, ]  
  
  valid_ys <- na.omit(labels_df$rit + 0.5 * (dplyr::lead(labels_df$rit, 1) - labels_df$rit))
  
  #some light calculus to find the angle of the label.
  #angle is the slope of the tangent line to the curve.
  #all the ACT curves have the same form, so we just need to get the slope once.
  
  #slope of tangent line to y=ax^2 + bx +c is 2ap + b where p is the x value in question.
  #(read about it: http://www.math.dartmouth.edu/opencalc2/cole/lecture3.pdf)
  #x value in question = labels_at_grade parameter
  #so... we just need the coefficients for the act slopes
  
  #coefficients for ACT 23 because why not
  coefs <- list(
    'Mathematics'=list('a'=-0.5961, 'b'=13.8734, 'c'='irrelevant (174.347)'),
    'Reading'=list('a'=-0.3161, 'b'=8.2295, 'c'='irrelevant (185.6195)')  
  )
  
  #get the active coefs
  active_coefs = coefs[[measurementscale]]
  
  #calculate slope of tangent line
  tan_slope = 2 * active_coefs[['a']] * labels_at_grade + 0.5 + active_coefs[['b']]
    
  #need to account for viewport..
  plot_xrange <- xy_lim_list[['max_x']] - xy_lim_list[['min_x']]
  plot_yrange <- xy_lim_list[['max_y']] - xy_lim_list[['min_y']]
  
  asp <- plot_xrange / plot_yrange 
  
  college_text <- geom_text(
    data = data.frame(
      x_pos = rep(labels_at_grade, length(valid_ys)),
      y_val = valid_ys,
      label = localization$canonical_colleges
    ),
    aes(
      x = x_pos,
      y = y_val,
      label = label
    ),
    angle = 180/pi*atan(tan_slope * asp * aspect_ratio),
    hjust = 1,
    vjust = 0.5,
    size = label_size
  )
  
  return(college_text)
}


#' Combines a template and a mapvizieR object to create a student goal plot
#' with college labels
#'
#' @param base_plot a height/weight template.
#' @param mapvizieR_obj conforming mapvizieR object
#' @param studentid target student
#' @param measurementscale target subject
#' @param labels_at_grade what grade level should the college labels 
#' print at?  Generally the students's most recent test grade_level_season
#' is desirable.
#' @param localization controls names/breakpoints for college labels and
#' ACT tiers.  See localization.R for more details
#' @param aspect_ratio college labels should print at the same
#' angle as the act ribbons.  if the viz is not square, this requires an
#' adjustment.  default value is 1, 0.5 would be a rectangle 2W for 1H.
#'
#' @return a ggplot object
#' @export

build_student_college_plot <- function(
  base_plot,
  mapvizieR_obj,
  studentid,
  measurementscale,
  labels_at_grade,
  localization = localize('Newark'),
  aspect_ratio = 1
) {
  #1. get stu_RIT_hist_plot_elements
  stu_map_df <- mv_limit_cdf(mapvizieR_obj, studentid, measurementscale)
  stu_elements <- stu_RIT_hist_plot_elements(stu_map_df)
  
  #2. with data from step 1, put the college labels at the right spot
  college_labels <- college_label_element(
    xy_lim_list = stu_elements[['plot_limits_exact']],
    measurementscale = measurementscale,
    labels_at_grade = labels_at_grade,
    localization = localization,
    aspect_ratio = aspect_ratio
  ) 
  
  min_y <- stu_elements[['plot_limits_round']][['min_y']]
  max_y <- stu_elements[['plot_limits_round']][['max_y']]
  min_x <- stu_elements[['plot_limits_round']][['min_x']]
  max_x <- stu_elements[['plot_limits_round']][['max_x']]
  
  #3. put everything together
  p <- base_plot + 
    college_labels + 
    stu_elements[['plot_elements']][['line']] + 
    stu_elements[['plot_elements']][['points']] +
    stu_elements[['plot_elements']][['text']]
    
  #axis limits
  p <- p + 
  coord_cartesian(
    ylim = c(min_y - 1, max_y + 1),
    xlim = c(min_x - 0.1, max_x + 0.1)
  ) +
  #format x
  scale_x_continuous(
    breaks = seq(min_x, max_x, by = 1) 
  ) +
  scale_y_continuous(
    breaks = seq(
      min_y, max_y, by = ifelse(max_y-min_y < 13, 2, round_to_any((max_y-min_y)/5, 5)))
  ) + 
  labs(
    x = 'Grade', y = 'RIT Score'
  )

  return(p)
}


#' Bulk generates student historic college plots
#'
#' @param mapvizieR_obj a conforming mapvizieR object
#' @param studentids a vector of target studentids
#' @param measurementscale desired subject
#' @param localization controls names/breakpoints for college labels and
#' ACT tiers.  See localization.R for more details
#' @param labels_at_grade what grade level should the college labels 
#' print at?  Generally the cohort's most recent test grade_level_season
#' is desirable.
#' @param template c('npr', 'ACT').  default is npr.
#' @param aspect_ratio college labels should print at the same
#' angle as the act ribbons.  if the viz is not square, this requires an
#' adjustment.  default value is 1, 0.5 would be a rectangle 2W for 1H.
#' @param annotation_style style for the underlying template.  See 
#' rit_height_weight_ACT and rit_height_weight_npr for details.
#' @param line_style c('gray lines', 'gray dashed')
#' @param title_text what text to print above the plot?
#'
#' @return a list of ggplot objects
#' @export

bulk_student_historic_college_plot <- function(
  mapvizieR_obj, 
  studentids, 
  measurementscale, 
  localization = localize('default'), 
  labels_at_grade,
  template = 'npr',  #npr or ACT
  aspect_ratio = 1,
  annotation_style = 'small numbers',
  line_style = 'gray lines',
  title_text = paste('1. Where have I been? ', measurementscale, '\n')
) {

  if (template == 'ACT') {
    blank_template <- rit_height_weight_ACT(
      measurementscale = measurementscale,
      localization = localization,
      annotation_style = annotation_style,
      line_style = line_style
    ) + theme_bw()
  } else if (template == 'npr') {
    blank_template <- npr_goal_sheet_style(measurementscale)
  }
    
  plot_list <- list()
  
  roster <- mapvizieR_obj$roster
  
  for (i in studentids) {
    data_test <- i %in% mapvizieR_obj$cdf$studentid
    if (!data_test) next
    
    stu_name <- roster %>% dplyr::filter(studentid == i) %>% 
      dplyr::select(studentfirstlast) %>%
      unique() %>% magrittr::extract(1) %>% unlist() %>% unname()
    
    p <- build_student_college_plot(
      base_plot = blank_template,
      mapvizieR_obj = mapvizieR_obj,
      studentid = i,
      measurementscale = measurementscale,
      labels_at_grade = labels_at_grade,
      aspect_ratio = aspect_ratio
    ) + labs(
      title = paste(title_text, stu_name)
    ) +
    theme(plot.title = element_text(hjust = 0))
    
    
    plot_list[[i]] <- p
  }
  
  return(plot_list)
}



#' Finds the centroid of a triangle
#'
#' @param x1 first x coord 
#' @param x2 second x coord
#' @param x3 third x coord
#' @param y1 first y coord
#' @param y2 second y coord
#' @param y3 third y coord
#'
#' @return a numeric vector length 2 with the xy coord of the centroid
#' @export

centroid <- function(x1, x2, x3, y1, y2, y3) {
  cx <- (x1 + x2 + x3) / 3
  cy <- (y1 + y2 + y3) / 3
  
  return(c(cx,cy))
}


#' Generates a one-term goal plot for one student
#'
#' @param base_plot either the output of rit_height_weight_ACT,
#' rit_height_weight_npr, or a wrapper around one of those templates
#' @param mapvizieR_obj a conforming mapvizieR object
#' @param studentid one target studentid
#' @param measurementscale desired subject
#' @param start_grade show student history starting with this grade level.
#' We generally go back one year, to show the baseline that the goals derive 
#' from.
#' @param end_grade show student history ending with this grade level
#' @param labels_at_grade what grade level should the college labels 
#' print at?  Generally the student's most recent test grade_level_season
#' is desirable.
#' @param growth_window for looking up the window of SGP outcomes, what 
#' growth window should we use?
#' @param localization controls names/breakpoints for college labels and
#' ACT tiers.  See localization.R for more details
#' @param aspect_ratio college labels should print at the same
#' angle as the act ribbons.  if the viz is not square, this requires an
#' adjustment.  default value is 1, 0.5 would be a rectangle 2W for 1H.
#'
#' @return a list of ggplot objects
#' @export

build_student_1year_goal_plot <- function(
  base_plot,
  mapvizieR_obj,
  studentid,
  measurementscale,
  start_grade,
  end_grade,
  labels_at_grade,
  growth_window = 'Spring to Spring',
  localization = localize('Newark'),
  aspect_ratio = 1
) {
  studentid_in <- studentid
  measurementscale_in <- measurementscale
  start_grade_in <- start_grade
  end_grade_in <- end_grade
  growth_window_in <- growth_window
  
  #get the growth df data
  stu_growth <- mapvizieR_obj$growth_df %>%
    dplyr::ungroup() %>%
    dplyr::filter(
      studentid == studentid_in & 
      measurementscale == measurementscale_in &
      start_grade == start_grade_in &
      growth_window == growth_window_in
    ) %>%
    dplyr::arrange(desc(start_teststartdate))

  stu_baseline <- stu_growth[1, ]$start_testritscore
  typ_growth <- stu_growth[1, ]$typical_growth
  rep_growth <- stu_growth[1, ]$reported_growth
  sd_growth <- stu_growth[1, ]$std_dev_of_expectation
  accel_growth <- stu_growth[1, ]$accel_growth
  
  #CHART - GOALS
  cgps <- data.frame(
    cgp = seq(1, 99, 1),
    rit_change = qnorm(seq(0.01, 0.99, 0.01), typ_growth, sd_growth)
  )
  cgps$end_rit <- stu_baseline + cgps$rit_change
  
  #df for triangle
  x1 <- start_grade
  y1 <- stu_baseline
  
  x2 <- end_grade
  y2 <- cgps[cgps$cgp == 10, 'end_rit', drop = TRUE]
  
  x3 <- end_grade
  y3 <- cgps[cgps$cgp == 30, 'end_rit', drop = TRUE]
  
  x4 <- end_grade
  y4 <- cgps[cgps$cgp == 50, 'end_rit', drop = TRUE]

  x5 <- end_grade
  y5 <- cgps[cgps$cgp == 70, 'end_rit', drop = TRUE]

  x6 <- end_grade
  y6 <- cgps[cgps$cgp == 90, 'end_rit', drop = TRUE]
    
  whole_triangle <- data.frame(x = c(x1, x2, x6), y = c(y1, y2, y6))
  sgp_alpha = 0.4
  tri_alpha = 0.8
  tri_color = 'gray70'
  tri_lty = 'dashed'
  big_text = 4
  small_text = 3
  big_point = 4
  small_point = 3
  
  #college labels
  ys <- c(y1, y2, y3, y4, y5, y6, stu_baseline + accel_growth)
  min_x <- start_grade - 0.1 
  max_x <- end_grade + 0.1
  min_y <- round_to_any(min(ys) - 1, 5, floor)
  max_y <- round_to_any(max(ys) + 1, 5, ceiling)
  
  college_labels <- college_label_element(
    xy_lim_list = list(
      'min_x' = min_x,
      'max_x' = max_x,
      'min_y' = min_y,
      'max_y' = max_y
    ),
    measurementscale = measurementscale,
    labels_at_grade = labels_at_grade,
    localization = localization
  ) 
  
  p <- base_plot + college_labels
  
  p <- p + 
    geom_polygon(
      data = whole_triangle,
      aes(x, y),
      fill = 'white',
      color = NA,
      alpha = sgp_alpha
    ) +
    geom_line(
      data = data.frame(x = c(x1, x2), y = c(y1, y2)), 
      aes(x, y), 
      size = 0.5,
      lty = tri_lty,
      color = tri_color,
      alpha = tri_alpha
    ) +
    geom_line(
      data = data.frame(x = c(x1, x3), y = c(y1, y3)), 
      aes(x, y),
      size = 0.5,
      lty = tri_lty,
      color = tri_color,
      alpha = tri_alpha
    ) +
    geom_line(
      data = data.frame(x = c(x1, x4), y = c(y1, y4)), 
      aes(x, y), 
      size = 0.5,
      lty = tri_lty,
      color = tri_color,
      alpha = tri_alpha
    ) +
    geom_line(
      data = data.frame(x = c(x1, x5), y = c(y1, y5)), 
      aes(x, y), 
      size = 0.5,
      lty = tri_lty,
      color = tri_color,
      alpha = tri_alpha
    ) +
    geom_line(
      data = data.frame(x = c(x1, x6), y = c(y1, y6)), 
      aes(x, y), 
      size = 0.5,
      lty = tri_lty,
      color = tri_color,
      alpha = tri_alpha
    ) 
  
  #draw triangles        
  c_q1 <- centroid(x1, x2, x3, y1, y2, y3)
  c_q2 <- centroid(x1, x3, x4, y1, y3, y4)
  c_q3 <- centroid(x1, x4, x5, y1, y4, y5)
  c_q4 <- centroid(x1, x5, x6, y1, y5, y6)
    
  p <- p + 
    annotate(
      "text", label = "Low Growth", x = c_q1[1], y = c_q1[2], 
      color = 'black', size = big_text, vjust = .5
    ) +
    annotate(
      "text", label = "Low/Average Growth", x = c_q2[1], 
      y = c_q2[2], color = 'black', size = big_text, vjust = .5
    ) +
    annotate(
      "text", label = "High Growth", x = c_q3[1], y = c_q3[2], 
      color = 'black', size = big_text, vjust = .5
    ) +
    annotate(
      "text", label = "Very High Growth!", x = c_q4[1], y = c_q4[2], 
      color = 'black', size = big_text, vjust = .5
    )        

  point_df <- data.frame(
    x = c(start_grade, end_grade, end_grade),
    y = c(stu_baseline, stu_baseline + rep_growth, stu_baseline + accel_growth),
    label = c('Baseline', paste0(stu_baseline + rep_growth, ' (Keep Up)'),
      paste0(stu_baseline + accel_growth, ' (Rutgers Ready)')),
    point_type = c('Baseline', 'Keep Up', 'Rutgers Ready'),
    stringsAsFactors = FALSE
  )
  p <- p + geom_point(
    data = point_df[point_df$point_type == 'Baseline', ],
    aes(
      x = x,
      y = y
    ),
    size = 3
  ) +
  geom_text(
    data = point_df[point_df$point_type == 'Baseline', ],
    aes(
      x = x, 
      y = y,
      label = label
    ),
    vjust = 1
  )
  
  p <- p + geom_point(
    data = point_df[point_df$point_type == 'Keep Up', ],
    aes(
      x = x,
      y = y
    ),
    shape = 3,
    color = 'red',
    size = 5,
    alpha = 0.9
  ) + geom_text(
    data = point_df[point_df$point_type == 'Keep Up', ],
    aes(
      x = x,
      y = y,
      label = label
    ),
    color = 'red',
    size = 5,
    alpha = 0.9,
    vjust = 1
  )
  
  p <- p + geom_point(
    data = point_df[point_df$point_type == 'Rutgers Ready', ],
    aes(
      x = x,
      y = y
    ),
    shape = 3,
    color = 'red',
    size = 5,
    alpha = 0.9
  ) + geom_text(
    data = point_df[point_df$point_type == 'Rutgers Ready', ],
    aes(
      x = x,
      y = y,
      label = label
    ),
    color = 'red',
    size = 5,
    alpha = 0.9,
    vjust = 1
  )
  

  p <- p + coord_cartesian(
    ylim = c(min_y, max_y),
    xlim = c(min_x, max_x)
  )
  
  return(p)
}


#' Bulk generates student goal plots
#'
#' @param mapvizieR_obj a conforming mapvizieR object
#' @param studentids vector of target studentids
#' @param measurementscale desired subject
#' @param labels_at_grade what grade level should the college labels 
#' print at?  Generally the student's most recent test grade_level_season
#' is desirable.
#' @param start_grade show student history starting with this grade level.
#' We generally go back one year, to show the baseline that the goals derive 
#' from.
#' @param end_grade show student history ending with this grade level
#' @param growth_window for looking up the window of SGP outcomes, what 
#' growth window should we use?
#' @param localization controls names/breakpoints for college labels and
#' ACT tiers.  See localization.R for more details
#' @param aspect_ratio college labels should print at the same
#' angle as the act ribbons.  if the viz is not square, this requires an
#' adjustment.  default value is 1, 0.5 would be a rectangle 2W for 1H.
#' @param annotation_style style for the underlying template.  See 
#' rit_height_weight_ACT and rit_height_weight_npr for details.
#' @param line_style c('gray lines', 'gray dashed')
#' @param title_text what text to print above the plot?
#'
#' @return a list of ggplot objects
#' @export

bulk_student_1year_goal_plot <- function(
  mapvizieR_obj, 
  studentids, 
  measurementscale, 
  labels_at_grade,
  start_grade,
  end_grade,
  growth_window,
  localization = localize('Newark'), 
  aspect_ratio = 1,
  annotation_style = 'small numbers',
  line_style = 'gray lines',
  title_text = paste('2. What are my 2015-16 goals?', measurementscale, '\n')
) {

  blank_template <- rit_height_weight_ACT(
    measurementscale = measurementscale,
    localization = localization,
    annotation_style = annotation_style,
    line_style = line_style
  )
    
  plot_list <- list()
  
  roster <- mapvizieR_obj$roster
  
  for (i in studentids) {
    data_test <- i %in% mapvizieR_obj$cdf$studentid
    if (!data_test) next
    
    stu_name <- roster %>% dplyr::filter(studentid == i) %>% 
      dplyr::select(studentfirstlast) %>%
      unique() %>% magrittr::extract(1) %>% unlist() %>% unname()

    p <- build_student_1year_goal_plot(
      base_plot = blank_template,
      mapvizieR_obj = mapvizieR_obj,
      studentid = i,
      measurementscale = measurementscale,
      start_grade = start_grade,
      end_grade = end_grade,
      labels_at_grade = labels_at_grade,
      growth_window = growth_window,
      aspect_ratio = aspect_ratio
    ) + labs(
      title = paste(title_text, stu_name)
    ) +
    theme(plot.title = element_text(hjust = 0))
    
    
    plot_list[[i]] <- p
  }
  
  return(plot_list)
}
