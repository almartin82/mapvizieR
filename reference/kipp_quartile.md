# Calcualte KIPP Foundation style quartiles from percentile vector

`kipp_quartile` returns an integer or factor vector quartiles.

## Usage

``` r
kipp_quartile(x, return_factor = TRUE, proper_quartile = FALSE)
```

## Arguments

- x:

  vector of percentiles to be converted to quartiels

- return_factor:

  default is `TRUE`. If set to `FALSE` returns integers rather than
  factors.

- proper_quartile:

  defaul is `FALSE`. If set to `TRUE` returns traditional quartiles
  rather then KIPP Foundation quartiles.

## Value

a vector of `length(x)`.

## Details

This function calculates the KIPP Foundation's (kinda fucked up)
quartile (i.e., the foundation breaks with stanard mathematical pracitce
and puts the 50th percenile in the 3rd rather than the 2nd quartile). It
takes a vector of percentiles and translates those into quartiles, where
the 25th, 50th, and 75th percentils are shifted up into the 2nd, 3rd,
and 4th quartiles, respectively. You can revert to a traditional
quartile calculation by setting the `proper.quartile` argument to
`TRUE`.

## Examples

``` r
x <- sample(x=1:99, 100,replace = TRUE)
kipp_quartile(x)
#>   [1] 4 4 1 3 3 2 3 2 1 4 2 3 2 3 3 1 2 2 4 4 2 1 2 3 3 1 1 1 2 2 1 3 3 1 4 1 3
#>  [38] 2 3 2 3 2 2 1 2 4 4 4 2 2 4 4 2 1 4 1 2 3 3 1 1 1 1 3 2 3 2 4 3 1 3 2 2 3
#>  [75] 2 3 1 1 4 1 1 4 2 4 4 2 3 3 1 2 2 1 1 4 2 3 3 3 3 2
#> Levels: 1 2 3 4
kipp_quartile(x, proper_quartile=TRUE)
#>   [1] 4 4 1 3 3 2 3 2 1 4 2 3 2 3 3 1 2 2 4 4 2 1 2 3 3 1 1 1 2 2 1 3 3 1 4 1 3
#>  [38] 2 3 2 3 1 2 1 2 4 4 4 2 2 3 4 2 1 4 1 2 3 3 1 1 1 1 3 2 3 2 4 3 1 3 2 2 3
#>  [75] 2 3 1 1 4 1 1 4 2 4 4 2 3 3 1 2 2 1 1 4 2 3 3 3 3 2
#> Levels: 1 2 3 4
kipp_quartile(x, proper_quartile=TRUE, return_factor=FALSE)
#>   [1] 4 4 1 3 3 2 3 2 1 4 2 3 2 3 3 1 2 2 4 4 2 1 2 3 3 1 1 1 2 2 1 3 3 1 4 1 3
#>  [38] 2 3 2 3 1 2 1 2 4 4 4 2 2 3 4 2 1 4 1 2 3 3 1 1 1 1 3 2 3 2 4 3 1 3 2 2 3
#>  [75] 2 3 1 1 4 1 1 4 2 4 4 2 3 3 1 2 2 1 1 4 2 3 3 3 3 2
```
