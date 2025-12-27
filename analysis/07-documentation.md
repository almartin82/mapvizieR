# Documentation Analysis - mapvizieR

## Executive Summary

Documentation exists but is outdated and incomplete. The README is functional but needs updating, vignettes may have build issues, and there's no pkgdown site configuration. Many exported functions lack working examples.

## 1. README.md Assessment

### Current State

**Location**: `/readme.md` (lowercase - should be `README.md`)

**Content Assessment**:

| Section | Status | Notes |
|---------|--------|-------|
| Package description | Good | Clear purpose statement |
| Badges | Stale | Codecov badge may be broken |
| Installation | Missing! | No installation instructions |
| Usage example | Missing! | No quick start |
| Function overview | Basic | Lists main functions |
| Contributing | Basic | References lintr |
| License | Missing | Not mentioned |

### Issues

1. **No installation instructions**:
```markdown
# Missing section like:
## Installation

```r
# Install from GitHub
devtools::install_github("almartin82/mapvizieR")
```
```

2. **No quick start example**:
```markdown
# Should have:
## Quick Start

```r
library(mapvizieR)

# Load sample data
data(ex_CombinedAssessmentResults)
data(ex_CombinedStudentsBySchool)

# Create mapvizieR object
mv <- mapvizieR(
  cdf = ex_CombinedAssessmentResults,
  roster = ex_CombinedStudentsBySchool
)

# Create a visualization
becca_plot(mv, unique(mv$roster$studentid), "Reading")
```
```

3. **Broken/outdated badges**:
   - Codecov badge may not be working (wercker CI is dead)
   - No R-CMD-check badge

4. **No plot gallery**:
   - README should show example outputs
   - Screenshots/images of key visualizations

### Recommended README Structure

```markdown
# mapvizieR

Visualization and analysis tools for NWEA MAP assessment data.

[![R-CMD-check](badge)](link)
[![codecov](badge)](link)

## Installation

## Quick Start

## Key Visualizations
### becca_plot
![becca_plot example](man/figures/becca_plot.png)

### haid_plot
![haid_plot example](man/figures/haid_plot.png)

## Documentation

## Contributing

## License
```

## 2. Roxygen2 Documentation

### Coverage Summary

| Category | Total Functions | Documented | With Examples | Examples Run |
|----------|----------------|------------|---------------|--------------|
| Visualization | ~20 | ~18 | ~5 | ~2 |
| Data Prep | ~25 | ~22 | ~10 | ~5 |
| Utilities | ~40 | ~30 | ~8 | ~3 |
| Object/Class | ~10 | ~8 | ~4 | ~2 |

### Functions Missing Documentation

From NAMESPACE exports that may lack complete docs:

1. **No @description or vague**:
   - `h_var()`
   - `grob_justifier()`
   - `peek()`

2. **No @param for all parameters**:
   - Several functions have incomplete parameter docs

3. **No @return**:
   - Multiple functions lack return value documentation

4. **Missing @export tag** (internal but exported):
   - Several utility functions

### @examples Status

**Wrapped in \dontrun{}**:
Most visualization functions use `\dontrun{}` because they require the mapvizieR object:

```r
#' @examples
#' \dontrun{
#'   mv <- mapvizieR(ex_CombinedAssessmentResults, ex_CombinedStudentsBySchool)
#'   becca_plot(mv, studentids, "Reading")
#' }
```

**Problem**: Users can't run examples easily.

**Solution**: Use `\donttest{}` instead or ensure examples are runnable:

```r
#' @examples
#' data(ex_CombinedAssessmentResults)
#' data(ex_CombinedStudentsBySchool)
#' mv <- mapvizieR(ex_CombinedAssessmentResults, ex_CombinedStudentsBySchool)
#' studentids <- unique(mv$roster$studentid)[1:50]
#' becca_plot(mv, studentids, "Reading")
```

### Documentation Quality Issues

1. **Typos**:
   - `mapvizier` vs `mapvizieR` inconsistency
   - `performonce` should be `performance` (becca_plot.R)

2. **Unclear descriptions**:
   - Some @description tags are copy-pasted

3. **Missing cross-references**:
   - @seealso rarely used
   - @family tags not used for grouping

## 3. Vignettes Assessment

### Current Vignettes

```
vignettes/
├── baseline_goals.Rmd      # 7909 bytes
├── mapvizieR_object.Rmd    # 5688 bytes - Core documentation
├── missing_stu.Rmd         # 126 bytes - Stub?
├── ny_proficiency.Rmd      # 22835 bytes
├── nys.Rmd                 # 1251 bytes
├── report_dispatcher.Rmd   # 5754 bytes
└── templates.Rmd           # 1343 bytes
```

