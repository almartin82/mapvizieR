library(dplyr)
library(tidyr)
library(stringr)

# Read the full text file
txt <- readLines('data-raw/NormsTables2020_full.txt')

# Function to parse a student status percentile table (integers)
# grade_range specifies which grades have data (e.g., 0:12 for K-12, 2:11 for Language Usage)
parse_status_table <- function(lines, start_pattern, subject, season, grade_range = 0:12) {
  # Find start of table
  start_idx <- grep(start_pattern, lines, fixed = TRUE)[1]
  if (is.na(start_idx)) {
    cat("  Pattern not found:", start_pattern, "\n")
    return(NULL)
  }

  n_grades <- length(grade_range)
  min_nums <- n_grades + 1  # percentile + grades

  # Extract data lines (skip header rows, get 99 data rows)
  data_start <- start_idx + 4  # Skip table title and header
  data_lines <- lines[data_start:(data_start + 98)]

  # Parse each line
  parsed <- lapply(data_lines, function(line) {
    nums <- as.numeric(str_extract_all(line, "\\d+")[[1]])
    if (length(nums) >= min_nums) {
      return(nums[1:min_nums])  # Pct + grades
    }
    return(NULL)
  })

  parsed <- parsed[!sapply(parsed, is.null)]
  df <- do.call(rbind, parsed)
  if (is.null(df) || nrow(df) == 0) return(NULL)

  # Create column names based on grade range
  grade_names <- ifelse(grade_range == 0, "K", paste0("G", grade_range))
  colnames(df) <- c("percentile", grade_names)
  df <- as.data.frame(df)

  # Reshape to long format
  df_long <- df %>%
    pivot_longer(cols = -percentile, names_to = "grade_raw", values_to = "RIT") %>%
    mutate(
      grade = case_when(
        grade_raw == "K" ~ 0,
        TRUE ~ as.numeric(gsub("G", "", grade_raw))
      ),
      measurementscale = subject,
      fallwinterspring = season,
      student_percentile = percentile
    ) %>%
    select(measurementscale, fallwinterspring, grade, RIT, student_percentile)

  return(df_long)
}

# Function to parse a school status percentile table (decimals, split across pages)
# grade_range specifies which grades have data (e.g., 0:12 for K-12, 2:11 for Language Usage)
parse_school_status_table <- function(lines, start_pattern, subject, season, grade_range = 0:12) {
  # Find start of table
  start_idx <- grep(start_pattern, lines, fixed = TRUE)[1]
  if (is.na(start_idx)) {
    cat("  Pattern not found:", start_pattern, "\n")
    return(NULL)
  }

  n_grades <- length(grade_range)
  min_nums <- n_grades + 1  # percentile + grades

  # School tables have decimal RIT values and are split across pages
  # First part: percentiles 1-49
  # Then page break with "continued" header
  # Second part: percentiles 50-90

  # Extract a large block and parse all valid lines
  data_start <- start_idx + 4
  data_lines <- lines[data_start:(data_start + 120)]  # Get enough lines to cover both pages

  # Parse each line - extract decimal numbers
  parsed <- lapply(data_lines, function(line) {
    # Match decimals and integers: e.g., 126.9 or 50
    nums <- as.numeric(str_extract_all(line, "\\d+\\.?\\d*")[[1]])
    # Need at least min_nums and first should be a percentile (1-99)
    if (length(nums) >= min_nums && nums[1] >= 1 && nums[1] <= 99) {
      return(nums[1:min_nums])
    }
    return(NULL)
  })

  parsed <- parsed[!sapply(parsed, is.null)]
  if (length(parsed) == 0) return(NULL)

  df <- do.call(rbind, parsed)

  # Create column names based on grade range
  grade_names <- ifelse(grade_range == 0, "K", paste0("G", grade_range))
  colnames(df) <- c("percentile", grade_names)
  df <- as.data.frame(df)

  # Remove duplicate percentiles (in case of parsing artifacts)
  df <- df[!duplicated(df$percentile), ]

  # Reshape to long format
  df_long <- df %>%
    pivot_longer(cols = -percentile, names_to = "grade_raw", values_to = "RIT") %>%
    mutate(
      grade = case_when(
        grade_raw == "K" ~ 0,
        TRUE ~ as.numeric(gsub("G", "", grade_raw))
      ),
      measurementscale = subject,
      fallwinterspring = season,
      school_percentile = percentile
    ) %>%
    select(measurementscale, fallwinterspring, grade, RIT, school_percentile)

  return(df_long)
}

# Parse all student status tables
cat("=== Parsing Student Status Tables ===\n")
all_student_status <- list()

