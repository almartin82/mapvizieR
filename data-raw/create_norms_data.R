library(dplyr)
library(tidyr)

# ============================================================================
# Create 2020 and 2025 Status Norms Data Files
# ============================================================================

# Load parsed CSV files
status_2020 <- read.csv('data-raw/status_norms_2020_parsed.csv', stringsAsFactors = FALSE)
status_2025 <- read.csv('data-raw/status_norms_2025_parsed.csv', stringsAsFactors = FALSE)
school_status_2020 <- read.csv('data-raw/school_status_norms_2020_parsed.csv', stringsAsFactors = FALSE)
school_status_2025 <- read.csv('data-raw/school_status_norms_2025_parsed.csv', stringsAsFactors = FALSE)

cat("2020 student raw dimensions:", dim(status_2020), "\n")
cat("2020 school raw dimensions:", dim(school_status_2020), "\n")
cat("2025 student raw dimensions:", dim(status_2025), "\n")
cat("2025 school raw dimensions:", dim(school_status_2025), "\n")

# The parsed data is percentile -> RIT format
# We need to convert to RIT -> percentile format (like status_norms_2015)

# Function to expand percentile->RIT to RIT->percentile (dense)
# pctl_col specifies which column contains the percentile (student_percentile or school_percentile)
expand_to_rit_lookup <- function(df, pctl_col = "student_percentile") {
  # For each measurementscale/season/grade combination,
  # create a mapping from every RIT value to its percentile

  # Round RIT values to integers for consistent dense lookup
  df <- df %>% mutate(RIT = round(RIT))

  result <- df %>%
    group_by(measurementscale, fallwinterspring, grade) %>%
    arrange(.data[[pctl_col]]) %>%
    mutate(
      next_rit = lead(RIT),
      next_pctl = lead(.data[[pctl_col]])
    ) %>%
    ungroup()

  # Expand each range to include all RIT values
  expanded <- list()

  groups <- result %>%
    select(measurementscale, fallwinterspring, grade) %>%
    unique()

  for (i in 1:nrow(groups)) {
    ms <- groups$measurementscale[i]
    fws <- groups$fallwinterspring[i]
    gr <- groups$grade[i]

    subset_df <- result %>%
      filter(measurementscale == ms, fallwinterspring == fws, grade == gr)

    # Get min and max RIT for this group
    min_rit <- min(subset_df$RIT) - 10  # extend range below
    max_rit <- max(subset_df$RIT) + 10  # extend range above

    # Create all RIT values
    all_rits <- data.frame(
      measurementscale = ms,
      fallwinterspring = fws,
      grade = gr,
      RIT = seq(min_rit, max_rit)
    )

    # Join with percentiles - use approx interpolation
    rit_pctl <- subset_df %>%
      select(RIT, all_of(pctl_col)) %>%
      arrange(RIT)

    # Use approx for interpolation
    all_rits[[pctl_col]] <- round(approx(
      x = rit_pctl$RIT,
      y = rit_pctl[[pctl_col]],
      xout = all_rits$RIT,
      rule = 2  # extrapolate to min/max at boundaries
    )$y)

    # Ensure percentiles are within 1-99
    all_rits[[pctl_col]] <- pmax(1, pmin(99, all_rits[[pctl_col]]))

    expanded[[length(expanded) + 1]] <- all_rits
  }

  result_df <- bind_rows(expanded)
  return(result_df)
}

# Create dense extended versions (RIT -> percentile for each RIT value)
cat("\nCreating 2020 student dense extended norms...\n")
student_status_norms_2020_dense_extended <- expand_to_rit_lookup(status_2020, pctl_col = "student_percentile")
cat("2020 student dense extended dimensions:", dim(student_status_norms_2020_dense_extended), "\n")

cat("\nCreating 2025 student dense extended norms...\n")
student_status_norms_2025_dense_extended <- expand_to_rit_lookup(status_2025, pctl_col = "student_percentile")
cat("2025 student dense extended dimensions:", dim(student_status_norms_2025_dense_extended), "\n")

cat("\nCreating 2020 school dense extended norms...\n")
school_status_norms_2020_dense_extended <- expand_to_rit_lookup(school_status_2020, pctl_col = "school_percentile")
cat("2020 school dense extended dimensions:", dim(school_status_norms_2020_dense_extended), "\n")

cat("\nCreating 2025 school dense extended norms...\n")
school_status_norms_2025_dense_extended <- expand_to_rit_lookup(school_status_2025, pctl_col = "school_percentile")
cat("2025 school dense extended dimensions:", dim(school_status_norms_2025_dense_extended), "\n")

# Create status_norms (same structure as status_norms_2015)
# This is the same as dense extended
status_norms_2020 <- student_status_norms_2020_dense_extended %>%
  as_tibble()

status_norms_2025 <- student_status_norms_2025_dense_extended %>%
  as_tibble()

# Convert to tibbles for consistency
student_status_norms_2020_dense_extended <- as_tibble(student_status_norms_2020_dense_extended)
student_status_norms_2025_dense_extended <- as_tibble(student_status_norms_2025_dense_extended)
school_status_norms_2020_dense_extended <- as_tibble(school_status_norms_2020_dense_extended)
school_status_norms_2025_dense_extended <- as_tibble(school_status_norms_2025_dense_extended)

# Verify data
cat("\n=== Verification ===\n")
cat("2020 subjects:", unique(status_norms_2020$measurementscale), "\n")
cat("2025 subjects:", unique(status_norms_2025$measurementscale), "\n")

cat("\n2020 grade range by subject:\n")
print(status_norms_2020 %>% group_by(measurementscale) %>% summarize(min_grade = min(grade), max_grade = max(grade)))

cat("\n2025 grade range by subject:\n")
print(status_norms_2025 %>% group_by(measurementscale) %>% summarize(min_grade = min(grade), max_grade = max(grade)))

# Test specific values from 2025 Tech Manual Table B.1 (Math Fall Student)
cat("\n=== 2025 Norms Validation ===\n")
cat("Math Fall Grade 5 50th percentile RIT (expected ~206):\n")
test_val <- status_norms_2025 %>%
  filter(measurementscale == "Mathematics", fallwinterspring == "Fall", grade == 5, student_percentile == 50) %>%
  select(RIT) %>%
  head(1)
print(test_val)

# Save data files
cat("\nSaving data files...\n")

save(status_norms_2020, file = 'data/status_norms_2020.rda', compress = 'xz')
save(status_norms_2025, file = 'data/status_norms_2025.rda', compress = 'xz')
save(student_status_norms_2020_dense_extended, file = 'data/student_status_norms_2020_dense_extended.rda', compress = 'xz')
save(student_status_norms_2025_dense_extended, file = 'data/student_status_norms_2025_dense_extended.rda', compress = 'xz')
save(school_status_norms_2020_dense_extended, file = 'data/school_status_norms_2020_dense_extended.rda', compress = 'xz')
save(school_status_norms_2025_dense_extended, file = 'data/school_status_norms_2025_dense_extended.rda', compress = 'xz')

cat("Done! Created:\n")
cat("  - data/status_norms_2020.rda\n")
cat("  - data/status_norms_2025.rda\n")
cat("  - data/student_status_norms_2020_dense_extended.rda\n")
cat("  - data/student_status_norms_2025_dense_extended.rda\n")
cat("  - data/school_status_norms_2020_dense_extended.rda\n")
cat("  - data/school_status_norms_2025_dense_extended.rda\n")
