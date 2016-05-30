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
    ny_rit = c(216:227),
    perf_level = 'Level 2',
    proficient = FALSE,
    stringsAsFactors = FALSE
  )
  ny_read_spr_g7_l3 <- data.frame(
    ny_subj = 'Reading',
    ny_grade = 7,
    ny_season = 'Spring',
    ny_rit = c(228:238),
    perf_level = 'Level 3',
    proficient = TRUE,
    stringsAsFactors = FALSE
  )
  ny_read_spr_g7_l4 <- data.frame(
    ny_subj = 'Reading',
    ny_grade = 7,
    ny_season = 'Spring',
    ny_rit = c(239:350),
    perf_level = 'Level 4',
    proficient = TRUE,
    stringsAsFactors = FALSE
  )
  
  ny_read_spr_g8_l1 <- data.frame(
    ny_subj = 'Reading',
    ny_grade = 8,
    ny_season = 'Spring',
    ny_rit = c(100:218),
    perf_level = 'Level 1',
    proficient = FALSE,
    stringsAsFactors = FALSE
  )
  ny_read_spr_g8_l2 <- data.frame(
    ny_subj = 'Reading',
    ny_grade = 8,
    ny_season = 'Spring',
    ny_rit = c(219:230),
    perf_level = 'Level 2',
    proficient = FALSE,
    stringsAsFactors = FALSE
  )
  ny_read_spr_g8_l3 <- data.frame(
    ny_subj = 'Reading',
    ny_grade = 8,
    ny_season = 'Spring',
    ny_rit = c(231:240),
    perf_level = 'Level 3',
    proficient = TRUE,
    stringsAsFactors = FALSE
  )
  ny_read_spr_g8_l4 <- data.frame(
    ny_subj = 'Reading',
    ny_grade = 8,
    ny_season = 'Spring',
    ny_rit = c(241:350),
    perf_level = 'Level 4',
    proficient = TRUE,
    stringsAsFactors = FALSE
  )

  ny_math_spr_g3_l1 <- data.frame(
    ny_subj = 'Mathematics',
    ny_grade = 3,
    ny_season = 'Spring',
    ny_rit = c(100:195),
    perf_level = 'Level 1',
    proficient = FALSE,
    stringsAsFactors = FALSE
  )  
  ny_math_spr_g3_l2 <- data.frame(
    ny_subj = 'Mathematics',
    ny_grade = 3,
    ny_season = 'Spring',
    ny_rit = c(196:205),
    perf_level = 'Level 2',
    proficient = FALSE,
    stringsAsFactors = FALSE
  )
  ny_math_spr_g3_l3 <- data.frame(
    ny_subj = 'Mathematics',
    ny_grade = 3,
    ny_season = 'Spring',
    ny_rit = c(206:214),
    perf_level = 'Level 3',
    proficient = TRUE,
    stringsAsFactors = FALSE
  )
  ny_math_spr_g3_l4 <- data.frame(
    ny_subj = 'Mathematics',
    ny_grade = 3,
    ny_season = 'Spring',
    ny_rit = c(215:350),
    perf_level = 'Level 4',
    proficient = TRUE,
    stringsAsFactors = FALSE
  )
  
  ny_math_spr_g4_l1 <- data.frame(
    ny_subj = 'Mathematics',
    ny_grade = 4,
    ny_season = 'Spring',
    ny_rit = c(100:205),
    perf_level = 'Level 1',
    proficient = FALSE,
    stringsAsFactors = FALSE
  )
  ny_math_spr_g4_l2 <- data.frame(
    ny_subj = 'Mathematics',
    ny_grade = 4,
    ny_season = 'Spring',
    ny_rit = c(206:219),
    perf_level = 'Level 2',
    proficient = FALSE,
    stringsAsFactors = FALSE
  )
  ny_math_spr_g4_l3 <- data.frame(
    ny_subj = 'Mathematics',
    ny_grade = 4,
    ny_season = 'Spring',
    ny_rit = c(220:233),
    perf_level = 'Level 3',
    proficient = TRUE,
    stringsAsFactors = FALSE
  )
  ny_math_spr_g4_l4 <- data.frame(
    ny_subj = 'Mathematics',
    ny_grade = 4,
    ny_season = 'Spring',
    ny_rit = c(234:350),
    perf_level = 'Level 4',
    proficient = TRUE,
    stringsAsFactors = FALSE
  )
  
  ny_math_spr_g5_l1 <- data.frame(
    ny_subj = 'Mathematics',
    ny_grade = 5,
    ny_season = 'Spring',
    ny_rit = c(100:218),
    perf_level = 'Level 1',
    proficient = FALSE,
    stringsAsFactors = FALSE
  )
  ny_math_spr_g5_l2 <- data.frame(
    ny_subj = 'Mathematics',
    ny_grade = 5,
    ny_season = 'Spring',
    ny_rit = c(219:231),
    perf_level = 'Level 2',
    proficient = FALSE,
    stringsAsFactors = FALSE
  )
  ny_math_spr_g5_l3 <- data.frame(
    ny_subj = 'Mathematics',
    ny_grade = 5,
    ny_season = 'Spring',
    ny_rit = c(232:246),
    perf_level = 'Level 3',
    proficient = TRUE,
    stringsAsFactors = FALSE
  )
  ny_math_spr_g5_l4 <- data.frame(
    ny_subj = 'Mathematics',
    ny_grade = 5,
    ny_season = 'Spring',
    ny_rit = c(247:350),
    perf_level = 'Level 4',
    proficient = TRUE,
    stringsAsFactors = FALSE
  )
  
  ny_math_spr_g6_l1 <- data.frame(
    ny_subj = 'Mathematics',
    ny_grade = 6,
    ny_season = 'Spring',
    ny_rit = c(100:216),
    perf_level = 'Level 1',
    proficient = FALSE,
    stringsAsFactors = FALSE
  )
  ny_math_spr_g6_l2 <- data.frame(
    ny_subj = 'Mathematics',
    ny_grade = 6,
    ny_season = 'Spring',
    ny_rit = c(217:231),
    perf_level = 'Level 2',
    proficient = FALSE,
    stringsAsFactors = FALSE
  )
  ny_math_spr_g6_l3 <- data.frame(
    ny_subj = 'Mathematics',
    ny_grade = 6,
    ny_season = 'Spring',
    ny_rit = c(232:241),
    perf_level = 'Level 3',
    proficient = TRUE,
    stringsAsFactors = FALSE
  )
  ny_math_spr_g6_l4 <- data.frame(
    ny_subj = 'Mathematics',
    ny_grade = 6,
    ny_season = 'Spring',
    ny_rit = c(242:350),
    perf_level = 'Level 4',
    proficient = TRUE,
    stringsAsFactors = FALSE
  )

  ny_math_spr_g7_l1 <- data.frame(
    ny_subj = 'Mathematics',
    ny_grade = 7,
    ny_season = 'Spring',
    ny_rit = c(100:226),
    perf_level = 'Level 1',
    proficient = FALSE,
    stringsAsFactors = FALSE
  )
  ny_math_spr_g7_l2 <- data.frame(
    ny_subj = 'Mathematics',
    ny_grade = 7,
    ny_season = 'Spring',
    ny_rit = c(227:240),
    perf_level = 'Level 2',
    proficient = FALSE,
    stringsAsFactors = FALSE
  )
  ny_math_spr_g7_l3 <- data.frame(
    ny_subj = 'Mathematics',
    ny_grade = 7,
    ny_season = 'Spring',
    ny_rit = c(241:254),
    perf_level = 'Level 3',
    proficient = TRUE,
    stringsAsFactors = FALSE
  )
  ny_math_spr_g7_l4 <- data.frame(
    ny_subj = 'Mathematics',
    ny_grade = 7,
    ny_season = 'Spring',
    ny_rit = c(255:350),
    perf_level = 'Level 4',
    proficient = TRUE,
    stringsAsFactors = FALSE
  )
  
  ny_math_spr_g8_l1 <- data.frame(
    ny_subj = 'Mathematics',
    ny_grade = 8,
    ny_season = 'Spring',
    ny_rit = c(100:226),
    perf_level = 'Level 1',
    proficient = FALSE,
    stringsAsFactors = FALSE
  )
  ny_math_spr_g8_l2 <- data.frame(
    ny_subj = 'Mathematics',
    ny_grade = 8,
    ny_season = 'Spring',
    ny_rit = c(227:245),
    perf_level = 'Level 2',
    proficient = FALSE,
    stringsAsFactors = FALSE
  )
  ny_math_spr_g8_l3 <- data.frame(
    ny_subj = 'Mathematics',
    ny_grade = 8,
    ny_season = 'Spring',
    ny_rit = c(246:259),
    perf_level = 'Level 3',
    proficient = TRUE,
    stringsAsFactors = FALSE
  )
  ny_math_spr_g8_l4 <- data.frame(
    ny_subj = 'Mathematics',
    ny_grade = 8,
    ny_season = 'Spring',
    ny_rit = c(260:350),
    perf_level = 'Level 4',
    proficient = TRUE,
    stringsAsFactors = FALSE
  )

  ny_all <- dplyr::bind_rows(
    ny_read_spr_g3_l1, ny_read_spr_g3_l2, ny_read_spr_g3_l3, ny_read_spr_g3_l4,
    ny_read_spr_g4_l1, ny_read_spr_g4_l2, ny_read_spr_g4_l3, ny_read_spr_g4_l4,
    ny_read_spr_g5_l1, ny_read_spr_g5_l2, ny_read_spr_g5_l3, ny_read_spr_g5_l4,
    ny_read_spr_g6_l1, ny_read_spr_g6_l2, ny_read_spr_g6_l3, ny_read_spr_g6_l4,
    ny_read_spr_g7_l1, ny_read_spr_g7_l2, ny_read_spr_g7_l3, ny_read_spr_g7_l4,
    ny_read_spr_g8_l1, ny_read_spr_g8_l2, ny_read_spr_g8_l3, ny_read_spr_g8_l4,
    ny_math_spr_g3_l1, ny_math_spr_g3_l2, ny_math_spr_g3_l3, ny_math_spr_g3_l4,
    ny_math_spr_g4_l1, ny_math_spr_g4_l2, ny_math_spr_g4_l3, ny_math_spr_g4_l4,
    ny_math_spr_g5_l1, ny_math_spr_g5_l2, ny_math_spr_g5_l3, ny_math_spr_g5_l4,
    ny_math_spr_g6_l1, ny_math_spr_g6_l2, ny_math_spr_g6_l3, ny_math_spr_g6_l4,
    ny_math_spr_g7_l1, ny_math_spr_g7_l2, ny_math_spr_g7_l3, ny_math_spr_g7_l4,
    ny_math_spr_g8_l1, ny_math_spr_g8_l2, ny_math_spr_g8_l3, ny_math_spr_g8_l4
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