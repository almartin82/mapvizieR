# Testing Analysis - mapvizieR

## Executive Summary

The package has a reasonable test suite with 54 test files covering most functionality. However, test coverage estimation suggests gaps, and the tests need updating to testthat 3rd edition. Visual regression testing is notably absent for a visualization-focused package.

## 1. Current Test Coverage

### Test File Inventory

```
tests/
├── testthat.R               # Test runner
└── testthat/
    ├── helper_constants.R   # Shared test fixtures
    └── 54 test files        # One per major functionality
```

### Test Files by Category

| Category | Files | Functions Tested |
|----------|-------|------------------|
| Visualization | 15 | becca, elephants, haid, quealy, goalbar, etc. |
| Data Prep | 12 | cdf_prep, roster_prep, growth_df, cgp, norms |
| Object/Class | 5 | mapvizier_object, summary, dplyr_wrappers |
| Utilities | 10 | utils, filter, linking, estimate_RIT, etc. |
| Reports | 5 | report_dispatcher, two_pager, fall_goals, etc. |
| Other | 7 | Various specific functionality |

### Test File List

```
test_add_accelerated_goals.R     test_mapvizier_object.R
test_amys_lists.R                test_mv_filter.R
test_baseline_calc.R             test_nearest_RIT.R
test_becca.R                     test_norm_space.R
test_cdf_check.R                 test_norms_prep.R
test_cdf_dedupe.R                test_plot_util.R
test_cdf_prep.R                  test_quealy_subgroups.R
test_cdf_type_detection.R        test_report_dispatcher.R
test_cgp_prep.R                  test_roster_check.R
test_cohort_cgp.R                test_roster_prep.R
test_cohort_longitudinal.R       test_roster_to_df.R
test_cohort_status_trace.R       test_schambach_figure.R
test_college_plots.R             test_schambach_table.R
test_dplyr_wrappers.R            test_sgp_histogram.R
test_elephants.R                 test_state_pass.R
test_estimate_RIT.R              test_strand_boxes.R
test_fall_goals_report.R         test_strand_list.R
test_fuzz_test.R                 test_student_npr_history.R
test_goal_strand_plot.R          test_student_npr_two_term.R
test_goalbar.R                   test_summary_mapvizier.R
test_growth_detail_table.R       test_teacher_performance_report.R
test_growth_df_prep.R            test_two_pager.R
test_growth_status_scatter.R     test_utils.R
test_growth_window.R
test_haid_plot.R
test_historic_nth_percentile.R
test_historic_recap_report.R
test_impute_rit.R
test_kipp_typ.R
test_linking.R
test_localization.R
```

## 2. Coverage Estimation

### Exported Functions Without Dedicated Tests

Based on NAMESPACE exports (134 functions) vs test files (54):

**Potentially Untested or Under-tested Functions:**

| Function | Test File | Status |
|----------|-----------|--------|
| `alt_cohort_cgp_hist_plot()` | test_cohort_cgp.R | Likely partial |
| `alt_multi_cohort_cgp_hist_plot()` | test_cohort_cgp.R | Likely partial |
| `build_student_1year_goal_plot()` | test_goal_strand_plot.R | Check coverage |
| `build_student_college_plot()` | test_college_plots.R | Check coverage |
| `bulk_student_*()` functions | Various | Likely partial |
| `cgp_sim()` | None found | Missing |
| `cohort_expectation()` | None found | Missing |
| `grade_levelify_cdf()` | test_cdf_prep.R | Check coverage |
| `report_footer()` | None found | Missing |
| `rit_height_weight_*()` | None found | Missing |
| `template_0*()` functions | None found | Missing |

### Estimated Coverage

Without running actual coverage tools, estimate based on file analysis:
- **Visualization functions**: ~70% covered (basic tests exist, edge cases missing)
- **Data prep functions**: ~80% covered (core logic tested)
- **Utility functions**: ~60% covered (many helpers untested)
- **Report functions**: ~50% covered (complex to test)

**Overall Estimate: 65-70% coverage**

## 3. Test Quality Assessment

### Strengths

1. **Good test fixture**: `helper_constants.R` provides consistent test data
2. **Coverage of core plots**: All major viz functions have test files
3. **Edge case awareness**: Some tests check for edge conditions

### Weaknesses

