# Test Coverage Improvement Strategy

## Current State

| Metric | Value |
|--------|-------|
| R Source Files | 68 |
| Test Files | 55 |
| Tests Passing | 618 |
| Tests Failing | 102 |
| Tests Skipped | 3 |
| Pass Rate | 85.5% |

## Coverage Gap Analysis

### Files Without Tests (15 files)

**High Priority (Exported functions, core functionality):**
1. `util.R` - 869 lines, 30+ utility functions
2. `goals_and_projections.R` - Goal calculations
3. `alt_cohort_cgp_hist.R` - Alternative CGP histograms
4. `mv_summary_plots.R` - Summary longitudinal plots
5. `strand_summary_plot.R` - Strand summary visualization
6. `growth_status.R` - Growth status scatter plots

**Medium Priority (Supporting functions):**
7. `cgp_table.R` - CGP display tables
8. `growth_status_class.R` - Class-level plots

**Low Priority (Data documentation, minimal code):**
9. `norm_data.R` - Norm dataset documentation
10. `ex_data.R` - Example data documentation
11. `globals.R` - Global variable declarations
12. `mapvizieR-package.R` - Package documentation
13. `kipp_report_card.R` - Color palette
14. `linking_data.R` - Data documentation
15. `school_growth_norms.R` - Data documentation

## Test Implementation Strategy

### Phase 1: Fix Failing Tests (Priority)

Before adding new tests, fix the 102 failing tests:
- Most failures are due to namespace issues (`lead()`, `lag()`, `n()`)
- Some are due to changed data structures after dplyr updates
- Some are deprecated test patterns (`expect_is`)

### Phase 2: Add Tests for High-Priority Files

#### 1. util.R Tests
```r
# Test key utility functions:
test_that("kipp_quartile returns correct quartiles", {
  expect_equal(kipp_quartile(25), 1)
  expect_equal(kipp_quartile(50), 2)
  expect_equal(kipp_quartile(75), 3)
  expect_equal(kipp_quartile(99), 4)
})

test_that("extract_academic_year works correctly", {
  expect_equal(extract_academic_year("Fall 2023-2024"), 2023)
  expect_equal(extract_academic_year("Spring 2023-2024"), 2024)
})

test_that("mv_limit_cdf filters correctly", {
  # Test with mapviz object
})
```

#### 2. goals_and_projections.R Tests
```r
test_that("goal_kipp_tiered returns correct growth targets", {
  # Test tiered goals for different percentiles
})

test_that("add_accelerated_growth adds correct columns", {
  # Verify new columns are added
  # Check calculation accuracy
})
```

#### 3. growth_status.R Tests
```r
test_that("growth_status_scatter produces valid plot", {
  p <- growth_status_scatter(mapviz, studentids, measurementscale)
  expect_s3_class(p, "ggplot")
})
```

### Phase 3: Visual Regression Tests

For plotting functions, add vdiffr tests:
- `growth_status_scatter`
- `alt_cohort_cgp_hist_plot`
- `summary_long_plot`
- `goal_strand_summary_plot`

### Phase 4: Data Validation Tests

For data documentation files:
```r
test_that("example data loads correctly", {
  expect_true(exists("ex_CombinedAssessmentResults"))
  expect_s3_class(ex_CombinedAssessmentResults, "data.frame")
  expect_true(nrow(ex_CombinedAssessmentResults) > 0)
})

test_that("norm data has expected structure", {
  expect_true(exists("student_status_norms_2015"))
  expect_true("grade" %in% names(student_status_norms_2015))
})
```

## Implementation Priority

1. **Immediate**: Fix namespace issues in existing tests
2. **High**: Add tests for `goals_and_projections.R`
3. **High**: Add tests for `growth_status.R`
4. **Medium**: Add tests for `mv_summary_plots.R`
5. **Medium**: Add tests for `alt_cohort_cgp_hist.R`
6. **Lower**: Data validation tests

## Expected Improvement

After implementation:
- Pass rate: 95%+
- File coverage: 90%+
- All exported functions tested
- Visual regression tests for key plots

## Testing Patterns

### Standard Test Pattern
```r
test_that("function_name handles valid input", {
  result <- function_name(valid_input)
  expect_s3_class(result, "expected_class")
  expect_true(condition)
})

test_that("function_name handles edge cases", {
  expect_error(function_name(NULL))
  expect_error(function_name(empty_df))
})
```

### Visual Test Pattern
```r
test_that("plot_function visual regression", {
  skip_on_cran()
  skip_if_not_installed("vdiffr")

  p <- plot_function(args)
  vdiffr::expect_doppelganger("plot_name", p)
})
```
