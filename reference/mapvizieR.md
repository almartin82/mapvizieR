# Create a mapvizieR object

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

## Examples

``` r
if (FALSE) { # \dontrun{
cdf_mv <- mapvizieR(ex_CombinedAssessmentResults, 
                    ex_CombinedStudentsBySchool)
                    
is.mapvizieR(cdf_mv)                     
} # }
```