1. **Shallow tests**: Many tests just check "it runs" without output verification
2. **No visual regression**: Visualization package without visual testing!
3. **Limited edge cases**: Few tests for empty data, single student, etc.
4. **Outdated testthat**: Not using 3rd edition features

### Example: Current Test Quality

```r
# test_becca.R - Example of shallow testing
test_that("becca_plot works", {
  # Just tests that it doesn't error
  p <- becca_plot(mapviz, studentids_ms, "Reading")
  expect_is(p, "ggplot")
})

# Better test would check:
# - Correct number of bars
# - Correct quartile labels
# - Handles empty data gracefully
# - Colors are correct
```

## 4. testthat 3rd Edition Migration

### Current State

The package uses testthat but not 3rd edition features.

### Required Changes

1. **Update testthat.R**:
```r
# Current
library(testthat)
library(mapvizieR)
test_check("mapvizieR")

# 3rd Edition
library(testthat)
library(mapvizieR)
test_check("mapvizieR")
```

2. **Add to DESCRIPTION**:
```r
Config/testthat/edition: 3
```

3. **Update test patterns**:
```r
# OLD (2nd edition)
context("Testing becca_plot")

# NEW (3rd edition)
# context() is deprecated - remove or use describe()
```

### 3rd Edition Benefits

- Parallel test execution
- Better error messages
- Snapshot testing support
- Improved test organization

## 5. Visual Regression Testing (vdiffr)

### Current State

**No visual regression tests exist** - This is a critical gap for a visualization package!

Issue #306 specifically requests: "consider vdiffr for visualization tests"

### Recommended Implementation

1. **Add vdiffr to Suggests**

2. **Create visual tests for each plot**:

```r
# tests/testthat/test-becca_visual.R
test_that("becca_plot renders correctly", {
  skip_if_not_installed("vdiffr")

  p <- becca_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_ms,
    measurementscale = "Reading"
  )

  vdiffr::expect_doppelganger("becca-plot-basic", p)
})

test_that("becca_plot handles small cohorts", {
  skip_if_not_installed("vdiffr")

  small_ids <- sample(studentids_ms, 10)
  p <- becca_plot(mapviz, small_ids, "Reading")

  vdiffr::expect_doppelganger("becca-plot-small", p)
})
```

3. **Priority plots for visual testing**:
   - `becca_plot()` - Core visualization
   - `galloping_elephants()` - Density plot
   - `haid_plot()` - Complex waterfall
   - `quealy_subgroups()` - Multi-panel
   - `goalbar()` - Stacked bar

### vdiffr Workflow

1. First run creates reference SVGs in `tests/testthat/_snaps/`
2. Future runs compare against references
3. `testthat::snapshot_review()` to review changes
4. CI integration via GitHub Actions

## 6. Test Organization and Naming

### Current Pattern

```
test_<functionality>.R
```

Examples:
- `test_becca.R` - Tests becca_plot
- `test_elephants.R` - Tests galloping_elephants
- `test_cdf_prep.R` - Tests CDF preparation

### Issues

1. **Inconsistent naming**: `test_elephants.R` should be `test_galloping_elephants.R`
2. **Bundled tests**: Some files test multiple unrelated functions
3. **No clear categories**: Hard to find tests for specific functionality

### Recommended Structure

```
tests/testthat/
├── helper_constants.R
├── helper_mock_data.R          # Additional test helpers
├── setup.R                     # Test setup (3e style)
│
├── test-data-prep/
│   ├── test-cdf_prep.R
│   ├── test-roster_prep.R
│   └── test-growth_df_prep.R
│
├── test-visualization/
│   ├── test-becca_plot.R
│   ├── test-galloping_elephants.R
│   ├── test-haid_plot.R
│   └── test-quealy_subgroups.R
│
├── test-object/
│   ├── test-mapvizieR_object.R
│   └── test-mapvizieR_summary.R
│
└── test-visual/                 # vdiffr visual tests
    ├── test-visual-becca.R
    └── test-visual-haid.R
```

## 7. Sample Data Adequacy

### Current Test Data

From `helper_constants.R`:
- Uses `ex_CombinedAssessmentResults`
- Uses `ex_CombinedStudentsBySchool`
- Creates `mapviz` object for tests

### Assessment

| Aspect | Status | Notes |
|--------|--------|-------|
| Student count | Good | Sufficient for testing |
| Grade range | Good | K-12 represented |
| Subject coverage | Good | Reading, Math |
| Term coverage | Good | Multiple years |
| Edge cases | Missing | No single-student data |
| Error cases | Missing | No malformed data |

