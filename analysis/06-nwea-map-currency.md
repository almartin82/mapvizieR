# NWEA MAP Data Currency Analysis - mapvizieR

## Executive Summary

This is a **CRITICAL** analysis for maintaining the package's relevance. The package's norm tables appear to be from the 2015 NWEA norm study, which has been superseded. NWEA released updated norms in 2020. The expected data format should be verified against current NWEA export formats.

## 1. Expected Input Data Format

### Assessment Results (CDF) Format

Based on `cdf_prep.R` and sample data, the expected format includes:

```r
# Required columns (from check_cdf_long)
required_cols <- c(
  "studentid",           # Student identifier
  "termname",            # e.g., "Fall 2013-2014"
  "measurementscale",    # e.g., "Reading", "Mathematics"
  "testritscore",        # RIT score
  "testpercentile",      # National percentile
  "testquartile"         # Quartile (1-4)
  # ... additional columns
)
```

### Roster Format

```r
# Required columns (from check_roster)
required_cols <- c(
  "studentid",
  "termname",
  "grade",
  "schoolname"
  # ... additional demographic columns
)
```

### Current Sample Data

The package includes sample data in `data/`:
- `ex_CombinedAssessmentResults` - CDF data
- `ex_CombinedStudentsBySchool` - Roster data

Sample data in `data-raw/` includes files from 2012-2013, suggesting the data model may be outdated.

## 2. NWEA Data Export Format Changes

### Known Format Evolution

| Era | Format | Status in Package |
|-----|--------|-------------------|
| Pre-2015 | Client-based exports | Supported |
| 2015-2020 | MAP Growth exports | Supported (likely) |
| 2020+ | MAP Growth Platform | Unknown |

### Potential Format Changes to Verify

1. **Column naming conventions** - NWEA may have changed column names
2. **Date/term formats** - May have evolved
3. **New fields** - Growth measures, goal strands, etc.
4. **Removed fields** - Deprecated metrics

### Action Required

Need to verify against current NWEA documentation:
- https://teach.mapnwea.org/ (requires login)
- https://www.nwea.org/resource-center/

## 3. Norm Tables Currency

### Current Norm Tables in Package

From `data-raw/` and code analysis:

| Norm Study | Files | Status |
|------------|-------|--------|
| 2011 | `student_norms_2011.csv`, `student_norms_2011_dense_extended.csv` | **OUTDATED** |
| 2012 | `SchoolGrowthNorms2012.csv` | **OUTDATED** |
| 2015 | `STU_NORMS2015_GROWTHV2_EXT.csv`, `SchoolGrowthNorms2015.csv` | **OUTDATED** (current in package) |

### NWEA Norm Study History

| Year | Study | Notes |
|------|-------|-------|
| 2011 | Student norms | Original study |
| 2015 | Updated norms | Major update, currently in package |
| 2020 | Latest norms | **NOT in package** |

### Critical Issue: 2020 Norms Missing

NWEA released updated norms in 2020:
- New percentile tables
- Updated growth expectations
- Refined by subject and grade

**Impact**: Users comparing to 2015 norms when 2020 norms are available may have inaccurate growth expectations.

### Code References to Norms

```r
# mapvizieR_object.R:58-62
if (norms == 2015) {
  norms_long <- norms_students_wide_to_long(student_growth_norms_2015)
} else if (norms == 2011) {
  norms_long <- norms_students_wide_to_long(student_growth_norms_2011)
}
```

**Required Update**: Add 2020 norms option.

## 4. RIT Score Interpretation

### Current Handling

The package uses RIT scores correctly for:
- Raw score display
- Percentile mapping
- Growth calculations

### Potential Changes

NWEA has not fundamentally changed RIT score interpretation, but:
1. Scale properties remain stable (Rasch-based)
2. Percentile mappings update with each norm study
3. Growth expectations refined with each study

### Package Compatibility

The core RIT handling should remain compatible, but percentile lookups need the 2020 norms.

## 5. Growth Percentile Calculations

### Current Implementation

From `cgp_prep.R` and related files:

```r
# calc_cgp function signature
calc_cgp(
  measurementscale,
  end_grade,
  growth_window,
  baseline_avg_rit,
  ending_avg_rit,
  norms = 2015  # Default is 2015
)
```

### NWEA CGP Methodology

The Conditional Growth Percentile (CGP) methodology has remained stable, but:
1. The underlying growth norms changed in 2020
2. Growth expectations by grade/subject updated
3. Some calculation refinements may have occurred

