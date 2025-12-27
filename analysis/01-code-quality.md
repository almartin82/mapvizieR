# Code Quality Analysis - mapvizieR

## Executive Summary

This analysis identifies significant code quality issues requiring modernization. The codebase shows its age (last major update ~2017) with numerous deprecated patterns and practices that need addressing.

## 1. Function Complexity Analysis

### Highly Complex Functions (>100 lines)

| File | Function | Lines | Cyclomatic Complexity Est. | Recommendation |
|------|----------|-------|---------------------------|----------------|
| `college_plots.R` | multiple | 1268 total | Very High | Split into multiple files |
| `haid_plot.R` | `haid_plot()` | 639 | Very High (~40+) | Refactor into helpers |
| `cgp_prep.R` | `cdf_to_cgp()` | 767 total | High | Extract sub-functions |
| `fall_goals_report.R` | various | 675 | High | Modularize |
| `quealy_subgroups.R` | `quealy_subgroups()` | 338 | High (~25) | Extract plotting logic |
| `cdf_prep.R` | `process_cdf_long()` | 406 | Medium-High | Consider splitting |
| `growth_df_prep.R` | various | 408 | Medium-High | Improve modularity |

### Functions Exceeding 50 Lines Needing Refactoring

1. **`haid_plot()`** (R/haid_plot.R:29-639) - 610 lines
   - Contains data processing, multiple conditional branches, plot construction
   - Should extract: data prep, label generation, plot assembly

2. **`quealy_subgroups()`** (R/quealy_subgroups.R:39-338) - 299 lines
   - Mixes iteration logic with plot generation
   - Should extract: window calculation, stats aggregation

3. **`becca_plot()`** (R/becca_plot.R:28-232) - 204 lines
   - Manageable but could benefit from helper extraction

4. **`goalbar()`** (R/goalbar.R:27-255) - 228 lines
   - Data tagging logic could be extracted

## 2. Code Duplication Patterns

### Duplicated Patterns Across Visualization Functions

1. **Opening validation pattern** - repeated in every plot function:
   ```r
   mv_opening_checks(mapvizieR_obj, studentids, 1)
   ```

2. **Data extraction pattern** - repeated with minor variations:
   ```r
   this_cdf <- mv_limit_cdf(mapvizieR_obj, studentids, measurementscale)
   ```

3. **Theme construction** - each plot builds similar themes from scratch:
   - `theme_bw()` + custom overrides repeated in: `becca_plot`, `galloping_elephants`, `haid_plot`, `goalbar`, `quealy_facet_one_subgroup`

4. **Quartile color lookup** - duplicated in multiple files:
   - `haid_plot.R` lines 161-166
   - `util.R` has `kipp_quartile()` but color mapping repeated

### Recommendation
Create `R/theme_mapvizier.R` with:
- `theme_mapvizier()` - base theme
- `scale_fill_quartile()` - consistent quartile colors
- `scale_color_quartile()` - consistent quartile colors

## 3. Naming Convention Inconsistencies

### snake_case vs camelCase Violations

| Pattern | Examples | Count |
|---------|----------|-------|
| camelCase in columns | `measurementscale`, `studentid`, `testritscore` | Many (from NWEA data) |
| Mixed in functions | `mapvizieR` vs `mapvizier` (inconsistent!) | 2 |
| Mixed parameters | `mapvizieR_obj` vs snake_case others | Throughout |

### Specific Issues

1. **mapvizieR vs mapvizier**: Used interchangeably throughout codebase
   - Class is `mapvizieR`
   - Documentation sometimes says `mapvizier`
   - File `mapvizier_summary.R` uses different spelling

2. **Parameter naming**:
   - `first_and_spring_only` (snake_case) - good
   - `measurementscale` (no underscore) - inconsistent
   - `studentids` (no underscore) - inconsistent

## 4. Magic Numbers and Hardcoded Values

### Colors (Should Be Centralized)

```r
# haid_plot.R:39-41
p_growth_colors = c("tan4", "snow4", "gold", "red")
p_quartile_colors = c('#f3716b', '#79ac41', '#1ebdc2', '#a57eb8')

# quealy_facet_one_subgroup.R:490
color = 'hotpink'  # hardcoded

# galloping_elephants.R:102
scale_fill_brewer(type = 'seq', palette = 'Blues')
```

### Sizes and Thresholds

```r
# becca_plot.R:175-176
size = 4  # text size hardcoded

# haid_plot.R:92-93
pointsize <- 3
annotate_size <- 5

# quealy_subgroups.R:424-425
min_width <- 0.2
max_width <- 0.5
```

### Grade-Related Magic Numbers

```r
# tiered_growth_factors in util.R
c(1.5,1.5,1.25,1,2,1.75,1.5,1)  # KIPP tiered growth factors

# fall_spring_me:313
gr_spr <- c(0:12)  # grade range
```

## 5. Roxygen2 Documentation Issues

### Functions Missing Documentation

- Internal helpers in `util.R`: `df_sorter`, `is_error`, `is_not_error`, `rand_stu`, `clean_measurementscale`, `munge_startdate`
- Many `@return` tags are vague or missing
- `@examples` often wrapped in `\dontrun{}` - should have runnable examples

