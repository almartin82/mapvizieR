#' @title KIPP Percent Making Typ Growth Network Distribution
#'
#' @description shows your school relative to KIPP schools nationwide (if you have that dataset :))
#'
#' @param nat_results_df KIPP results nationwide.  Ask R&E for the raw data file - same as the data 
#' in the HSR tableau reports.
#' @param measurementscale MAP subject
#' @param academic_year the academic year
#' @param grade_level comparison grade level
#' @param start_fws starting season
#' @param end_fws ending season
#' @param comparison_name this school name
#' @param comparison_pct_typ_growth pct keep up, this school
#' @param replace_nat_results_match if using last year's data, remove this school's name
#' @param de_kippify_names shorten names by removing KIPP prefix
#' @param de_schoolify_names shorten names by removing 'Academy', 'Primary', etc.
#' 
#' @return a ggplot chart
#' @export

kipp_typ_growth_distro <- function (
  nat_results_df,
  measurementscale,
  academic_year,
  grade_level,
  start_fws,
  end_fws,
  comparison_name,
  comparison_pct_typ_growth,
  replace_nat_results_match = FALSE,
  de_kippify_names = TRUE,
  de_schoolify_names = TRUE) {
  
  #subset the df
  nat <- nat_results_df %>% 
    dplyr::filter(
      Sub_Test_Name == measurementscale &
      Growth_Academic_Year == academic_year &
      Growth_Grade_Level == grade_level &
      Start_Season == toupper(start_fws) &
      End_Season == toupper(end_fws)
    )
  
  #strip KIPP from name?
  if (de_kippify_names == TRUE) {
    #corner case, TEAM
    nat$School_Display_Name <- gsub(', a KIPP school', '', nat$School_Display_Name)
    nat$School_Display_Name <- gsub('KIPP ', '', nat$School_Display_Name)
  }

  #strip school, academy, etc from name?
  if (de_schoolify_names == TRUE) {
    nat$School_Display_Name <- gsub(' Academy for Girls', '', nat$School_Display_Name)
    nat$School_Display_Name <- gsub(' Academy for Boys', '', nat$School_Display_Name)
    nat$School_Display_Name <- gsub(' Academy of', '', nat$School_Display_Name)
    nat$School_Display_Name <- gsub(' Academy', '', nat$School_Display_Name)
    nat$School_Display_Name <- gsub(' Middle School', '', nat$School_Display_Name)
    nat$School_Display_Name <- gsub(' Elementary', '', nat$School_Display_Name)
    nat$School_Display_Name <- gsub(' Primary', '', nat$School_Display_Name)
    nat$School_Display_Name <- gsub(' College Preparatory', '', nat$School_Display_Name)
    nat$School_Display_Name <- gsub(' College Prep', '', nat$School_Display_Name)
    nat$School_Display_Name <- gsub(' Charter School', '', nat$School_Display_Name)
    nat$School_Display_Name <- gsub(' School', '', nat$School_Display_Name)
    nat$School_Display_Name <- gsub(' Preparatory', ' Prep', nat$School_Display_Name)
  }
  
  #name collision
  if (replace_nat_results_match == TRUE) {
    nat <- nat[nat$School_Display_Name != comparison_name,]
  }
  
  #target beat how many schools?
  e <- new.env()
  e$kipp_rank <- sum(comparison_pct_typ_growth < as.numeric(nat$Perc_Growth)) + 1
  e$kipp_denom <- length(nat$Perc_Growth) + 1
  
  #text size
  e$hacky_text_size <- 6 + -.12 * e$kipp_denom
  
  if (e$hacky_text_size < 2) {
    e$hacky_text_size <- 2
  }
  
  #add a row for comparison school
  nat$highlight_me <- 0
  new_row <- c(comparison_name, NA, NA, comparison_pct_typ_growth, NA, grade_level
              ,measurementscale, start_fws, end_fws, academic_year, 1)
  nat_plus <- rbind(nat, new_row)

  head(nat)
  tail(nat_plus)
  #dummy x, sort order
  nat_plus$dummy_x <- rank(as.numeric(nat_plus$Perc_Growth), ties.method = 'random')
  
  nat_plus$Perc_Growth <- as.numeric(nat_plus$Perc_Growth) * 100
  
  
  
  p <- ggplot(
    data = nat_plus,
    aes(
      x = dummy_x,
      y = as.numeric(Perc_Growth),
      fill = factor(highlight_me),
      label = paste(School_Display_Name, ' (', round(Perc_Growth,0) , '%)',sep = '')
    ),
    environment = e
  ) + 
  geom_bar(
    stat = "identity"
  ) +  
  geom_text(
    y = 0.25,
    hjust = 0,
    vjust = 0.3,
    size = e$hacky_text_size,
    color = 'floralwhite'
  ) + 
  coord_flip() +  
  guides(
    fill = FALSE
  ) +
  labs(
    y = 'Percent Making Typical [Keep Up] Growth',
    title = 'KIPP Network Comparison'
  ) +
  theme(
    #zero out cetain formatting
    panel.background = element_blank(),
    plot.background = element_blank(),
    
    #grid
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    #title and axis sizes
    title = element_text(size = rel(0.7)),

    axis.title.y = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
     
    panel.margin = unit(0, "null"),
    plot.margin = rep(unit(0, "null"), 4),
    axis.ticks.margin = unit(0, "null")
  ) +
  scale_fill_manual(
    values = c('gray30', 'gold1')
  ) + 
  annotate(
    geom = 'text',
    x = 1.25,
    y = .7 * nat_plus[nat_plus$dummy_x == max(nat_plus$dummy_x), 'Perc_Growth'],
    label = paste0(toOrdinal::toOrdinal(e$kipp_rank), ' of ', e$kipp_denom),
    color = 'gray20',
    alpha = .8,
    size = 8,
    vjust = 1,
    angle = 0
  )
  
  return(p)
}