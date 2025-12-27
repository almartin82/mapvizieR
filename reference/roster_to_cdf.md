# roster_to_cdf

when you need to put a roster object onto a cdf. reasonably easy because
this is point in time data.

## Usage

``` r
roster_to_cdf(
  target_df,
  mapvizieR_obj,
  roster_cols,
  by_measurementscale = FALSE
)
```

## Arguments

- target_df:

  the df you want to put stuff on

- mapvizieR_obj:

  a conforming mapvizieR object

- roster_cols:

  roster column names you want to move over. to move 'studentgender',
  pass the character string. to move multiple columns, pass as a vector:
  c('studentgender', 'studentethnicgroup')

- by_measurementscale:

  boolean, when you have student demographics that are specific to a
  particular assessment - eg course enrollment, but the match is
  specific to student AND measurementscale, not just student. if TRUE
  your roster object must contain a field called measurementscale.

## Value

a cdf data frame with the roster objects
