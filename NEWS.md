# mapvizieR 0.2.5

* `read_cdf` generates messages, not warnings or errors, when it encounters 0-length data files.

* `read_cdf` brings in all files as character, then does type inference after `dplyr::bind_rows()` has combined files.

# mapvizieR 0.2.4

* fixes deprecated `dplyr::rbind_all`.

# mapvizieR 0.2.3

* started keeping track of new features in `NEWS.md` :see_no_evil:
* added `fall_goals_report` and `historic_recap`.