### Verification Needed

Compare package CGP output against:
- NWEA's own CGP calculations (from reports)
- 2020 norm study documentation

## 6. New MAP Features Not Supported

### Potentially Missing Features

Based on NWEA's evolution:

| Feature | Status | Priority |
|---------|--------|----------|
| Learning Continuum | Not supported | Medium |
| Instructional Areas | Limited support | Medium |
| Lexile/Quantile linking | Not supported | Low |
| Khan Academy integration | N/A | N/A |
| Universal Screening | Not supported | Low |
| Dyslexia Screener data | Not supported | Low |

### New Data Fields (Potential)

NWEA may now provide:
- `achievement_level` - New proficiency bands
- `projected_proficiency` - State test predictions
- `lexile_score` - For Reading
- `quantile_score` - For Math
- Goal strand detail fields

## 7. Sample Data Currency

### Current Sample Data Age

Files in `data-raw/`:
- `Fall2013AssessmentResults.csv`
- `Spring2012AssessmentResults.csv`
- `Spring2013AssessmentResults.csv`
- `Winter2013AssessmentResults.csv`

**Issue**: Sample data is 10+ years old

### Impact

1. Column names may not match current exports
2. Value formats may have changed
3. Not representative of current grade distributions

### Recommended Action

1. Obtain anonymized current-format data from NWEA or partner
2. Update sample data to match 2024 export format
3. Document expected input format clearly

## 8. Goal-Setting Calculations

### KIPP Tiered Growth

From `util.R`:

```r
tiered_growth_factors <- function(quartile, grade){
  tgrowth <- data.frame(
    grade.type = c(rep(0,4),rep(1,4)),
    quartile = as.factor(rep(1:4, 2)),
    KIPPTieredGrowth = c(1.5,1.5,1.25,1,2,1.75,1.5,1)
  )
  # ...
}
```

### Questions

1. Are KIPP tiered growth factors still current?
2. Do other networks use different goal structures?
3. Should factors be configurable?

### NWEA's Own Goals

NWEA provides goal-setting tools:
- Student projection
- School-level targets
- Pathways to proficiency

The package may want to incorporate or interface with these.

## 9. Recommendations

### Immediate Actions

1. **Obtain 2020 Norms**
   - Contact NWEA for norm tables
   - Add `student_growth_norms_2020` dataset
   - Add `norms = 2020` option to functions

2. **Verify Data Format**
   - Get current CDF export sample from NWEA
   - Update `check_cdf_long()` for any new/changed columns
   - Update sample data

3. **Document Expected Format**
   - Create clear documentation of expected input
   - List required vs optional columns
   - Provide format conversion examples

### Medium-Term Actions

4. **Add 2020 Norm Support**
   - Create `norms_2020.R` with new tables
   - Update `mapvizieR()` constructor
   - Default to 2020 norms

5. **Verify CGP Calculations**
   - Compare output to NWEA reports
   - Document any methodology differences
   - Add validation tests

### Long-Term Actions

6. **New Feature Support**
   - Learning continuum visualization
   - Instructional area breakdowns
   - State test linking

7. **Maintain Currency**
   - Create process for norm updates
   - Document data format changes
   - Regular NWEA documentation review

## 10. NWEA Resources

### Official Documentation

- **NWEA Resource Center**: https://www.nwea.org/resource-center/
- **MAP Growth Help**: https://teach.mapnwea.org/ (requires login)
- **Technical Documentation**: Available from NWEA support

### Norm Studies

- 2020 Norms: Request from NWEA
- Research on norms: https://www.nwea.org/research/

### Data Format

- CDF documentation: Available in MAP Growth platform
- API documentation: https://api.mapnwea.org/ (if applicable)

## Summary: Currency Status

### Critical Updates Needed

| Item | Current State | Required Update |
|------|---------------|-----------------|
| Norms | 2015 | Add 2020 |
| Sample data | 2012-2013 | Update to current |
| CGP calculations | 2015 norms | Verify with 2020 |
| Data format | Pre-2015 | Verify current |

### Package Default Change

When 2020 norms are added:
```r
# mapvizieR() should default to most recent norms
mapvizieR <- function(cdf, roster, verbose = FALSE, norms = 2020, ...) {
  # ...
}
```

### Documentation Updates

1. Add "Data Format Requirements" vignette
2. Document norm study version differences
3. Explain how to choose appropriate norms
4. Add troubleshooting for format issues
