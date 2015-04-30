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
#' @param p_arrow_colors vector of colors passed to ggplot.
#' @param p_arrow_tiers vector of colors passed to ggplot.
#' @param p_name_colors vector of colors passed to ggplot.
#' @param p_name_color_tiers vector of colors passed to ggplot.
#' @param p_quartile_colors vector of colors passed to ggplot.
#' @param p_name_size sets point size of student names.
#' @param p_alpha sets level fo transparency for goals. 
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
  p_arrow_colors = c("tan4", "snow4", "gold", "red"),
  p_arrow_tiers = c("Positive", "Typical", "College Ready", "Negative"),
  p_name_colors = c("#f3716b", "#79ac41", "#1ebdc2", "#a57eb8"),
  p_name_color_tiers = c("1","2","3","4"),
  p_quartile_colors = c('#f3716b', '#79ac41', '#1ebdc2', '#a57eb8'),
  p_name_size = 3,
  p_alpha = 1
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
  
  #is this ONE SEASON or TWO SEASON?
  if (any(df$complete_obsv)) {
    single_season_flag <- FALSE  
  } else {
    single_season_flag <- TRUE 
  }
  
  #make a psuedo-axis by ordering based on one variable
  df$y_order <- rank(
    x = df[ , sort_column]
    ,ties.method = "first"
    ,na.last = FALSE
  )
  
  #make growth status an ordered factor
  df$growth_status = factor(
    x = df$growth_status,
    levels = p_arrow_tiers,
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
  df$name_x <- ifelse(df$neg_flag == 1, df$end_testritscore - 6, df$start_testritscore - 0.25)
  #NAs
  df$name_x <- ifelse(is.na(df$name_x), df$start_testritscore - 0.25, df$name_x)
  
  df$rit_xoffset <- ifelse(df$neg_flag == 1, -.25, .25)
  df$rit_hjust <- ifelse(df$neg_flag == 1, 1, 0)
  
  #colors for identity! 
  arrow_colors <- data.frame(
    status = p_arrow_tiers,
    color = p_arrow_colors,
    stringsAsFactors = FALSE
  )
  #cribbing off of 'subscripting' http://rwiki.sciviews.org/doku.php?id=tips:data-frames:merge
  df$arrow_color_identity <- arrow_colors$color[match(df$growth_status, arrow_colors$status)]

  #start/end quartile colors
  quartile_colors <- data.frame(
    quartile = c(1,2,3,4),
    color = p_quartile_colors,
    stringsAsFactors = FALSE
  )
  df$baseline_color <- quartile_colors$color[match(df$start_testquartile, quartile_colors$quartile)]
  df$endpoint_color <- quartile_colors$color[match(df$end_testquartile, quartile_colors$quartile)]

  #thematic stuff
  pointsize <- 3
  segsize <- 1
  annotate_size <- 5

  #base ggplot object
  p <- ggplot(
    data = df
    ,aes(
      x = start_testritscore,
      y = y_order
    )
  )

  #make chart ----------------------------------------------------------
  #typical and college ready goal lines (want these behind segments)
  p <- p + 
  geom_point(
    aes(x = start_testritscore + typical_growth),
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
      x = start_testritscore + typical_growth
     ,label = start_testritscore + typical_growth
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

  #only do the following if there is data in end rit
  if (any(df$complete_obsv)) {
    #add segments
    p <- p +
    geom_segment(
      data = df[!is.na(df$end_testritscore), ],
      aes(
        xend = end_testritscore,
        yend = y_order,
        group = arrow_color_identity,
        color = arrow_color_identity
      ),
      arrow = arrow(length = unit(0.1, "cm"))
    ) 

    #add RIT text
    p <- p +
    geom_text(
      data = df[!is.na(df$end_testritscore) & df$student_name_format != ' ', ],
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

  return(p)  
}