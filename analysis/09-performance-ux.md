# Performance and User Experience Analysis - mapvizieR

## Executive Summary

Performance appears adequate for typical use cases but may degrade with large datasets (10,000+ students). User experience could be improved with better error messages, progress indicators, and validation. Several common user mistakes are not guarded against.

## 1. Performance with Large Datasets

### Current Assessment

Based on code analysis, potential bottlenecks:

| Operation | Concern Level | Notes |
|-----------|--------------|-------|
| mapvizieR object creation | Medium | Multiple joins, could be slow |
| CGP calculation | High | Loop-based in cgp_prep.R |
| Growth df generation | Medium | Multiple growth window calculations |
| Visualization rendering | Low-Medium | ggplot2 is generally fast |

### Specific Performance Concerns

#### 1.1 CGP Calculation Loop

```r
# cgp_prep.R - Loop-based calculation
for (i in 1:nrow(results)) {
  results[i, ]$cgp <- calc_cgp(...)
}
```

**Issue**: Row-by-row loop is slow in R
**Recommendation**: Vectorize or use `purrr::map()` with proper parallelization

#### 1.2 Growth DF Generation

```r
# growth_df_prep.R
generate_growth_dfs(processed_cdf, norm_df_long = norms_long, ...)
```

**Issue**: Creates growth windows for all possible combinations
**Recommendation**: Add lazy evaluation or caching

#### 1.3 Report Dispatcher

```r
# report_dispatcher.R - 185 lines
# Iterates over combinations of schools, grades, subjects
```

**Issue**: Can generate many reports sequentially
**Recommendation**: Add parallel processing option

### Performance Recommendations

1. **Add benchmarking tests**:
```r
test_that("handles 10000 students efficiently", {
  skip_on_cran()
  large_cdf <- generate_large_test_cdf(10000)

  time <- system.time({
    mv <- mapvizieR(large_cdf, large_roster)
  })

  expect_lt(time["elapsed"], 60)  # < 1 minute
})
```

2. **Consider data.table for large data operations**:
```r
# For large CDFs, data.table joins are much faster
if (nrow(cdf) > 10000) {
  # Use data.table backend
}
```

3. **Add progress indicators** (see section 5)

## 2. Memory Efficiency

### Current Memory Usage Patterns

```r
# mapvizieR_object.R
# Creates three full data frames in memory
mapviz <- list(
  'cdf' = processed_cdf,        # Full copy
  'roster' = roster,            # Full copy
  'growth_df' = growth_df       # Full copy
)
```

### Potential Issues

1. **Duplicate data**: Some data exists in both CDF and growth_df
2. **No lazy loading**: All data loaded immediately
3. **No garbage collection hints**: Large intermediates may persist

### Recommendations

1. **Document memory requirements**:
```r
#' @details
#' Memory Usage: Approximately 3x the size of input data.
#' For 10,000 students over 5 years, expect ~500MB memory usage.
```

2. **Add memory-efficient mode** (optional):
```r
mapvizieR <- function(cdf, roster, verbose = FALSE, norms = 2015,
                      memory_efficient = FALSE, ...) {
  if (memory_efficient) {
    # Don't pre-calculate all growth windows
    # Use lazy evaluation
  }
}
```

## 3. Plot Rendering Speed

### Current State

Most plots render quickly for typical cohort sizes (50-500 students).

### Potential Slowdowns

1. **haid_plot with many students**:
   - Creates individual elements per student
   - 500+ students may be slow

2. **galloping_elephants with dense data**:
   - Density calculations scale with data size

3. **quealy_subgroups with many subgroups**:
   - Creates separate plots per subgroup

### Recommendations

1. **Add sampling for large cohorts**:
```r
haid_plot <- function(..., max_students = 200) {
  if (length(studentids) > max_students) {
    message(sprintf("Sampling %d of %d students for display",
                    max_students, length(studentids)))
    studentids <- sample(studentids, max_students)
  }
  # ...
}
```

2. **Add rendering progress** for slow plots:
```r
if (verbose) {
  message("Rendering plot... (this may take a moment for large cohorts)")
}
```

## 4. Caching Opportunities

### What Could Be Cached

1. **Norm lookups**: Same norms used repeatedly
2. **CGP calculations**: Same inputs give same outputs
3. **Processed CDFs**: If input hasn't changed

### Implementation Options

1. **Package-level cache** (using memoise):
```r
calc_cgp_cached <- memoise::memoise(calc_cgp)
```

2. **Session-level cache** in mapvizieR object:
```r
mapviz$cache <- new.env(hash = TRUE)
```

3. **Disk cache** for large computations:
```r
# Save processed CDF to temp file
saveRDS(processed_cdf, tempfile())
```

### Recommendation

Add `memoise` to Suggests and optionally cache expensive calculations.

## 5. Progress Indicators

### Current State