### Issue #307: Vignettes Built Incorrectly

From GitHub issues: "vignettes are wrong because I didn't use devtools::use_vignette"

**Potential Problems**:
1. May not build during package installation
2. YAML front matter may be incorrect
3. Missing or incorrect VignetteBuilder in DESCRIPTION

### Vignette Content Assessment

| Vignette | Purpose | Status | Needs Update |
|----------|---------|--------|--------------|
| mapvizieR_object.Rmd | Core concepts | Good | Yes - syntax |
| baseline_goals.Rmd | Goal setting | OK | Maybe |
| report_dispatcher.Rmd | Report generation | OK | Yes |
| ny_proficiency.Rmd | NY state specific | Specific | Maybe |
| nys.Rmd | NY state | Minimal | Yes |
| templates.Rmd | Report templates | Minimal | Yes |
| missing_stu.Rmd | Unknown | Stub (126 bytes!) | Remove or complete |

### Vignette Build Verification

Need to run:
```r
devtools::build_vignettes()
```

And verify all vignettes build without errors.

### Recommended Vignette Structure

```
vignettes/
├── 01-getting-started.Rmd     # Installation, basic usage
├── 02-mapvizier-object.Rmd    # Object structure, creation
├── 03-visualizations.Rmd      # All plot types with examples
├── 04-growth-analysis.Rmd     # CGP, growth calculations
├── 05-report-generation.Rmd   # Report dispatcher, templates
└── 06-customization.Rmd       # Themes, colors, extending
```

## 4. NEWS.md Assessment

### Current State

Last entry: mapvizieR 0.3.6 (undated, but ~2017)

```markdown
# mapvizieR 0.3.6
* `summary()` methods for `growth_df` and `cdf` now respect...
* we use the new `janitor` package...
```

### Issues

1. **No recent updates** - Many changes not documented
2. **No dates** - Entries should have release dates
3. **Inconsistent format** - Some entries more detailed than others

### Recommended Format

```markdown
# mapvizieR 0.4.0 (2025-XX-XX)

## Breaking Changes
* Updated to ggplot2 3.4+ compatibility
* Removed ensurer dependency (archived on CRAN)
* Default norms changed from 2015 to 2020

## New Features
* Added `theme_mapvizier()` for consistent styling
* Added visual regression tests

## Bug Fixes
* Fixed deprecation warnings from dplyr 1.0+
* Fixed panel.margin deprecation in plots

## Deprecated
* `norms = 2011` will be removed in future version
```

## 5. pkgdown Configuration

### Current State

**No pkgdown configuration exists!**

No files found:
- `_pkgdown.yml`
- `pkgdown/` directory

### Required Setup

1. **Create `_pkgdown.yml`**:

```yaml
url: https://almartin82.github.io/mapvizieR

template:
  bootstrap: 5
  bootswatch: flatly

navbar:
  structure:
    left: [intro, reference, articles, tutorials, news]
    right: [search, github]

reference:
- title: Create mapvizieR Object
  contents:
  - mapvizieR
  - is.mapvizieR

- title: Group Visualizations
  contents:
  - becca_plot
  - galloping_elephants

- title: Growth Visualizations
  contents:
  - haid_plot
  - quealy_subgroups
  - goalbar
  - growth_histogram

- title: Data Preparation
  contents:
  - prep_cdf_long
  - prep_roster
  - read_cdf

- title: Utilities
  contents:
  - starts_with("mv_")

articles:
- title: Getting Started
  contents:
  - getting-started
  - mapvizieR-object

- title: Visualizations
  contents:
  - visualizations

- title: Advanced Topics
  contents:
  - report-generation
  - customization
```

2. **Create GitHub Action for deployment** (covered in CI/CD report)

3. **Generate plot images for documentation**

## 6. DESCRIPTION File Issues

### Current DESCRIPTION

```
Package: mapvizieR
Type: Package
Title: Visualization and Data Analysis tools for NWEA MAP student data
Version: 0.3.7
Date: 2015-01-14      # VERY outdated!
Authors@R: c(...)
Description: mapzivieR is a suite...  # Typo: mapzivieR
```

### Issues

1. **Date is from 2015** - Should reflect actual release
2. **Typo in Description**: "mapzivieR" should be "mapvizieR"
3. **Missing URL field**:
```r
URL: https://github.com/almartin82/mapvizieR,
     https://almartin82.github.io/mapvizieR
```

4. **Missing BugReports field**:
```r
BugReports: https://github.com/almartin82/mapvizieR/issues
```

