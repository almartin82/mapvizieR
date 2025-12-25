# mapvizieR Tests

This directory contains the test suite for the mapvizieR package.

## Test Organization

### Unit Tests (`testthat/`)

The main test suite uses the `testthat` framework and includes:

- **Data preparation tests**: Validate CDF, roster, and growth data processing
- **Plot function tests**: Verify plot generation and structure
- **Calculation tests**: Ensure accuracy of growth metrics and statistics
- **Utility function tests**: Test helper functions and data transformations

### Visual Regression Tests (`testthat/test-visual-plots.R`)

Visual regression tests use the `vdiffr` package to detect unintended changes in plot appearance:

- **becca_plot**: Quartile performance charts
- **haid_plot**: Waterfall-rainbow-arrow charts
- **growth_histogram**: Student growth percentile distributions
- **student_npr_history_plot**: NPR history small multiples

See `testthat/visual-tests-guide.md` for detailed documentation.

## Running Tests

### Run all tests

```r
# From R console
devtools::test()

# From command line
R CMD check .
```

### Run specific test files

```r
# Run just visual tests
devtools::test(filter = "visual-plots")

# Run a specific test file
testthat::test_file("tests/testthat/test_becca.R")
```

### Run visual tests with helper script

```bash
Rscript tests/run_visual_tests.R
```

## Test Data

Test data is set up in `testthat/helper_constants.R` which runs before all tests. This includes:

- `mapviz`: A complete mapvizieR object with example data
- `cdf`, `roster`, `growth_df`: Individual data frames
- `studentids_*`: Various student ID vectors for different test scenarios

Example data comes from:
- `ex_CombinedAssessmentResults`: Sample MAP assessment data
- `ex_CombinedStudentsBySchool`: Sample roster data

## Test Coverage

To check test coverage:

```r
# Install covr if needed
install.packages("covr")

# Run coverage report
covr::package_coverage()

# Interactive coverage report
covr::report()
```

## Adding New Tests

### Adding a standard test

1. Create or update a file: `tests/testthat/test_function_name.R`
2. Follow existing patterns (see other test files)
3. Use test data from `helper_constants.R`
4. Include edge cases and error conditions

### Adding a visual test

1. Open `tests/testthat/test-visual-plots.R`
2. Add a new `test_that()` block
3. Follow the vdiffr pattern (see existing tests)
4. Run and accept the initial snapshot

## Continuous Integration

Tests run automatically on:
- Pull requests
- Main branch commits
- CRAN submissions (subset of tests)

Note: Visual tests are skipped on CRAN to avoid platform-specific rendering differences.

## Troubleshooting

### Tests fail locally but pass in CI

- Check for platform-specific differences
- Verify you have all suggested packages installed
- Ensure test data files are present

### Visual tests always fail

- Font rendering differences between platforms
- Update snapshots if changes are intentional: `testthat::snapshot_accept()`
- Review changes carefully: `vdiffr::manage_cases()`

### Missing test data

- Ensure package data is properly loaded
- Check that `helper_constants.R` runs successfully
- Verify example data is available in package

## Resources

- [testthat documentation](https://testthat.r-lib.org/)
- [vdiffr documentation](https://vdiffr.r-lib.org/)
- [R Packages testing chapter](https://r-pkgs.org/testing-basics.html)
