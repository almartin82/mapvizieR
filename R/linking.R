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

  ny_read_spr_g4_l1 <- data.frame(
    ny_subj = 'Reading',
    ny_grade = 4,
    ny_season = 'Spring',
    ny_rit = c(100:202),
    perf_level = 'Level 1',
    proficient = FALSE,
    stringsAsFactors = FALSE
  )
  ny_read_spr_g4_l2 <- data.frame(
    ny_subj = 'Reading',
    ny_grade = 4,
    ny_season = 'Spring',
    ny_rit = c(203:215),
    perf_level = 'Level 2',
    proficient = FALSE,
    stringsAsFactors = FALSE
  )
  ny_read_spr_g4_l3 <- data.frame(
    ny_subj = 'Reading',
    ny_grade = 4,
    ny_season = 'Spring',
    ny_rit = c(216:223),
    perf_level = 'Level 3',
    proficient = TRUE,
    stringsAsFactors = FALSE
  )
  ny_read_spr_g4_l4 <- data.frame(
    ny_subj = 'Reading',
    ny_grade = 4,
    ny_season = 'Spring',
    ny_rit = c(224:350),
    perf_level = 'Level 4',
    proficient = TRUE,
    stringsAsFactors = FALSE
  )

  ny_read_spr_g5_l1 <- data.frame(
    ny_subj = 'Reading',
    ny_grade = 5,
    ny_season = 'Spring',
    ny_rit = c(100:209),
    perf_level = 'Level 1',
    proficient = FALSE,
    stringsAsFactors = FALSE
  )
  ny_read_spr_g5_l2 <- data.frame(
    ny_subj = 'Reading',
    ny_grade = 5,
    ny_season = 'Spring',
    ny_rit = c(210:221),
    perf_level = 'Level 2',
    proficient = FALSE,
    stringsAsFactors = FALSE
  )
  ny_read_spr_g5_l3 <- data.frame(
    ny_subj = 'Reading',
    ny_grade = 5,
    ny_season = 'Spring',
    ny_rit = c(222:230),
    perf_level = 'Level 3',
    proficient = TRUE,
    stringsAsFactors = FALSE
  )
  ny_read_spr_g5_l4 <- data.frame(
    ny_subj = 'Reading',
    ny_grade = 5,
    ny_season = 'Spring',
    ny_rit = c(231:350),
    perf_level = 'Level 4',
    proficient = TRUE,
    stringsAsFactors = FALSE
  )
  
  ny_read_spr_g6_l1 <- data.frame(
    ny_subj = 'Reading',
    ny_grade = 6,
    ny_season = 'Spring',
    ny_rit = c(100:210),
    perf_level = 'Level 1',
    proficient = FALSE,
    stringsAsFactors = FALSE
  )
  ny_read_spr_g6_l2 <- data.frame(
    ny_subj = 'Reading',
    ny_grade = 6,
    ny_season = 'Spring',
    ny_rit = c(211:224),
    perf_level = 'Level 2',
    proficient = FALSE,
    stringsAsFactors = FALSE
  )
  ny_read_spr_g6_l3 <- data.frame(
    ny_subj = 'Reading',
    ny_grade = 6,
    ny_season = 'Spring',
    ny_rit = c(225:231),
    perf_level = 'Level 3',
    proficient = TRUE,
    stringsAsFactors = FALSE
  )
  ny_read_spr_g6_l4 <- data.frame(
    ny_subj = 'Reading',
    ny_grade = 6,
    ny_season = 'Spring',
    ny_rit = c(232:350),
    perf_level = 'Level 4',
    proficient = TRUE,
    stringsAsFactors = FALSE
  )
  
  ny_read_spr_g7_l1 <- data.frame(
    ny_subj = 'Reading',
    ny_grade = 7,
    ny_season = 'Spring',
    ny_rit = c(100:215),
    perf_level = 'Level 1',
    proficient = FALSE,
    stringsAsFactors = FALSE
  )
  ny_read_spr_g7_l2 <- data.frame(
    ny_subj = 'Reading',
    ny_grade = 7,
    ny_season = 'Spring',
    ny_rit = c(100:215),
    perf_level = 'Level 2',
    proficient = FALSE,
    stringsAsFactors = FALSE
  )
  ny_read_spr_g7_l3 <- data.frame(
    ny_subj = 'Reading',
    ny_grade = 7,
    ny_season = 'Spring',
    ny_rit = c(100:215),
    perf_level = 'Level 3',
    proficient = TRUE,
    stringsAsFactors = FALSE
  )
  ny_read_spr_g7_l4 <- data.frame(
    ny_subj = 'Reading',
    ny_grade = 7,
    ny_season = 'Spring',
    ny_rit = c(100:215),
    perf_level = 'Level 4',
    proficient = TRUE,
    stringsAsFactors = FALSE
  )
  
  # 7   100-�‐215  1-�‐43  216-�‐227  44-�‐73  228-�‐238  74-�‐91  239-�‐350  92-�‐99 
  # 8   100-�‐218  1-�‐46  219-�‐230  47-�‐74  231-�‐240  75-�‐90  241-�‐350  91-�‐99 
  
  ny_all <- dplyr::bind_rows(
    ny_read_spr_g3_l1, ny_read_spr_g3_l2, ny_read_spr_g3_l3, ny_read_spr_g3_l4,
    ny_read_spr_g4_l1, ny_read_spr_g4_l2, ny_read_spr_g4_l3, ny_read_spr_g4_l4,
    ny_read_spr_g5_l1, ny_read_spr_g5_l2, ny_read_spr_g5_l3, ny_read_spr_g5_l4,
    ny_read_spr_g6_l1, ny_read_spr_g6_l2, ny_read_spr_g6_l3, ny_read_spr_g6_l4,
  )
  
  out <- ny_all %>%
    dplyr::filter(
      ny_subj == measurementscale,
      ny_grade == current_grade,
      ny_season == season,
      ny_rit == RIT
    )
  
  out <- out[, returns] %>% unlist %>% unname()
 
  out 
}