### Incomplete Documentation

1. **Missing @param tags**:
   - `get_group_stats()` in haid_plot.R - no @export but used

2. **Vague @return descriptions**:
   - `becca_plot()`: "prints a ggplot object" (it returns, doesn't print)
   - `haid_plot()`: "prints a ggplot object" (same issue)

## 6. Deprecated R/tidyverse Patterns

### CRITICAL: Deprecated dplyr Functions (dplyr 1.0+)

| Deprecated | Replacement | Files Affected |
|------------|-------------|----------------|
| `summarize_()` | `summarize()` with `.data` | haid_plot.R:682, util.R:644 |
| `group_by_()` | `group_by()` with `.data` | quealy_subgroups.R:357, util.R:648 |
| `select_()` | `select()` with `all_of()` | util.R:644-665 |
| `mutate_()` | `mutate()` | util.R |
| `dplyr::tbl_df()` | `tibble::as_tibble()` | util.R:46 |
| `dplyr::with_order()` | `dplyr::arrange()` pattern | becca_plot.R:128, goalbar.R:213 |

### Deprecated tidyr Functions

| Deprecated | Replacement | Location |
|------------|-------------|----------|
| `gather()` | `pivot_longer()` | (check needed) |
| `spread()` | `pivot_wider()` | (check needed) |

### Deprecated Patterns in Code

```r
# util.R:644 - deprecated NSE
dplyr::select_(
  quote(studentid),
  subgroup_name
)

# Should be:
dplyr::select(
  studentid,
  all_of(subgroup_name)
)
```

## 7. S3 Class Implementation Review

### mapvizieR Object Structure

```r
# Current structure (mapvizieR_object.R)
class(mapviz) <- c("mapvizieR", class(mapviz))  # Correct
class(mapviz$cdf) <- c("mapvizieR_cdf", class(mapviz$cdf))  # OK
class(mapviz$growth_df) <- c("mapvizieR_growth", class(mapviz$growth_df))  # OK
```

### Issues

1. **No validation on object access**: Anyone can modify internals
2. **No `validate_mapvizieR()` function**: Should check integrity
3. **print method** could be more informative
4. **summary method** exists but outputs could be richer

### Recommendation
Add:
- `validate_mapvizieR()` exported function
- `[.mapvizieR` and `[[.mapvizieR` methods for safer access
- More robust constructor with input validation

## 8. Error Handling Patterns

### Current State

1. **Using `ensurer` package** (ARCHIVED on CRAN!):
   ```r
   ensurer::ensure_that(...)
   ensurer::ensures_that(...)
   ```

2. **Inconsistent error messages**:
   - Some use `stop()` with message
   - Some use `stopifnot()` (cryptic errors)
   - Some use `assertthat::assert_that()`

### Recommendations

1. Replace `ensurer` with either:
   - `rlang::abort()` with classed conditions
   - `cli::cli_abort()` for pretty errors

2. Standardize on one validation approach:
   - `assertthat` is fine but consider `rlang` for modern approach

## 9. Input Validation on Exported Functions

### Functions Lacking Input Validation

| Function | Missing Validation |
|----------|-------------------|
| `becca_plot()` | measurementscale type check |
| `haid_plot()` | date/year format validation |
| `galloping_elephants()` | entry_grade_seasons bounds |
| `goalbar()` | color vector length check |

### Recommended Validation Pattern

```r
# Add to each exported function
if (!is.character(measurementscale) || length(measurementscale) != 1) {
 cli::cli_abort("{.arg measurementscale} must be a single string")
}
```

## 10. ggplot2 Usage Patterns (Deprecations)

### CRITICAL: Deprecated ggplot2 Syntax

| Deprecated | Replacement | Files |
|------------|-------------|-------|
| `aes_string()` | `aes()` with `.data[[var]]` | Not found (good!) |
| `size` in lines | `linewidth` | quealy_subgroups.R:476 |
| `panel.margin` | `panel.spacing` | quealy_subgroups.R:546 |
| `environment = .e` in ggplot | Remove (deprecated) | haid_plot.R:226, quealy_subgroups.R:467 |

### Specific Fixes Needed

```r
# quealy_subgroups.R:476 - DEPRECATED
size = 1.25  # in annotate() for lines

# Should check if this is for lines or points
# If lines: linewidth = 1.25

# quealy_subgroups.R:546 - DEPRECATED
panel.margin = grid::unit(0, "lines")

# Should be:
panel.spacing = unit(0, "lines")
```

## Summary: Priority Fixes

### Priority 1 (Breaking)
1. Replace `ensurer` package (archived on CRAN)
2. Update deprecated dplyr verbs (`summarize_`, `group_by_`, `select_`)
3. Fix ggplot2 deprecations (`panel.margin`, `size` for lines)

### Priority 2 (High)
1. Refactor `haid_plot()` into smaller functions
2. Create centralized theme and color scales
3. Standardize error handling

### Priority 3 (Medium)
1. Add input validation to all exported functions
2. Improve documentation with runnable examples
3. Address magic numbers

### Priority 4 (Low)
1. Resolve naming inconsistencies
2. Add more informative print/summary methods
