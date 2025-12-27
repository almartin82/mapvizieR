# Contributing to mapvizieR

Thank you for considering contributing to mapvizieR! This document
provides guidelines and information for contributors.

## Code of Conduct

Please note that mapvizieR follows a Contributor Code of Conduct. By
participating in this project you agree to abide by its terms.

## How to Contribute

### Reporting Bugs

Before creating a bug report, please check the existing issues to avoid
duplicates. When you create a bug report, include as much detail as
possible:

- **R version** and **package versions** (use
  [`sessionInfo()`](https://rdrr.io/r/utils/sessionInfo.html))
- **Operating system**
- **Minimal reproducible example** demonstrating the bug
- **Expected behavior** vs **actual behavior**
- Any **error messages** or **warnings**

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When suggesting an
enhancement:

- Use a **clear and descriptive title**
- Provide a **step-by-step description** of the suggested enhancement
- Explain **why this enhancement would be useful**
- Include **examples** if applicable

### Pull Requests

1.  **Fork the repository** and create your branch from `master`
2.  **Make your changes** following the coding standards below
3.  **Add or update tests** as needed
4.  **Update documentation** if you’re changing functionality
5.  **Run checks** with `devtools::check()` before submitting
6.  **Submit a pull request** with a clear description of changes

## Development Setup

``` r
# Clone your fork
git clone https://github.com/YOUR_USERNAME/mapvizieR.git
cd mapvizieR

# Install development dependencies
install.packages("devtools")
devtools::install_deps(dependencies = TRUE)

# Run tests
devtools::test()

# Run R CMD check
devtools::check()

# Build documentation
devtools::document()
```

## Coding Standards

### Style Guide

mapvizieR follows the [tidyverse style
guide](https://style.tidyverse.org/) with some adaptations:

- Use `snake_case` for function and variable names
- Use `camelCase` for mapvizieR-specific data column names (matching
  NWEA conventions)
- Maximum line length: 120 characters
- Use `#'` for roxygen2 documentation

### Documentation

- All exported functions must have roxygen2 documentation
- Include `@param`, `@return`, and `@examples` for all exported
  functions
- Use `@inheritParams` when appropriate to reduce duplication

### Testing

- Write tests for all new functionality using testthat
- Place tests in `tests/testthat/`
- Name test files as `test-*.R`
- Aim for high test coverage on new code

### Commit Messages

- Use the present tense (“Add feature” not “Added feature”)
- Use the imperative mood (“Move cursor to…” not “Moves cursor to…”)
- Reference issues and pull requests when relevant

## Package Architecture

### Core Data Structures

- **cdf**: Comprehensive Data File from NWEA MAP
- **roster**: Student demographic and enrollment data
- **growth_df**: Growth data frame with term-to-term growth calculations
- **mapvizieR object**: S3 class combining cdf, roster, and growth_df

### Key Modules

- `R/cdf_prep.R`: CDF data preparation and validation
- `R/cgp_prep.R`: Conditional growth percentile calculations
- `R/mapvizieR_object.R`: mapvizieR object constructor
- `R/util.R`: Utility functions and validation helpers
- `R/theme_mapvizier.R`: Theming and color palettes

### Visualization Naming Conventions

Plot functions typically follow the pattern: - `[name]_plot()` for
standalone plots - `[name]_table()` for table-format outputs -
`[name]_histogram()` for histogram visualizations

## Getting Help

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Package Documentation**: <https://almartin82.github.io/mapvizieR>

## Recognition

Contributors will be recognized in the package’s `DESCRIPTION` file and
in release notes. Thank you for helping improve mapvizieR!
