library(dplyr)
library(tidyr)
library(stringr)

# ============================================================================
# Parse 2025 School Growth Norms
# ============================================================================

txt_2025 <- readLines('data-raw/2025_Technical_Manual.txt')

# 2025 growth norms are simpler: Mean and SD by grade for each growth window
# Tables: C.2 (Math), C.4 (Reading), C.6 (Language Usage), C.8 (Science)

parse_2025_growth_table <- function(lines, start_line, subject, grades) {
  # Growth windows in order
  windows <- c("Fall to Winter", "Winter to Spring", "Fall to Spring",
               "Fall to Fall", "Winter to Winter", "Spring to Spring")

  # Data starts 4 lines after table header
  data_start <- start_line + 4
  n_grades <- length(grades)
  data_lines <- lines[data_start:(data_start + n_grades - 1)]

  all_rows <- list()

  for (i in seq_along(data_lines)) {
    line <- data_lines[i]
    # Extract all numbers (including negatives and decimals)
    nums <- as.numeric(str_extract_all(line, "-?\\d+\\.?\\d*")[[1]])

    if (length(nums) < 2) next

    grade <- grades[i]

    # Structure: Grade, then pairs of (Mean, SD) for each window
    # Some windows may have "-" for missing data
    # We expect up to 12 numbers after grade (6 windows x 2 values)

    # Parse the line more carefully - split by whitespace
    parts <- str_split(str_trim(line), "\\s+")[[1]]

    # First part is grade (K or number), skip it
    values <- parts[-1]

    # Convert to numeric, "-" becomes NA
    values <- suppressWarnings(as.numeric(values))

    # Should have pairs: Mean1, SD1, Mean2, SD2, ... for 6 windows = 12 values
    if (length(values) >= 2) {
      for (w in 1:6) {
        idx <- (w - 1) * 2 + 1
        if (idx + 1 <= length(values)) {
          mean_val <- values[idx]
          sd_val <- values[idx + 1]

          if (!is.na(mean_val) && !is.na(sd_val)) {
            all_rows[[length(all_rows) + 1]] <- data.frame(
              end_grade = grade,
              measurementscale = subject,
              growth_window = windows[w],
              typical_cohort_growth = mean_val,
              sd_of_expectation = sd_val,
              stringsAsFactors = FALSE
            )
          }
        }
      }
    }
  }

  if (length(all_rows) == 0) return(NULL)
  bind_rows(all_rows)
}

# Find table line numbers
find_table_line <- function(lines, pattern) {
  idx <- grep(pattern, lines, fixed = TRUE)[1]
  if (is.na(idx)) {
    cat("Pattern not found:", pattern, "\n")
    return(NA)
  }
  idx
}

# Parse 2025 school growth norms
cat("=== Parsing 2025 School Growth Norms ===\n")

tables_2025 <- list(
  list(pattern = "Table C.2.: Growth Norms - Mathematics, School", subject = "Mathematics", grades = 0:12),
  list(pattern = "Table C.4.: Growth Norms - Reading, School", subject = "Reading", grades = 0:12),
  list(pattern = "Table C.6.: Growth Norms - Language Usage, School", subject = "Language Usage", grades = 2:11),
  list(pattern = "Table C.8.: Growth Norms - Science, School", subject = "General Science", grades = 3:11)
)

all_2025_school <- list()

for (t in tables_2025) {
  line_num <- find_table_line(txt_2025, t$pattern)
  if (!is.na(line_num)) {
    cat("Parsing:", t$subject, "(line", line_num, ")\n")
    df <- parse_2025_growth_table(txt_2025, line_num, t$subject, t$grades)
    if (!is.null(df)) {
      all_2025_school[[t$subject]] <- df
      cat("  Found", nrow(df), "rows\n")
    }
  }
}

sch_growth_norms_2025 <- bind_rows(all_2025_school)

