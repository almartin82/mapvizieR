# identify type of cdf from AssessmentResults file.

identify type of cdf from AssessmentResults file.

## Usage

``` r
id_cdf_type(cdf)
```

## Arguments

- cdf:

  an Assessment Results data frame.

## Value

one of "Client-Server", "WBM pre-2015", "WBM post-2015"

## Examples

``` r
data(ex_CombinedAssessmentResults)
id_cdf_type(ex_CombinedAssessmentResults)
#> [1] "WBM post-2015"

data(ex_CombinedAssessmentResults_pre_2015)
id_cdf_type(ex_CombinedAssessmentResults_pre_2015)
#> [1] "WBM pre-2015"
```
