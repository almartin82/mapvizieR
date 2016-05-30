#' ny linking
#'
#' @param measurementscale MAP subject
#' @param current_grade grade level
#' @param season c('fall', 'winter', 'spring')
#' @param RIT rit score
#' @param returns one of c('perf_level', 'proficient')
#'
#' @return either character, length 1 with performance level or logical, 
#' length 1, with proficiency
#' @export

ny_linking <- function(measurementscale, current_grade, season, RIT, returns = 'perf_level') {
 
  ny_read_spr_g3_l1 <- data.frame(
    ny_subj = 'Reading',
    ny_grade = 3,
    ny_season = 'Spring',
    ny_rit = c(100:195),
    perf_level = 'Level 1',
    proficient = FALSE,
    stringsAsFactors = FALSE
  )
  ny_read_spr_g3_l2 <- data.frame(
    ny_subj = 'Reading',
    ny_grade = 3,
    ny_season = 'Spring',
    ny_rit = c(196:207),
    perf_level = 'Level 2',
    proficient = FALSE,
    stringsAsFactors = FALSE
  )
  ny_read_spr_g3_l3 <- data.frame(
    ny_subj = 'Reading',
    ny_grade = 3,
    ny_season = 'Spring',
    ny_rit = c(208:221),
    perf_level = 'Level 3',
    proficient = TRUE,
    stringsAsFactors = FALSE
  )
  ny_read_spr_g3_l4 <- data.frame(
    ny_subj = 'Reading',
    ny_grade = 3,
    ny_season = 'Spring',
    ny_rit = c(222:350),
    perf_level = 'Level 4',
    proficient = TRUE,
    stringsAsFactors = FALSE
  )
  
  ny_all <- dplyr::bind_rows(
    ny_read_spr_g3_l1, ny_read_spr_g3_l2, ny_read_spr_g3_l3, ny_read_spr_g3_l4
  )
  
  out <- ny_all %>%
    dplyr::filter(
      ny_subj == measurementscale,
      ny_grade == current_grade,
      ny_season == season,
      ny_rit == RIT
    )
  
  out <- out[, returns] %>% unlist %>% unname()
  # 4   100-�‐202  1-�‐40  203-�‐215  41-�‐73  216-�‐223  74-�‐88  224-�‐350  89-�‐99 
  # 5   100-�‐209  1-�‐43  210-�‐221  44-�‐74  222-�‐230  75-�‐89  231-�‐350  90-�‐99 
  # 6   100-�‐210  1-�‐36  211-�‐224  37-�‐72  225-�‐231  73-�‐85  232-�‐350  86-�‐99 
  # 7   100-�‐215  1-�‐43  216-�‐227  44-�‐73  228-�‐238  74-�‐91  239-�‐350  92-�‐99 
  # 8   100-�‐218  1-�‐46  219-�‐230  47-�‐74  231-�‐240  75-�‐90  241-�‐350  91-�‐99 
 
  out 
}