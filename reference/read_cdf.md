# Reads CDF csv files from a director

utility function to read in multiple NWEA files, if dir is known.

## Usage

``` r
read_cdf(path = ".", verbose = TRUE, bad_students = NA)
```

## Arguments

- path:

  the path to the CSV files as character vector

- verbose:

  defaults is TRUE

- bad_students:

  StudentIDs to ignore

## Value

a list holding data frames with of stacked longitudinal MAP data. There
are slots for each CSV provided in a test session by NWEA:
\`assessment_results\`, \`students_by_school\`, \`class_assignments\`,
\`accommodation_assignments\`, and \`program_assignments\`.

## Examples

``` r
if (FALSE) { # \dontrun{
cdf <- read_cdf("data/")

str(cdf)
} # }
```