### Recommended Additional Test Data

1. **Edge case datasets**:
   - Single student roster
   - Empty CDF
   - CDF with all NA percentiles
   - Roster with missing grades

2. **Error case datasets**:
   - Malformed termname
   - Invalid studentid formats
   - Duplicate entries

## 8. mapvizieR Object Testing

### Current Coverage

`test_mapvizier_object.R` tests:
- Object creation
- Basic validation
- print method

### Missing Tests

1. **Object integrity after operations**:
```r
test_that("filtering maintains object integrity", {
  filtered_mv <- mv_filter(mapviz, grade = 5)
  expect_true(is.mapvizieR(filtered_mv))
  # Check all components still valid
})
```

2. **Object with edge case data**:
```r
test_that("handles minimal data", {
  minimal_cdf <- ex_CombinedAssessmentResults[1:10, ]
  # Should create or error gracefully
})
```

3. **Component access**:
```r
test_that("cdf access works", {
  cdf <- mapviz$cdf
  expect_s3_class(cdf, "mapvizieR_cdf")
})
```

## 9. Plot Output Verification

### Current State

Most plot tests only verify:
```r
expect_is(p, "ggplot")  # or expect_s3_class(p, "ggplot")
```

### Recommended Improvements

1. **Check plot data**:
```r
test_that("becca_plot has correct data", {
  p <- becca_plot(mapviz, studentids_ms, "Reading")

  # Check layers exist
  expect_length(p$layers, expected_layers)

  # Check data in plot
  plot_data <- ggplot2::ggplot_build(p)$data
  expect_true(all(c("x", "y") %in% names(plot_data[[1]])))
})
```

2. **Check aesthetic mappings**:
```r
test_that("becca_plot uses correct aesthetics", {
  p <- becca_plot(mapviz, studentids_ms, "Reading")

  # Check fill aesthetic exists
  expect_true("fill" %in% names(p$mapping))
})
```

3. **Check scales and labels**:
```r
test_that("becca_plot has correct labels", {
  p <- becca_plot(mapviz, studentids_ms, "Reading")

  expect_equal(p$labels$x, "Grade Level")
  expect_equal(p$labels$y, "Percentage of Cohort")
})
```

## 10. Missing Integration Tests

### Currently Missing

1. **End-to-end workflow tests**:
```r
test_that("complete workflow works", {
  # Load raw data
  cdf <- read_cdf("path/to/cdf")
  roster <- read.csv("path/to/roster")

  # Create object
  mv <- mapvizieR(cdf, roster)

  # Generate reports
  expect_silent(becca_plot(mv, unique(roster$studentid), "Reading"))
  expect_silent(haid_plot(mv, ...))
})
```

2. **Report generation tests**:
```r
test_that("report_dispatcher generates output", {
  result <- report_dispatcher(mapviz, ...)
  expect_true(file.exists(result))
})
```

3. **Performance regression tests**:
```r
test_that("cdf_to_cgp completes in reasonable time", {
  skip_on_cran()

  time <- system.time({
    result <- cdf_to_cgp(large_cdf)
  })

  expect_lt(time["elapsed"], 30)  # Should complete in < 30s
})
```

## Summary: Testing Priorities

### Priority 1 (Critical)
1. Add vdiffr for visual regression testing of core plots
2. Migrate to testthat 3rd edition
3. Add tests for edge cases (empty data, single student)

### Priority 2 (High)
1. Increase coverage of utility functions
2. Add mapvizieR object integrity tests
3. Improve plot data verification

### Priority 3 (Medium)
1. Add integration tests for workflows
2. Create error case test data
3. Organize test files by category

### Priority 4 (Low)
1. Add performance regression tests
2. Improve test naming consistency
3. Add more detailed documentation for test fixtures

## Recommended Test Updates

### New Test Files to Create

```r
# tests/testthat/test-visual-becca.R
# tests/testthat/test-visual-haid.R
# tests/testthat/test-visual-elephants.R
# tests/testthat/test-edge-cases.R
# tests/testthat/test-mapvizieR-validation.R
# tests/testthat/test-integration-workflow.R
```

### Updates to DESCRIPTION

```r
Suggests:
    testthat (>= 3.0.0),
    knitr,
    vdiffr (>= 1.0.0),
    rmarkdown
Config/testthat/edition: 3
```
