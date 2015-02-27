#' @title Becca Vichniac's Quartile (Floating Bar) Chart 
#'
#' @description
#' \code{becca_plot} returns a ggplot object binned quaritle performonce
#'
#' @details 
#' This function builds and prints a bar graph with 4 bins per bar show MAP data
#' binned by quartile (National Percentile Rank).  Bars are centered at 50th percentile 
#' horizonatally
#' 
#' @param mapvizieR_obj mapvizieR object
#' @param studentids target students
#' @param measurementscale target subject
#' @param first_and_spring_only show all terms, or only entry & spring?  default is TRUE.
#' @param entry_grade_seasons which grade_level_seasons are entry grades?
#' @param detail_academic_year don't mask any data for this academic year
#' @param small_n_cutoff drop a grade_level_season if less than x% of the max? 
#' (useful when dealing with weird cohort histories)
#' @param color_scheme color scheme for the stacked bars.  options are 'KIPP Report Card', 
#' 'Sequential Blues', or a vector of 4 colors.
#' 
#' @return prints a ggplot object
#' 
#' @export

becca_plot <- function(
  mapvizieR_obj, 
  studentids, 
  measurementscale, 
  first_and_spring_only=TRUE, 
  entry_grade_seasons=c(-0.8, 4.3), 
  detail_academic_year=2014, 
  small_n_cutoff=.5,
  color_scheme='KIPP Report Card'
  ) {

  #data validation
  mv_opening_checks(mapvizieR_obj, studentids, 1)

  #TRANSFORMATION 1 - DATA PROCESSING

  #unpack the mapvizieR object and limit to desired students
  this_cdf <- mv_limit_cdf(mapvizieR_obj, studentids, measurementscale)
    
  #only valid seasons
  munge <- valid_grade_seasons(this_cdf, first_and_spring_only, 
    entry_grade_seasons, detail_academic_year)
  
  #filter out small N 
  munge <- min_term_filter(munge, small_n_cutoff)
 
  #tag with quartiles
  munge <- munge %>%
    mutate(
      quartile=kipp_quartile(testpercentile)
    )
  
  #TRANSFORMATION 2 - BIN COUNTS FOR BECCA PLOT
  #calculate group level averages.  Our final data set should have
  #SUBJECT    GRADE_LEVEL_SEASON     QUARTILE      PCT
  
  term_totals <- munge %>%
    select(
      measurementscale, grade_level_season, quartile
    ) %>%
    #first group by term
    group_by(
      measurementscale, grade_level_season  
    ) %>%
    summarize(
      n_total=n()
    ) %>%
    as.data.frame()
  
  quartile_totals <- munge %>%
    #then group by quartile
    group_by(
      measurementscale, grade_level_season, quartile
    ) %>%
    #include at grade level flag
    summarize(
      n_quartile=n()
    ) %>%
    rowwise() %>%
    mutate(
      at_grade_level_dummy=ifelse(quartile %in% c(3, 4), 'Yes', 'No'),
      order=quartile_order(as.numeric(quartile))
    ) 
          
  
  prepped <- left_join(
    quartile_totals, term_totals[, c(2,3)]  
  ) %>%
  mutate(
    pct=n_quartile /  n_total * 100
  ) %>%
  as.data.frame()
  
  #TRANSFORMATION - TWO dfs FOR CHART
  #super helpful advice from: http://stackoverflow.com/a/13734448/561698

  npr_above <- prepped[prepped$at_grade_level_dummy == 'Yes', ]
  npr_below <- prepped[prepped$at_grade_level_dummy == 'No', ]

  #flip the sign
  npr_below$pct <- npr_below$pct * -1
  
  #midpoints for labels
  npr_above <- npr_above %>%
    mutate(
      midpoint=cumsum(pct) - 0.5 * pct      
    )

  npr_below <- npr_below %>%
    mutate(
      midpoint=cumsum(pct) - 0.5 * pct      
    )
  
  #MAKE THE PLOT
   p <- ggplot() +
    #top half of NPR plots
    geom_bar(
      data = npr_above
     ,aes(
        x = grade_level_season
       ,y = pct
       ,fill = factor(quartile)
       ,order = order
      )
     ,stat = "identity"
    ) +
    #bottom half of NPR plots
    geom_bar(
      data = npr_below
     ,aes(
        x = grade_level_season
       ,y = pct
       ,fill = factor(quartile)
       ,order = order
      )
     ,stat = "identity"
    ) +
    #labels above
    geom_text(
      data = npr_above
     ,aes(
        x = grade_level_season
       ,y = midpoint
       ,label = round(pct,0)
      )
     ,size = 4
    ) +
    #labels below
    geom_text(
      data = npr_below
     ,aes(
        x = grade_level_season
       ,y = midpoint
       ,label = abs(round(pct, 0))
      )
     ,size = 4
    ) +
    #axis labels
    labs(
      x = 'Grade Level'
     ,y = 'Percentage of Cohort'
    ) +
    #clean out some default ggplot formatting elements
    theme(
      #zero out cetain formatting
      panel.background = element_blank()
     ,plot.background = element_blank()
     ,panel.grid.major = element_blank()
     ,panel.grid.minor = element_blank()
     ,axis.ticks.y = element_blank()
      
      #title and axis sizes
     ,title = element_text(size = rel(0.9))
     ,axis.title.x = element_text(size = rel(0.9))
     ,axis.text.y = element_blank()
     
     ,plot.margin = rep(unit(0,"null"),4)
    ) 
  
#     
#     scale_x_continuous(
#       breaks = becca_x_breaks
#      ,labels = becca_x_labels
#     ) +
#     coord_cartesian(
#       xlim=c(min(becca_x_breaks),max(becca_x_breaks))  
#     )

  legend_labels = c('1st', '2nd', '3rd', '4th')
  
  #color style?
  if(color_scheme == 'KIPP Report Card') {
    p <- p +
      #dark gray, light gray, light orange, dark orange
      scale_fill_manual(
        values = c(
          rgb(207, 204, 193, max = 255)
         ,rgb(230, 230, 230, max = 255)
         ,rgb(254, 188, 17, max = 255)
         ,rgb(247, 148, 30, max = 255)
        )
       ,name = 'Quartiles' 
       ,labels = legend_labels
      )
  } else if (color_scheme == 'Sequential Blues') {
    p <- p + scale_fill_brewer(
      type = "seq"
     ,palette = 1
    ) 
  } else {
    p <- p + scale_fill_manual(
      values = color_scheme
     ,labels = legend_labels
    )
  }
  
  p
  
}
