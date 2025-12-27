# filter mapvizieR object

filter a mapvizieR object by academic year, or any variable in the
roster.

## Usage

``` r
mv_filter(mapvizieR_obj, cdf_filter = NA, roster_filter = NA)
```

## Arguments

- mapvizieR_obj:

  mapvizieR object

- cdf_filter:

  a filter, or filters to apply on fields in the cdf. wrap it in
  [`quote()`](https://rdrr.io/r/base/substitute.html)

- roster_filter:

  a filter, or filters to apply on fields in the roster. will also
  filter the cdf to only return those students. wrap it in \`quote()\`

## Value

a filtered mapvizieR object
