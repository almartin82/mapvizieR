library(dplyr)
library(tidyr)
library(stringr)

# Read the full text file
txt <- readLines('data-raw/2025_Technical_Manual.txt')

# Function to parse a 2025 status percentile table (handles variable grades)
parse_2025_status_table <- function(lines, line_num, subject, season, grade_range) {
  # Extract data lines (skip title, "Grade" row, and column headers)
  data_start <- line_num + 3
  data_lines <- lines[data_start:(data_start + 18)]

  # Parse each line
  parsed <- lapply(data_lines, function(line) {
    nums <- as.numeric(str_extract_all(line, "\\d+")[[1]])
    n_grades <- length(grade_range)
    if (length(nums) >= n_grades + 1) {
      # First number is percentile, next n are grades, last might be percentile again
      return(nums[1:(n_grades + 1)])
    }
    return(NULL)
  })

  parsed <- parsed[!sapply(parsed, is.null)]
  if (length(parsed) == 0) return(NULL)

  df <- do.call(rbind, parsed)
  colnames(df) <- c("percentile", paste0("G", grade_range))
  df <- as.data.frame(df)

  # Reshape to long format
  df_long <- df %>%
    pivot_longer(cols = -percentile, names_to = "grade_raw", values_to = "RIT") %>%
    mutate(
      grade = as.numeric(gsub("G", "", grade_raw)),
      measurementscale = subject,
      fallwinterspring = season,
      student_percentile = percentile
    ) %>%
    select(measurementscale, fallwinterspring, grade, RIT, student_percentile)

  return(df_long)
}

# Student tables with their line numbers and grade ranges
student_tables <- list(
  list(line = 1947, subject = "Mathematics", season = "Fall", grades = 0:12),
  list(line = 2007, subject = "Mathematics", season = "Winter", grades = 0:12),
  list(line = 2067, subject = "Mathematics", season = "Spring", grades = 0:12),
  list(line = 2129, subject = "Reading", season = "Fall", grades = 0:12),
  list(line = 2189, subject = "Reading", season = "Winter", grades = 0:12),
  list(line = 2249, subject = "Reading", season = "Spring", grades = 0:12),
  list(line = 2311, subject = "Language Usage", season = "Fall", grades = 2:11),
  list(line = 2371, subject = "Language Usage", season = "Winter", grades = 2:11),
  list(line = 2431, subject = "Language Usage", season = "Spring", grades = 2:11),
  list(line = 2492, subject = "General Science", season = "Fall", grades = 2:11),
  list(line = 2552, subject = "General Science", season = "Winter", grades = 2:11),
  list(line = 2612, subject = "General Science", season = "Spring", grades = 2:11)
)

# School tables with their line numbers and grade ranges
school_tables <- list(
  list(line = 1977, subject = "Mathematics", season = "Fall", grades = 0:12),
  list(line = 2037, subject = "Mathematics", season = "Winter", grades = 0:12),
  list(line = 2097, subject = "Mathematics", season = "Spring", grades = 0:12),
  list(line = 2159, subject = "Reading", season = "Fall", grades = 0:12),
  list(line = 2219, subject = "Reading", season = "Winter", grades = 0:12),
  list(line = 2279, subject = "Reading", season = "Spring", grades = 0:12),
  list(line = 2341, subject = "Language Usage", season = "Fall", grades = 2:11),
  list(line = 2401, subject = "Language Usage", season = "Winter", grades = 2:11),
  list(line = 2461, subject = "Language Usage", season = "Spring", grades = 2:11),
  list(line = 2522, subject = "General Science", season = "Fall", grades = 2:11),
  list(line = 2582, subject = "General Science", season = "Winter", grades = 2:11),
  list(line = 2642, subject = "General Science", season = "Spring", grades = 2:11)
)

# Parse student tables
cat("=== Parsing Student Tables ===\n")
all_student_status <- list()

for (t in student_tables) {
  cat("Parsing:", t$subject, t$season, "(line", t$line, ")\n")
  df <- parse_2025_status_table(txt, t$line, t$subject, t$season, t$grades)
  if (!is.null(df)) {
    all_student_status[[paste(t$subject, t$season)]] <- df
    cat("  Found", nrow(df), "rows\n")
  } else {
    cat("  FAILED\n")
  }
}

# Parse school tables
cat("\n=== Parsing School Tables ===\n")
all_school_status <- list()

for (t in school_tables) {
  cat("Parsing:", t$subject, t$season, "(line", t$line, ")\n")
  df <- parse_2025_status_table(txt, t$line, t$subject, t$season, t$grades)
  if (!is.null(df)) {
    # Rename column for school norms
    df <- df %>% rename(school_percentile = student_percentile)
    all_school_status[[paste(t$subject, t$season)]] <- df
    cat("  Found", nrow(df), "rows\n")
  } else {
    cat("  FAILED\n")
  }
}

# Combine all
status_norms_2025 <- bind_rows(all_student_status)
school_status_norms_2025 <- bind_rows(all_school_status)

cat("\n=== 2025 Student Status norms dimensions:", dim(status_norms_2025), "===\n")
print(head(status_norms_2025, 10))

cat("\n=== 2025 School Status norms dimensions:", dim(school_status_norms_2025), "===\n")
print(head(school_status_norms_2025, 10))

# Check subjects
cat("\nStudent subjects found:\n")
print(table(status_norms_2025$measurementscale, status_norms_2025$fallwinterspring))

cat("\nSchool subjects found:\n")
print(table(school_status_norms_2025$measurementscale, school_status_norms_2025$fallwinterspring))

# Save
write.csv(status_norms_2025, 'data-raw/status_norms_2025_parsed.csv', row.names = FALSE)
write.csv(school_status_norms_2025, 'data-raw/school_status_norms_2025_parsed.csv', row.names = FALSE)
cat("\nSaved to data-raw/status_norms_2025_parsed.csv\n")
cat("Saved to data-raw/school_status_norms_2025_parsed.csv\n")
