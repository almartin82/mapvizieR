# round_to_any

because we don't want to have to suggest plyr, if we can avoid it.

## Usage

``` r
round_to_any(x, accuracy, f = round)
```

## Arguments

- x:

  numeric or date-time (POSIXct) vector to round

- accuracy:

  number to round to; for POSIXct objects, a number of seconds

- f:

  rounding function: [`floor`](https://rdrr.io/r/base/Round.html),
  [`ceiling`](https://rdrr.io/r/base/Round.html) or
  [`round`](https://rdrr.io/r/base/Round.html)

## Value

a numeric vector