**No progress indicators exist** for long operations.

Only feedback is `verbose` mode messages:
```r
if (verbose) print('preparing and processing your CDF...')
```

### Recommended Implementation

Use `cli` package for modern progress bars:

```r
#' @importFrom cli cli_progress_bar cli_progress_update cli_progress_done

mapvizieR <- function(cdf, roster, verbose = FALSE, norms = 2015, ...) {

  if (verbose) {
    cli::cli_progress_bar("Creating mapvizieR object", total = 5)
  }

  # Step 1
  prepped_cdf <- prep_cdf_long(cdf)
  if (verbose) cli::cli_progress_update()

  # Step 2
  roster <- prep_roster(roster)
  if (verbose) cli::cli_progress_update()

  # ... etc

  if (verbose) cli::cli_progress_done()

  return(mapviz)
}
```

### Functions Needing Progress Indicators

| Function | Reason |
|----------|--------|
| `mapvizieR()` | Multi-step object creation |
| `cdf_to_cgp()` | Large CGP calculations |
| `report_dispatcher()` | Multiple report generation |
| `generate_growth_dfs()` | Growth window calculations |

## 6. Error Messages

### Current Error Handling

Uses multiple approaches inconsistently:
- `ensurer::ensure_that()` - DEPRECATED
- `assertthat::assert_that()`
- `stopifnot()` - Cryptic messages
- `stop()` - Direct errors

### Example Poor Error Messages

```r
# stopifnot gives unhelpful error
stopifnot(length(df$start_testritscore) > 0)
# Error: length(df$start_testritscore) > 0 is not TRUE

# ensurer also not great
df %>% ensurer::ensure_that(nrow(.) > 0 ~ "no matching students")
```

### Recommended Error Message Pattern

```r
# Using cli for user-friendly errors
if (length(studentids) == 0) {
  cli::cli_abort(c(
    "No students found in the data",
    "i" = "Check that your studentids match those in the mapvizieR object",
    "x" = "Received {length(studentids)} student IDs"
  ))
}

# Using rlang for programmatic errors
if (!is.mapvizieR(mapvizieR_obj)) {
  rlang::abort(
    message = "Expected a mapvizieR object",
    class = "mapvizier_type_error",
    mapvizieR_obj = class(mapvizieR_obj)
  )
}
```

### Functions Needing Better Errors

| Function | Current Error | Recommended Error |
|----------|--------------|-------------------|
| `mv_opening_checks()` | Generic assertion | Specific guidance |
| `becca_plot()` | Silent failures possible | Catch edge cases |
| `haid_plot()` | `stopifnot()` | Informative message |
| All plot functions | Various | Standardize with cli |

## 7. Default Values

### Current Defaults Assessment

| Function | Parameter | Default | Assessment |
|----------|-----------|---------|------------|
| `mapvizieR()` | norms | 2015 | Should update to 2020 |
| `becca_plot()` | small_n_cutoff | 0.5 | OK |
| `becca_plot()` | detail_academic_year | 2014 | OUTDATED! |
| `haid_plot()` | colors | hardcoded | Should be NULL (use theme) |

### Problematic Defaults

1. **Hardcoded years**:
```r
# becca_plot.R:34
detail_academic_year = 2014  # 10 years old!

# Should be:
detail_academic_year = as.integer(format(Sys.Date(), "%Y"))
# Or:
detail_academic_year = NULL  # Infer from data
```

2. **Norm study default**:
```r
# Should default to most recent
norms = 2015  # Update to 2020 when available
```

3. **Magic thresholds**:
```r
small_n_cutoff = 0.5  # What does this mean?
# Should document: "Drops terms with < 50% of max term size"
```

### Recommended Changes

```r
# Use NULL for "auto-detect from data"
becca_plot <- function(
  mapvizieR_obj,
  studentids,
  measurementscale,
  first_and_spring_only = TRUE,
  entry_grade_seasons = c(-0.8, 4.2),
  detail_academic_year = NULL,  # Auto-detect
  ...
) {
  if (is.null(detail_academic_year)) {
    detail_academic_year <- max(mapvizieR_obj$cdf$map_year_academic)
  }
  # ...
}
```

## 8. Common User Mistakes to Guard Against

### Identified Common Mistakes

1. **Wrong data format**:
   - Passing raw CSV instead of prepped data
   - Missing required columns

2. **Student ID mismatches**:
   - IDs in studentids not in CDF
   - Different ID formats (character vs numeric)

3. **Invalid season/year combinations**:
   - Requesting data that doesn't exist
   - Typos in season names ("fall" vs "Fall")

4. **Wrong measurementscale**:
   - Typos or case mismatches
   - Using full names vs abbreviations

### Recommended Guards

