#' @title RIT distribution change (affectionately titled 'Galloping Elephants')
#'
#' @description
#' \code{galloping_elephants} returns ggplot density distributions that show change
#'  in RIT over time
#'
#' @param mapvizieR_obj a conforming mapvizieR object, which contains a cdf and a roster.
#' @param studentids which students to display?
#' @param first_and_spring_only show all terms, or only entry & spring?  default is TRUE.
#' @param detail_academic_year don't mask any data for this academic year
#' @param entry_grade_seasons which grade_level_seasons are entry grades?
#' 
#' @return a ggplot object.
#' 
#' @export


galloping_elephants <- function (
  mapvizieR_obj,
  studentids,
  first_and_spring_only=TRUE,
  detail_academic_year=2014,
  entry_grade_seasons=c(-0.8, 4.2)
) {
  #use ensureR to check if this is a mapvizieR object
  mapvizieR_obj %>% ensure_is_mapvizieR()
    
  #unpack the mapvizieR object
  cdf_long <- mapvizieR_obj[['cdf']]
  
  #test if the cdf conforms to specs
  assert_that(check_cdf_long(cdf_long)$boolean)
  
  #munge data 
  ##only these kids
  this_cdf <- cdf_long[cdf_long$studentid %in% studentids, ]
  
  #only these seasons
  valid_grades <- c(entry_grade_seasons, seq(0:13))
  stage_1 <- this_cdf[this_cdf$grade %in% valid_grades | 
                this_cdf$map_year_academic==detail_academic_year, ]

  #get counts by term (for labels)
  term_counts <- stage_1 %>%
    group_by(grade_season_label) %>%
    summarize(
      count=n()  
    )
  
  
  #make and return the plot
  p <- ggplot(
    data=stage_1
   ,aes(
      x = testritscore
     ,group = grade_season_label
     ,fill = grade_season_label
     ,alpha = grade_level_season
    )
  ) + 
  geom_density(
    adjust = 1
  ) +
  theme_bw()
  
  return(p)
}