# Add start/end season columns based on growth_window
sch_growth_norms_2025 <- sch_growth_norms_2025 %>%
  mutate(
    start_fallwinterspring = case_when(
      growth_window %in% c("Fall to Winter", "Fall to Spring", "Fall to Fall") ~ "Fall",
      growth_window %in% c("Winter to Spring", "Winter to Winter") ~ "Winter",
      growth_window == "Spring to Spring" ~ "Spring"
    ),
    end_fallwinterspring = case_when(
      growth_window == "Fall to Winter" ~ "Winter",
      growth_window %in% c("Winter to Spring", "Fall to Spring") ~ "Spring",
      growth_window %in% c("Fall to Fall", "Winter to Winter", "Spring to Spring") ~
        sub(".* to ", "", growth_window)
    )
  ) %>%
  select(end_grade, measurementscale, growth_window, start_fallwinterspring,
         end_fallwinterspring, typical_cohort_growth, sd_of_expectation)

cat("\n2025 School Growth Norms dimensions:", dim(sch_growth_norms_2025), "\n")
print(head(sch_growth_norms_2025, 20))

cat("\nSubjects and windows:\n")
print(table(sch_growth_norms_2025$measurementscale, sch_growth_norms_2025$growth_window))

# Save
write.csv(sch_growth_norms_2025, 'data-raw/sch_growth_norms_2025_parsed.csv', row.names = FALSE)
cat("\nSaved to data-raw/sch_growth_norms_2025_parsed.csv\n")


# ============================================================================
# Parse 2020 School Growth Norms (Conditional Growth Percentiles)
# ============================================================================

cat("\n\n=== Parsing 2020 School Growth Norms ===\n")

txt_2020 <- readLines('data-raw/NormsTables2020_full.txt')

# 2020 has conditional growth percentile tables (Appendix E)
# Structure: For each percentile row, there's a Student row and School row
# We want the School rows

# The tables have:
# - Status %ile, Start RIT, Mean Growth, SD
# - Then CGP columns: 20, 30, 40, 45, 50, 55, 60, 70, 80

parse_2020_school_growth_table <- function(lines, start_line, subject, grade, growth_window) {
  # Data starts after header rows
  data_start <- start_line + 4
  data_lines <- lines[data_start:(data_start + 50)]  # Get enough lines

  all_rows <- list()

  for (line in data_lines) {
    # Check if this is a School row (has "School" in it)
    if (!grepl("School", line)) next

    # Extract numbers from the line
    nums <- as.numeric(str_extract_all(line, "-?\\d+\\.?\\d*")[[1]])

    # School rows have: Start RIT, Mean, SD (at minimum)
    if (length(nums) >= 3) {
      start_rit <- nums[1]
      mean_growth <- nums[2]
      sd_growth <- nums[3]

      # Only include valid data
      if (!is.na(start_rit) && !is.na(mean_growth) && !is.na(sd_growth) &&
          start_rit > 100 && start_rit < 300) {
        all_rows[[length(all_rows) + 1]] <- data.frame(
          end_grade = grade,
          measurementscale = subject,
          growth_window = growth_window,
          rit = round(start_rit),
          typical_cohort_growth = mean_growth,
          sd_of_expectation = sd_growth,
          stringsAsFactors = FALSE
        )
      }
    }
  }

  if (length(all_rows) == 0) return(NULL)
  bind_rows(all_rows)
}

# Find all E.x.x table lines for school growth
# E.1 = Math, E.2 = Reading, E.3 = Language Usage, E.4 = Science

# Get table info from the document
table_lines <- grep("Table E\\.[0-9]+\\.[0-9]+:", txt_2020, value = FALSE)
table_texts <- txt_2020[table_lines]

# Parse table info
parse_table_info <- function(table_text, line_num) {
  # Extract subject, grade, and growth window from table title
  # Example: "Table E.1.1: Mathematics Grade K"
  #          "Fall To Winter Conditional Growth Percentile"

  subject <- case_when(
    grepl("E\\.1\\.", table_text) ~ "Mathematics",
    grepl("E\\.2\\.", table_text) ~ "Reading",
    grepl("E\\.3\\.", table_text) ~ "Language Usage",
    grepl("E\\.4\\.", table_text) ~ "General Science",
    TRUE ~ NA_character_
  )

  # Extract grade
  grade_match <- str_extract(table_text, "Grade ([K0-9]+)")
  grade <- if (!is.na(grade_match)) {
    g <- str_extract(grade_match, "[K0-9]+$")
    if (g == "K") 0 else as.numeric(g)
  } else NA

  list(subject = subject, grade = grade, line = line_num)
}