5. **Outdated Authors@R format** - Format is OK but could add ORCID

### Recommended DESCRIPTION Updates

```r
Package: mapvizieR
Title: Visualization and Data Analysis Tools for NWEA MAP Student Data
Version: 0.4.0
Authors@R: c(
    person("Andrew", "Martin", , "almartin@gmail.com", role = c("aut", "cre")),
    person("Chris", "Haid", , "chaid@kippchicago.org", role = "aut")
  )
Description: A suite of analytic, visualization, and reporting tools for
    NWEA MAP Data. Provides functions for creating visualizations of
    student growth, cohort status, and goal attainment.
License: file LICENSE
URL: https://github.com/almartin82/mapvizieR,
    https://almartin82.github.io/mapvizieR
BugReports: https://github.com/almartin82/mapvizieR/issues
```

## 7. GitHub Wiki

### Current State

Need to check: https://github.com/almartin82/mapvizieR/wiki

### Recommendation

If wiki exists:
- Review for outdated content
- Consider migrating to pkgdown articles
- Keep wiki for community contributions

If wiki doesn't exist:
- Don't create one; use pkgdown instead

## 8. Report Templates Documentation

### Current State

```
inst/report_templates/
└── slim_template.docx    # Single Word template

vignettes/
├── report_dispatcher.Rmd # Documents dispatcher
└── templates.Rmd         # Template documentation (minimal)
```

### Issues

1. **Only one template** - Limited options
2. **templates.Rmd is minimal** - Only 1343 bytes
3. **No RMarkdown templates** - Could add parameterized reports

### Recommendations

1. **Expand template options**:
```
inst/report_templates/
├── slim_template.docx
├── full_template.docx
├── student_report.Rmd
├── cohort_report.Rmd
└── school_report.Rmd
```

2. **Document template creation**:
   - How to create custom templates
   - Required elements/placeholders
   - Example workflow

3. **Add parameterized RMarkdown**:
```r
# Example parameterized report
---
title: "Student Growth Report"
params:
  mapvizier_obj: NULL
  studentids: NULL
  measurementscale: "Reading"
---
```

## 9. Inline Code Documentation

### Comment Quality

Most complex functions have reasonable inline comments:

```r
# haid_plot.R
#make a psuedo-axis by ordering based on one variable
#need to allow for holdovers
#make a fake ranking value that is quartile in thousands value, plus rit
```

### Issues

1. **Inconsistent comment style**:
   - Some use `#comment` (no space)
   - Some use `# comment` (with space)

2. **Outdated comments**:
   - Some reference old behavior

3. **TODO comments not tracked**:
   ```r
   # mapvizieR_object.R:70-72
   #TODO: also return a goal/strand df
   #TODO: add some analytics about matched/unmatched kids
   ```

### Recommendation

Create issues from TODO comments:
- Issue for goal/strand df
- Issue for matched/unmatched analytics

## 10. Documentation Modernization Priorities

### Priority 1 (Critical)

1. **Fix README.md**:
   - Add installation instructions
   - Add quick start example
   - Update badges
   - Add plot gallery

2. **Verify vignettes build**:
   - Run `devtools::build_vignettes()`
   - Fix any errors
   - Remove or complete stub vignettes

3. **Update DESCRIPTION**:
   - Fix typo
   - Update date
   - Add URL/BugReports

### Priority 2 (High)

4. **Add pkgdown configuration**:
   - Create `_pkgdown.yml`
   - Organize reference into sections
   - Set up GitHub Pages deployment

5. **Add working @examples**:
   - At minimum for all visualization functions
   - Replace `\dontrun{}` where possible

6. **Update NEWS.md**:
   - Document recent/upcoming changes
   - Add dates to entries

### Priority 3 (Medium)

7. **Improve function documentation**:
   - Add missing @return tags
   - Add @seealso cross-references
   - Use @family for grouping

8. **Expand vignettes**:
   - Getting started guide
   - Visualization gallery
   - Customization guide

### Priority 4 (Low)

9. **Documentation polish**:
   - Consistent comment style
   - Fix typos
   - Resolve TODO comments

10. **Report template docs**:
    - Document template creation
    - Add example templates

## Summary: Documentation Status

| Component | Current State | Target State | Effort |
|-----------|--------------|--------------|--------|
| README | Incomplete | Full with examples | Medium |
| Roxygen | Mostly complete | Complete with examples | Medium |
| Vignettes | May not build | Building, current | High |
| pkgdown | Missing | Configured, deployed | Medium |
| DESCRIPTION | Outdated | Current | Low |
| NEWS | Stale | Up to date | Low |
