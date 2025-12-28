library(dplyr)
library(tidyr)

# ============================================================================
# Create 2020 and 2025 Status Norms Data Files
# ============================================================================

# Load parsed CSV files
status_2020 <- read.csv('data-raw/status_norms_2020_parsed.csv', stringsAsFactors = FALSE)
status_2025 <- read.csv('data-raw/status_norms_2025_parsed.csv', stringsAsFactors = FALSE)

cat("2020 raw dimensions:", dim(status_2020), "\n")
cat("2025 raw dimensions:", dim(status_2025), "\n")

# The parsed data is percentile -> RIT format
# We need to convert to RIT -> percentile format (like status_norms_2015)

# Function to expand percentile->RIT to RIT->percentile (dense)
expand_to_rit_lookup <- function(df, include_school_pctl = TRUE) {
  # For each measurementscale/season/grade combination,
  # create a mapping from every RIT value to its percentile

  result <- df %>%
    group_by(measurementscale, fallwinterspring, grade) %>%
    arrange(student_percentile) %>%
    mutate(
      next_rit = lead(RIT),
      next_pctl = lead(student_percentile)
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
      select(RIT, student_percentile) %>%
      arrange(RIT)

    # Use approx for interpolation
    all_rits$student_percentile <- round(approx(
      x = rit_pctl$RIT,
      y = rit_pctl$student_percentile,
      xout = all_rits$RIT,
      rule = 2  # extrapolate to min/max at boundaries
    )$y)

    # Ensure percentiles are within 1-99
    all_rits$student_percentile <- pmax(1, pmin(99, all_rits$student_percentile))

    expanded[[length(expanded) + 1]] <- all_rits
  }

  result_df <- bind_rows(expanded)

  if (include_school_pctl) {
    # School percentile - for now, use same as student percentile
    # (NWEA provides school norms separately, but they're similar)
    result_df$school_percentile <- result_df$student_percentile
  }

  return(result_df)
}

# Create dense extended versions (RIT -> percentile for each RIT value)
cat("\nCreating 2020 dense extended norms...\n")
student_status_norms_2020_dense_extended <- expand_to_rit_lookup(status_2020, include_school_pctl = TRUE)
cat("2020 dense extended dimensions:", dim(student_status_norms_2020_dense_extended), "\n")

cat("\nCreating 2025 dense extended norms...\n")
student_status_norms_2025_dense_extended <- expand_to_rit_lookup(status_2025, include_school_pctl = TRUE)
cat("2025 dense extended dimensions:", dim(student_status_norms_2025_dense_extended), "\n")

# Create status_norms (same structure as status_norms_2015)
# This is the same as dense extended
status_norms_2020 <- student_status_norms_2020_dense_extended %>%
  as_tibble()

status_norms_2025 <- student_status_norms_2025_dense_extended %>%
  as_tibble()

# Also create school versions (for cohort_mean_rit_to_npr)
school_status_norms_2020_dense_extended <- student_status_norms_2020_dense_extended
school_status_norms_2025_dense_extended <- student_status_norms_2025_dense_extended

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
