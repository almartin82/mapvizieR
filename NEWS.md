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