# Patterns for student tables (C.1.x) with grade ranges
student_patterns <- list(
  list(pattern = "Table C.1.1: Fall Mathematics", subject = "Mathematics", season = "Fall", grades = 0:12),
  list(pattern = "Table C.1.2: Winter Mathematics", subject = "Mathematics", season = "Winter", grades = 0:12),
  list(pattern = "Table C.1.3: Spring Mathematics", subject = "Mathematics", season = "Spring", grades = 0:12),
  list(pattern = "Table C.1.4: Fall Reading", subject = "Reading", season = "Fall", grades = 0:12),
  list(pattern = "Table C.1.5: Winter Reading", subject = "Reading", season = "Winter", grades = 0:12),
  list(pattern = "Table C.1.6: Spring Reading", subject = "Reading", season = "Spring", grades = 0:12),
  list(pattern = "Table C.1.7: Fall Language Usage Student", subject = "Language Usage", season = "Fall", grades = 2:11),
  list(pattern = "Table C.1.8: Winter Language Usage Student", subject = "Language Usage", season = "Winter", grades = 2:11),
  list(pattern = "Table C.1.9: Spring Language Usage Student", subject = "Language Usage", season = "Spring", grades = 2:11),
  list(pattern = "Table C.1.10: Fall Science Student", subject = "General Science", season = "Fall", grades = 3:11),
  list(pattern = "Table C.1.11: Winter Science Student", subject = "General Science", season = "Winter", grades = 3:11),
  list(pattern = "Table C.1.12: Spring Science Student", subject = "General Science", season = "Spring", grades = 3:11)
)

for (p in student_patterns) {
  cat("Parsing:", p$subject, p$season, "\n")
  df <- parse_status_table(txt, p$pattern, p$subject, p$season, p$grades)
  if (!is.null(df)) {
    all_student_status[[paste(p$subject, p$season)]] <- df
    cat("  Found", length(unique(df$student_percentile)), "percentiles\n")
  }
}

# Parse all school status tables
cat("\n=== Parsing School Status Tables ===\n")
all_school_status <- list()

# Patterns for school tables (C.2.x) with grade ranges
school_patterns <- list(
  list(pattern = "Table C.2.1: Fall Mathematics School", subject = "Mathematics", season = "Fall", grades = 0:12),
  list(pattern = "Table C.2.2: Winter Mathematics School", subject = "Mathematics", season = "Winter", grades = 0:12),
  list(pattern = "Table C.2.3: Spring Mathematics School", subject = "Mathematics", season = "Spring", grades = 0:12),
  list(pattern = "Table C.2.4: Fall Reading School", subject = "Reading", season = "Fall", grades = 0:12),
  list(pattern = "Table C.2.5: Winter Reading School", subject = "Reading", season = "Winter", grades = 0:12),
  list(pattern = "Table C.2.6: Spring Reading School", subject = "Reading", season = "Spring", grades = 0:12),
  list(pattern = "Table C.2.7: Fall Language Usage School", subject = "Language Usage", season = "Fall", grades = 2:11),
  list(pattern = "Table C.2.8: Winter Language Usage School", subject = "Language Usage", season = "Winter", grades = 2:11),
  list(pattern = "Table C.2.9: Spring Language Usage School", subject = "Language Usage", season = "Spring", grades = 2:11),
  list(pattern = "Table C.2.10: Fall Science School", subject = "General Science", season = "Fall", grades = 3:11),
  list(pattern = "Table C.2.11: Winter Science School", subject = "General Science", season = "Winter", grades = 3:11),
  list(pattern = "Table C.2.12: Spring Science School", subject = "General Science", season = "Spring", grades = 3:11)
)

for (p in school_patterns) {
  cat("Parsing:", p$subject, p$season, "\n")
  df <- parse_school_status_table(txt, p$pattern, p$subject, p$season, p$grades)
  if (!is.null(df)) {
    all_school_status[[paste(p$subject, p$season)]] <- df
    cat("  Found", length(unique(df$school_percentile)), "percentiles\n")
  }
}

# Combine all
status_norms_2020 <- bind_rows(all_student_status)
school_status_norms_2020 <- bind_rows(all_school_status)

cat("\n=== 2020 Student Status norms dimensions:", dim(status_norms_2020), "===\n")
print(head(status_norms_2020, 10))

cat("\n=== 2020 School Status norms dimensions:", dim(school_status_norms_2020), "===\n")
print(head(school_status_norms_2020, 10))

# Check subjects
cat("\nStudent subjects found:\n")
print(table(status_norms_2020$measurementscale, status_norms_2020$fallwinterspring))

cat("\nSchool subjects found:\n")
print(table(school_status_norms_2020$measurementscale, school_status_norms_2020$fallwinterspring))

# Save
write.csv(status_norms_2020, 'data-raw/status_norms_2020_parsed.csv', row.names = FALSE)
write.csv(school_status_norms_2020, 'data-raw/school_status_norms_2020_parsed.csv', row.names = FALSE)
cat("\nSaved to data-raw/status_norms_2020_parsed.csv\n")
cat("Saved to data-raw/school_status_norms_2020_parsed.csv\n")
