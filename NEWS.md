# mapvizieR 0.3.6

* `summary()` methods for `growth_df` and `cdf` now respect incoming `dplyr` groupings.

* we use the new `janitor` package from [@sfirke](https://github.com/sfirke) to clean up data frame names.


# mapvizieR 0.3.5

* various hotfixes on plots that were breaking.  most issues appear to be related to upstream changes in `dplyr`. in particular:

- `base::rbind()` replaced with `dplyr::bind_rows()`.  `rbind` seems confused by `dplyr` output.  see [issue 293](https://github.com/almartin82/mapvizieR/issues/293) for detail.

- `dplyr::select` needed references to `matches` explicitly prefixed with `dplyr::`.  Something about the scoping of those `dplyr::select()` statements appears to have changed with dplyr 0.5.0.


# mapvizieR 0.3.4

* an upstream change to `dplyr` broke `roster_to_growth_df`.


# mapvizieR 0.3.3

* fixed a bug that was preventing the mapvizieR object from correctly using the 2011 growth norms for the `growth_df`.


# mapvizieR 0.3.2

* test fixes, mostly causes by changes to `ggplot2` output or changes to our `summary()` methods.
* some housekeeping on function documentation


# mapvizieR 0.3.1

* new viz: `cohort_status_trace_plot()` - uses the 2015 status norms for **grade levels** to show the change in a cohort over time in the **grade level** status space.
* cleans up warnings on calc_baseline_detail 
* tidies up `becca_plot()`, with some new parameter checks.


# mapvizieR 0.3.0

* reworked summary functions to create new cdf summary method.  note that this is a breaking change for any code that depends on `summary(mapviz)` - you should use `summary(mapviz$growth_df)` instead.  `summary(mapviz)` will now return a named list with summaries of every relevant element of the mapvizieR object. 


# mapvizieR 0.2.8

* added new york linking functions


# mapvizieR 0.2.7

* added grade/class status percentiles to `summary()` method.

* rewrote `cohort_cgp_hist_plot` to use grade/class status percentiles.


# mapvizieR 0.2.6

* added median calculations to `summary()` method

* added cohort growth percentile calculations to `summary()` method.


# mapvizieR 0.2.5

* `read_cdf` generates messages, not warnings or errors, when it encounters 0-length data files.

* `read_cdf` brings in all files as character, then does type inference after `dplyr::bind_rows()` has combined files.

* `quealy_subgroups` fix that allows Fall-to-Winter CGP to print.


# mapvizieR 0.2.4

* fixes deprecated `dplyr::rbind_all`.


# mapvizieR 0.2.3

* started keeping track of new features in `NEWS.md` :see_no_evil:
* added `fall_goals_report` and `historic_recap`.
