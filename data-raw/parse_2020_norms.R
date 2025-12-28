library(dplyr)
library(tidyr)
library(stringr)

# Read the full text file
txt <- readLines('data-raw/NormsTables2020_full.txt')

# Function to parse a status percentile table
parse_status_table <- function(lines, start_pattern, subject, season) {
  # Find start of table
  start_idx <- grep(start_pattern, lines, fixed = TRUE)[1]
  if (is.na(start_idx)) {
    cat("  Pattern not found:", start_pattern, "\n")
    return(NULL)
  }

  # Extract data lines (skip header rows, get 99 data rows)
  data_start <- start_idx + 4  # Skip table title and header
  data_lines <- lines[data_start:(data_start + 98)]

  # Parse each line
  parsed <- lapply(data_lines, function(line) {
    nums <- as.numeric(str_extract_all(line, "\\d+")[[1]])
    if (length(nums) >= 14) {
      return(nums[1:14])  # Pct, K, 1-11, 12
    }
    return(NULL)
  })

  parsed <- parsed[!sapply(parsed, is.null)]
  df <- do.call(rbind, parsed)
  if (is.null(df) || nrow(df) == 0) return(NULL)

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

# Parse all status tables
all_status <- list()

# Patterns for each table
patterns <- list(
  list(pattern = "Table C.1.1: Fall Mathematics", subject = "Mathematics", season = "Fall"),
  list(pattern = "Table C.1.2: Winter Mathematics", subject = "Mathematics", season = "Winter"),
  list(pattern = "Table C.1.3: Spring Mathematics", subject = "Mathematics", season = "Spring"),
  list(pattern = "Table C.1.4: Fall Reading", subject = "Reading", season = "Fall"),
  list(pattern = "Table C.1.5: Winter Reading", subject = "Reading", season = "Winter"),
  list(pattern = "Table C.1.6: Spring Reading", subject = "Reading", season = "Spring"),
  list(pattern = "Table C.1.7: Fall Language Usage", subject = "Language Usage", season = "Fall"),
  list(pattern = "Table C.1.8: Winter Language Usage", subject = "Language Usage", season = "Winter"),
  list(pattern = "Table C.1.9: Spring Language Usage", subject = "Language Usage", season = "Spring"),
  list(pattern = "Table C.1.10", subject = "General Science", season = "Fall"),
  list(pattern = "Table C.1.11", subject = "General Science", season = "Winter"),
  list(pattern = "Table C.1.12", subject = "General Science", season = "Spring")
)

for (p in patterns) {
  cat("Parsing:", p$subject, p$season, "\n")
  df <- parse_status_table(txt, p$pattern, p$subject, p$season)
  if (!is.null(df)) {
    all_status[[paste(p$subject, p$season)]] <- df
  }
}

# Combine all
status_norms_2020 <- bind_rows(all_status)
cat("\nStatus norms 2020 dimensions:", dim(status_norms_2020), "\n")
print(head(status_norms_2020, 20))

# Save
write.csv(status_norms_2020, 'data-raw/status_norms_2020_parsed.csv', row.names = FALSE)
cat("\nSaved to data-raw/status_norms_2020_parsed.csv\n")
