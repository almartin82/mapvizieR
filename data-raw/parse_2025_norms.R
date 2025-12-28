library(dplyr)
library(tidyr)
library(stringr)

# Read the full text file
txt <- readLines('data-raw/2025_Technical_Manual.txt')

# Function to parse a 2025 status percentile table
parse_2025_status_table <- function(lines, start_pattern, subject, season) {
  # Find start of table
  start_idx <- grep(start_pattern, lines, fixed = TRUE)[1]
  if (is.na(start_idx)) {
    cat("  Pattern not found:", start_pattern, "\n")
    return(NULL)
  }

  # Extract data lines (skip header rows - title, "Grade", column headers)
  # Tables have 19 rows of data (percentiles 5,10,15...95)
  data_start <- start_idx + 3  # Skip title, "Grade" row, and column headers
  data_lines <- lines[data_start:(data_start + 18)]

  # Parse each line
  parsed <- lapply(data_lines, function(line) {
    nums <- as.numeric(str_extract_all(line, "\\d+")[[1]])
    if (length(nums) >= 14) {
      # First number is percentile, next 13 are grades K-12, last is percentile again
      return(nums[1:14])
    }
    return(NULL)
  })

  parsed <- parsed[!sapply(parsed, is.null)]
  if (length(parsed) == 0) return(NULL)

  df <- do.call(rbind, parsed)
  colnames(df) <- c("percentile", "K", paste0("G", 1:12))
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

# Parse all 2025 status tables
all_status <- list()

# Patterns for each student table (not school tables)
patterns <- list(
  list(pattern = "Table B.1.: Achievement Percentiles - Mathematics, Fall, Student", subject = "Mathematics", season = "Fall"),
  list(pattern = "Table B.3.: Achievement Percentiles - Mathematics, Winter, Student", subject = "Mathematics", season = "Winter"),
  list(pattern = "Table B.5.: Achievement Percentiles - Mathematics, Spring, Student", subject = "Mathematics", season = "Spring"),
  list(pattern = "Table B.7.: Achievement Percentiles - Reading, Fall, Student", subject = "Reading", season = "Fall"),
  list(pattern = "Table B.9.: Achievement Percentiles - Reading, Winter, Student", subject = "Reading", season = "Winter"),
  list(pattern = "Table B.11.: Achievement Percentiles - Reading, Spring, Student", subject = "Reading", season = "Spring"),
  list(pattern = "Table B.13.: Achievement Percentiles - Language Usage, Fall, Student", subject = "Language Usage", season = "Fall"),
  list(pattern = "Table B.15.: Achievement Percentiles - Language Usage, Winter, Student", subject = "Language Usage", season = "Winter"),
  list(pattern = "Table B.17.: Achievement Percentiles - Language Usage, Spring, Student", subject = "Language Usage", season = "Spring"),
  list(pattern = "Table B.19.: Achievement Percentiles - Science, Fall, Student", subject = "General Science", season = "Fall"),
  list(pattern = "Table B.21.: Achievement Percentiles - Science, Winter, Student", subject = "General Science", season = "Winter"),
  list(pattern = "Table B.23.: Achievement Percentiles - Science, Spring, Student", subject = "General Science", season = "Spring")
)

for (p in patterns) {
  cat("Parsing:", p$subject, p$season, "\n")
  df <- parse_2025_status_table(txt, p$pattern, p$subject, p$season)
  if (!is.null(df)) {
    all_status[[paste(p$subject, p$season)]] <- df
    cat("  Found", nrow(df), "rows\n")
  }
}

# Combine all
status_norms_2025 <- bind_rows(all_status)
cat("\n=== 2025 Status norms dimensions:", dim(status_norms_2025), "===\n")
print(head(status_norms_2025, 30))
print(tail(status_norms_2025, 10))

# Save
write.csv(status_norms_2025, 'data-raw/status_norms_2025_parsed.csv', row.names = FALSE)
cat("\nSaved to data-raw/status_norms_2025_parsed.csv\n")
