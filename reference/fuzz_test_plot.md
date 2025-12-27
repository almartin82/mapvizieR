# fuzz_test_plot

throws a random subset of students against a plot n times, and reports
back if a valid ggplot gets returned

## Usage

``` r
fuzz_test_plot(
  plot_name,
  n = 100,
  additional_args = list(),
  mapvizieR_obj = mapvizieR(cdf = ex_CombinedAssessmentResults, roster =
    ex_CombinedStudentsBySchool)
)
```

## Arguments

- plot_name:

  name of a plot, as text. gets thrown to do call

- n:

  how many times to test?

- additional_args:

  all plots will get "mapvizieR_obj" and "studentids". if your plot
  needs additional args, pass them here.

- mapvizieR_obj:

  a
  [`mapvizieR`](https://almartin82.github.io/mapvizieR/reference/mapvizieR.md)
  object.
