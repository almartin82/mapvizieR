#' @title Students' names stacked by category, or a more informative bar graph.
#'
#' @description \code{amys_lists} implements bar charts that created by ranking and
#' stacking student names for each growth status bin (i.e., negative growth,
#' not typical, typical, and college ready growth).  The name is from KIPP Chicago
#' CAO Amy Pouba, who came up with the idea.  This visualizaiton is nice in that it provides
#' a quick overview of the distribution of growth statuses while simultaneously providing
#' student-level information (student name, end RIT score, and gorwth status).
#'
#'
#' @param mapvizieR_obj mapvizieR object
#' @param studentids target students
#' @param measurementscale target subject
#' @param grade_level target ending grade level
#' @param start_fws starting season
#' @param start_academic_year starting academic year
#' @param end_fws ending season
#' @param end_academic_year ending academic year
#'
#' @export

amys_lists <- function(
  mapvizieR_obj,
  studentids,
  measurementscale,
  start_fws,
  start_academic_year,
  end_fws,
  end_academic_year
) {

  #data validation and unpack
  mv_opening_checks(mapvizieR_obj, studentids, 1)

  #unpack the mapvizieR object and limit to desired students
  growth_df <- mv_limit_growth(mapvizieR_obj, studentids, measurementscale) %>%
    dplyr::inner_join(
      mapvizieR_obj$roster %>%
        dplyr::filter(fallwinterspring == end_fws, map_year_academic == end_academic_year),
        by = "studentid"
      ) %>%
    dplyr::mutate(
      studentfirstlastrit = sprintf("%s (%s)", studentfirstlast, end_testritscore)
    )

  #data processing
  #just desired terms
  this_growth <- growth_df %>%
    dplyr::filter(
      start_map_year_academic == start_academic_year,
      start_fallwinterspring == start_fws,
      end_map_year_academic == end_academic_year,
      end_fallwinterspring == end_fws
    )

  #need to be at least one row with valid data
  ensure_rows_in_df(this_growth[!is.na(this_growth$sgp), ])

  this_growth2 <- this_growth %>%
    dplyr::mutate(growth_status = ifelse(growth_status == "Positive", "Not Typical", growth_status)) %>%
    dplyr::group_by(end_grade, measurementscale, growth_status) %>%
    dplyr::mutate(growth_status_rank = dplyr::row_number(end_testritscore))


  statuses <- c("College Ready", "Typical", "Not Typical", "Negative")

  this_growth2_summary <- this_growth2 %>%
    dplyr::group_by(end_grade, measurementscale, growth_status) %>%
    dplyr::summarise(n = n()) %>%
    dplyr::mutate(
      tot = sum(n),
      percent = n/tot,
      text = paste0("% ", growth_status, " = ", round(percent * 100), "% (", n,"/", tot, ")")
    ) %>%
    dplyr::inner_join(
      data.frame(
        growth_status = statuses,
        loc = c(40, 37.5, 35, 32.5),
        stringsAsFactors = FALSE
      ),
      by = "growth_status"
    ) %>%
    dplyr::mutate(
      growth_status2 = factor(growth_status, levels = rev(statuses))
    )

  # makes growth status a factor
  this_growth2 <- this_growth2 %>%
    dplyr::mutate(growth_status2 = factor(growth_status, levels = rev(statuses)))


  p <- ggplot(
    data = this_growth2, 
    aes(x = growth_status2, y = growth_status_rank)
  ) +
  #student names
  geom_text(
    aes(label = studentfirstlastrit, color = growth_status2),
    size = 1.75
  ) +
  #summary labels
  geom_text(
    data = this_growth2_summary,
    aes(x = "Negative", y = loc, label = text, color = growth_status2),
    size = 3,
    hjust = 0
  ) +
  scale_color_manual(values = c("red", "#C49A6C", "#8D8685", "#FEBC11")) +
  facet_grid(end_grade ~ measurementscale) +
  theme_bw() +
  theme(legend.position = "bottom") +
  xlab("Growth Type") +
  ylab("Count of Students")

  # return
  p
}
