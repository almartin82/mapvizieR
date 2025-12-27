# n_timings

a convenience wrapper around timings to record the results of timing a
function's execution

## Usage

``` r
n_timings(n, test_function, test_args)
```

## Arguments

- n:

  num times to run the function

- test_function:

  name of the function, passed to do.call

- test_args:

  list of arguments for the function, passed to do.call