# Build list of tables to parse
cat("Finding 2020 growth tables...\n")

all_2020_school <- list()
processed <- 0

for (i in seq_along(table_lines)) {
  line_num <- table_lines[i]
  table_text <- table_texts[i]

  info <- parse_table_info(table_text, line_num)

  if (is.na(info$subject) || is.na(info$grade)) next

  # Get growth window from next line
  if (line_num + 1 <= length(txt_2020)) {
    window_line <- txt_2020[line_num + 1]

    growth_window <- case_when(
      grepl("Fall To Winter", window_line, ignore.case = TRUE) ~ "Fall to Winter",
      grepl("Winter To Spring", window_line, ignore.case = TRUE) ~ "Winter to Spring",
      grepl("Fall To Spring", window_line, ignore.case = TRUE) ~ "Fall to Spring",
      grepl("Fall To.*Fall", window_line, ignore.case = TRUE) ~ "Fall to Fall",
      grepl("Winter To.*Winter", window_line, ignore.case = TRUE) ~ "Winter to Winter",
      grepl("Spring To.*Spring", window_line, ignore.case = TRUE) ~ "Spring to Spring",
      grepl("Last Winter.*Winter", window_line, ignore.case = TRUE) ~ "Winter to Winter",
      grepl("Last Spring.*Spring", window_line, ignore.case = TRUE) ~ "Spring to Spring",
      grepl("Last Spring.*Fall", window_line, ignore.case = TRUE) ~ "Spring to Fall",
      TRUE ~ NA_character_
    )

    if (!is.na(growth_window)) {
      df <- parse_2020_school_growth_table(txt_2020, line_num, info$subject, info$grade, growth_window)
      if (!is.null(df) && nrow(df) > 0) {
        all_2020_school[[length(all_2020_school) + 1]] <- df
        processed <- processed + 1
      }
    }
  }
}

cat("Processed", processed, "tables\n")

if (length(all_2020_school) > 0) {
  sch_growth_norms_2020 <- bind_rows(all_2020_school)

  # Add start/end season columns
  sch_growth_norms_2020 <- sch_growth_norms_2020 %>%
    mutate(
      start_fallwinterspring = case_when(
        growth_window %in% c("Fall to Winter", "Fall to Spring", "Fall to Fall") ~ "Fall",
        growth_window %in% c("Winter to Spring", "Winter to Winter") ~ "Winter",
        growth_window %in% c("Spring to Spring", "Spring to Fall") ~ "Spring"
      ),
      end_fallwinterspring = case_when(
        growth_window == "Fall to Winter" ~ "Winter",
        growth_window %in% c("Winter to Spring", "Fall to Spring") ~ "Spring",
        growth_window == "Fall to Fall" ~ "Fall",
        growth_window == "Winter to Winter" ~ "Winter",
        growth_window == "Spring to Spring" ~ "Spring",
        growth_window == "Spring to Fall" ~ "Fall"
      )
    ) %>%
    # Remove duplicates (same grade/subject/window/rit)
    distinct(end_grade, measurementscale, growth_window, rit, .keep_all = TRUE) %>%
    select(end_grade, measurementscale, growth_window, start_fallwinterspring,
           end_fallwinterspring, rit, typical_cohort_growth, sd_of_expectation)

  cat("\n2020 School Growth Norms dimensions:", dim(sch_growth_norms_2020), "\n")
  print(head(sch_growth_norms_2020, 20))

  cat("\nSubjects and windows:\n")
  print(table(sch_growth_norms_2020$measurementscale, sch_growth_norms_2020$growth_window))

  cat("\nGrades per subject:\n")
  print(sch_growth_norms_2020 %>% group_by(measurementscale) %>%
          summarize(min_grade = min(end_grade), max_grade = max(end_grade), n_rows = n()))

  # Save
  write.csv(sch_growth_norms_2020, 'data-raw/sch_growth_norms_2020_parsed.csv', row.names = FALSE)
  cat("\nSaved to data-raw/sch_growth_norms_2020_parsed.csv\n")
} else {
  cat("No 2020 school growth data parsed!\n")
}
