# group_by wrapper

wrapper for group_by that preserves classes of data frames

## Usage

``` r
# S3 method for class 'mapvizieR_data'
group_by(.data, ..., .add = FALSE, .drop = dplyr::group_by_drop_default(.data))
```

## Arguments

- .data:

  data.frame

- ...:

  additional args

- .add:

  see [`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)

- .drop:

  see [`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)

## Value

data.frame
