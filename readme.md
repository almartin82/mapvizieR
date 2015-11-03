# mapvizieR:
### an R package that generates visualizations and reports for NWEA MAP data.

[![wercker status](https://app.wercker.com/status/9148019dd43b8d0b5bd8f88f8ba51e37/m/master "wercker status")](https://app.wercker.com/project/bykey/9148019dd43b8d0b5bd8f88f8ba51e37)[![codecov.io](https://codecov.io/github/almartin82/mapvizieR/coverage.svg?branch=master)](https://codecov.io/github/almartin82/mapvizieR?branch=master)

...because how else are you going to get a capital 'R' into mapviz?
<br><img src="https://upload.wikimedia.org/wikipedia/commons/thumb/0/0e/Arolsen_Klebeband_02_327.jpg/255px-Arolsen_Klebeband_02_327.jpg">

# why mapvizieR?
The [MAP](https://www.nwea.org/assessments/map/) assessment is a computer-adaptive, norm-referenced assessment published by [NWEA](https://www.nwea.org/about/), a not-for-profit organization that specializes in assessment.
More than **10 million students** take the MAP assessment - including [KIPP](http://www.kipp.org/), the organization where [Andrew](https://twitter.com/moneywithwings) and [Chris](https://www.linkedin.com/in/chrishaid) work.

We'd like mapvizeR to be a home where data scientists [working with MAP data](https://github.com/search?l=r&q=testritscore&type=Code&utf8=%E2%9C%93) can share visualizations and analysis tools, given that we're all working on a common data set.  If you work with MAP data, please reach out!

# is mapvizier licensed by, or affiliated with NWEA?
Nope!  This is an independent community effort.  

# what's inside?
mapvizieR is a product of some [lessons learned](https://github.com/almartin82/MAP-visuals) about the promises, and pitfalls, of sharing common analysis code.  Central to our approach here is workflow to create a [mapvizier](https://github.com/almartin82/MAP-visuals/blob/master/R/mapvizier.R) object, so that plots, analysis, and reporting can benefit from clear definitions and data structures.  The basic idea is that if each participating entity can build a data loading pathway into the mapvizieR object, reporting becomes easy scalable.  

Take a look at this [this](https://github.com/almartin82/mapvizieR/blob/master/vignettes/mapvizieR_object.Rmd) vignette, which describes the object in detail.

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

- `quealy_subgroups()`
- `haid_plot()`
- `goal_bar()`

### multiple term student longitudinal visualizations
_college ready/rutgers ready growth stuff will go here_

## development guidelines

### style
- follow the `lintr` conventions https://github.com/jimhester/lintr
- `.lintr` has configuration options for the lintr bot.
- read about rstudio code analysis integration [here](https://support.rstudio.com/hc/en-us/articles/205753617-Code-Diagnostics)

### testing
- write tests & vignettes off of the sample CDF in `data/CombinedAssessmentRsults.csv`

- did you how it said 'write tests' up there?  write tests!

- a note on testing: remember that if you are doing something fancy with `do.call`, coveralls/travis might give you the false impression that you have full coverage.  enumerate the types of things the `do.call` step might do, and write test cases for each.  (this bit me [here](https://github.com/almartin82/mapvizieR/blob/7bc5199bb8d7f2100ce809618d61011e509d4bf8/R/cdf_prep.R#L90))

- separate data processing functions from visualization functions

- use ggplot themes, where possible, to handle formatting stuff (font size, transparency, etc) on plots

- there's a tag for `design philosophy` in issues; put down thoughts about how we're thinking about handling data, workflows, etc there.