```r
# 1. Validate studentids exist
validate_studentids <- function(mapvizieR_obj, studentids) {
  valid_ids <- unique(mapvizieR_obj$roster$studentid)
  missing <- setdiff(studentids, valid_ids)

  if (length(missing) > 0) {
    pct_missing <- length(missing) / length(studentids) * 100

    if (pct_missing > 50) {
      cli::cli_abort(c(
        "{round(pct_missing)}% of student IDs not found in data",
        "i" = "Check that student IDs match those in the roster"
      ))
    } else {
      cli::cli_warn(c(
        "{length(missing)} student IDs not found ({round(pct_missing)}%)",
        "i" = "These students will be excluded from the analysis"
      ))
    }
  }
}

# 2. Validate measurementscale
validate_measurementscale <- function(mapvizieR_obj, measurementscale) {
  valid_ms <- unique(mapvizieR_obj$cdf$measurementscale)

  if (!measurementscale %in% valid_ms) {
    # Check for case-insensitive match
    match <- valid_ms[tolower(valid_ms) == tolower(measurementscale)]

    if (length(match) == 1) {
      cli::cli_warn(c(
        "Correcting measurementscale: {.val {measurementscale}} -> {.val {match}}",
        "i" = "Consider using the exact case in future"
      ))
      return(match)
    } else {
      cli::cli_abort(c(
        "Unknown measurementscale: {.val {measurementscale}}",
        "i" = "Available options: {.val {valid_ms}}"
      ))
    }
  }

  return(measurementscale)
}

# 3. Validate term exists
validate_term <- function(mapvizieR_obj, fws, academic_year) {
  valid_terms <- unique(paste(
    mapvizieR_obj$cdf$fallwinterspring,
    mapvizieR_obj$cdf$map_year_academic
  ))

  requested <- paste(fws, academic_year)

  if (!requested %in% valid_terms) {
    cli::cli_abort(c(
      "No data found for {.val {fws}} {.val {academic_year}}",
      "i" = "Available terms: {.val {valid_terms}}"
    ))
  }
}
```

### Add to mv_opening_checks

```r
mv_opening_checks <- function(mapvizieR_obj, studentids, min_stu = 1) {
  # Existing checks
  mapvizieR_obj %>% ensure_is_mapvizieR()

  # Add new validation
  validate_studentids(mapvizieR_obj, studentids)

  # Rest of checks...
}
```

## 9. User Experience Improvements

### Quick Wins

1. **Better print method**:
```r
print.mapvizieR <- function(x, ...) {
  cli::cli_h1("mapvizieR Object")
  cli::cli_text("Schools: {length(unique(x$roster$schoolname))}")
  cli::cli_text("Students: {length(unique(x$roster$studentid))}")
  cli::cli_text("Years: {min(x$cdf$map_year_academic)}-{max(x$cdf$map_year_academic)}")
  cli::cli_text("Subjects: {paste(unique(x$cdf$measurementscale), collapse = ', ')}")
}
```

2. **Helpful suggestions on error**:
```r
# When plot fails, suggest common fixes
tryCatch(
  becca_plot(...),
  error = function(e) {
    cli::cli_abort(c(
      conditionMessage(e),
      "i" = "Common fixes:",
      "*" = "Check that studentids are in the data",
      "*" = "Verify measurementscale spelling",
      "*" = "Ensure data exists for requested terms"
    ))
  }
)
```

3. **Add diagnostic function**:
```r
#' @export
diagnose_mapvizier <- function(mapvizieR_obj) {
  # Check for common issues
  issues <- list()

  # Check for missing data
  if (any(is.na(mapvizieR_obj$cdf$testritscore))) {
    issues$missing_rit <- "Some RIT scores are missing"
  }

  # Check for duplicate entries
  dupes <- duplicated(mapvizieR_obj$cdf[, c("studentid", "termname", "measurementscale")])
  if (any(dupes)) {
    issues$duplicates <- sprintf("%d duplicate entries found", sum(dupes))
  }

  # Report
  if (length(issues) == 0) {
    cli::cli_alert_success("No issues found")
  } else {
    cli::cli_alert_warning("Found {length(issues)} potential issues:")
    for (issue in issues) {
      cli::cli_li(issue)
    }
  }

  invisible(issues)
}
```

## 10. Summary: UX Priorities

### Priority 1 (High Impact, Low Effort)

1. **Update hardcoded years** (detail_academic_year = 2014)
2. **Add input validation** to visualization functions
3. **Improve error messages** with cli package

### Priority 2 (High Impact, Medium Effort)

4. **Add progress indicators** for long operations
5. **Create diagnose_mapvizier()** function
6. **Better print/summary methods**

### Priority 3 (Medium Impact, Higher Effort)

7. **Performance optimization** for large datasets
8. **Add caching** for expensive calculations
9. **Memory efficiency** options

### Priority 4 (Nice to Have)

10. **Parallel processing** for report generation
11. **Lazy evaluation** for growth calculations
12. **Comprehensive benchmarking suite**
