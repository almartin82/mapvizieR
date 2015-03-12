# mapvizieR
### mapvizieR is an R package that generates visualizations and reports for NWEA MAP data.
[![Build Status](https://travis-ci.org/almartin82/mapvizieR.png?branch=master)](https://travis-ci.org/almartin82/mapvizieR) [![Coverage Status](https://coveralls.io/repos/almartin82/mapvizieR/badge.svg?branch=master)](https://coveralls.io/r/almartin82/mapvizieR?branch=master)

...because how else are you going to get a capital 'R' into mapviz?
<br><img src="https://upload.wikimedia.org/wikipedia/commons/thumb/0/0e/Arolsen_Klebeband_02_327.jpg/255px-Arolsen_Klebeband_02_327.jpg">

## what's inside?

### data prep functions
prep MAP data and create `cdf_long` and `cdf_growth` dataframes.
along with roster info, those data frames get wrapped up into a `mapvizieR` object, which can be passed to the visualization functions below..

### data tests and checks
test data frames to see if they conform with mapvizieR conventions and expectations.

### group visualizations
these plots show MAP scores for a group of students across multiple testing terms.  they expect a `cdf_long` dataframe and return ggplot charts.  some examples:

- `becca_plot()`
- `galloping_elephants()`


### growth visualizations
unlike the functions above, which can take 1, 2, 3, n... test seasons, a lot of MAP analysis revolves around growth windows.  these visualization functions expect a 'cdf_growth' dataframe.  examples include:

- `quealy_subgroups()` _to come_
- `haid_plot()` _to come_
- `goal_bar()`  _to come_

### multiple term student longitudinal visualizations
_college ready/rutgers ready growth stuff will go here_

## development guidelines

### testing
- write tests & vignettes off of the sample CDF in `data/CombinedAssessmentRsults.csv`

- did you how it said 'write tests' up there?  write tests!

- a note on testing: remember that if you are doing something fancy with `do.call`, coveralls/travis might give you the false impression that you have full coverage.  enumerate the types of things the `do.call` step might do, and write test cases for each.  (this bit me [here](https://github.com/almartin82/mapvizieR/blob/7bc5199bb8d7f2100ce809618d61011e509d4bf8/R/cdf_prep.R#L90))

- separate data processing functions from visualization functions

- use ggplot themes, where possible, to handle formatting stuff (font size, transparency, etc) on plots

- there's a tag for `design philosophy` in issues; put down thoughts about how we're thinking about handling data, workflows, etc there.

