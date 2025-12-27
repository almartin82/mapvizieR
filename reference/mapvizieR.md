# mapvizieR

A suite of analytic, visualization, and reporting tools for NWEA MAP
Data. Provides functions for creating visualizations of student growth,
cohort status, and goal attainment from MAP assessment data. Includes
specialized plots like the becca plot, galloping elephants, haid plot,
and quealy subgroups visualization.

`mapvizieR` is a workhorse workflow function that calls a sequence of
cdf and roster prep functions, given a cdf and roster

## Usage

``` r
mapvizieR(cdf, roster, verbose = FALSE, norms = 2015, ...)
```

## Arguments

- cdf:

  a NWEA AssessmentResults.csv or CDF

- roster:

  a NWEA students

- verbose:

  should mapvizieR print status updates? default is FALSE.

- norms:

  norm study to use. passed through to cdf prep

- ...:

  additional arguments to pass to constructor functions called by
  mapvizieR

## See also

Useful links:

- <https://github.com/almartin82/mapvizieR>

- <https://almartin82.github.io/mapvizieR>

- Report bugs at <https://github.com/almartin82/mapvizieR/issues>

## Author

**Maintainer**: Andrew Martin <almartin@gmail.com>

Authors:

- Chris Haid <chaid@kippchicago.org>

## Examples

``` r
if (FALSE) { # \dontrun{
cdf_mv <- mapvizieR(ex_CombinedAssessmentResults, 
                    ex_CombinedStudentsBySchool)
                    
is.mapvizieR(cdf_mv)                     
} # }
```
