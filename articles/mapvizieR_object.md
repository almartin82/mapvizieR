# your new mapvizieR object

## big idea

prior to mapvizieR, Chris and I had very different workflows and data
structures for storing longitudinal MAP data. As a result our shared R
code had a lot of extra cruft built into every plot that would try to
adapt it to our different environments As a result there was a lot of
code like
[this](https://github.com/almartin82/MAP-visuals/blob/2daa2dc47aa5afb84bc85e992657aaa9018b5e85/R/becca_plot.R#L59)
which moved stuff around when the plotting functions were called.

As a design pattern this proved to be inefficient (lots of extra
parameters for every function) and brittle (we didn’t have tests on the
old package, and even if we did, they would have been extremely hard to
write.)

and thus the **mapvizieR object** born! rather than write a bunch of
defensive logic in each plot (and depend on each end user to write
custom pipelines into our canonical formats) we decided that we would
put some up-front effort in to defining a data object that, if
conforming, would ‘just work’ with our plots. that object is the
mapvizieR object.

## raw ingredients

NWEA hands data back in two important files:

- `AssessmentResults.csv`
- `StudentsBySchool.csv`

(we are assuming that folks are using web-based MAP here. If you are
using client-server MAP, there are a few annoying changes to your CDF
that will have to be made, because the data model changed
ever-so-slightly between the two platforms. Writing these functions is
currently a [\#todo](https://github.com/almartin82/mapvizieR/issues/37),
but on the whole they’re not so complicated. Get in touch if this
describes your situation.)

## what happens next

well, if you’ve copied/pasted all the csvs together into two
master/combined files, hopefully you can just load your files, and then
just call mapvizieR

``` r
library(mapvizieR)

mapviz <- mapvizieR(
  cdf = ex_CombinedAssessmentResults,
  roster = ex_CombinedStudentsBySchool
)

mapviz
```

    ## A mapvizieR object repesenting:
    ## - 2 school years from SY2012 to SY2013;
    ## - 714 students from 4 schools;
    ## - and, 6 growth seasons:
    ##     Fall to Winter,
    ##     Fall to Spring,
    ##     Fall to Fall,
    ##     Spring to Spring,
    ##     Winter to Spring,
    ##     Winter to Winter

that’s sort of psuedo-code, because I’m not sure how to actually read in
the raw data that we’ve provided in this package in the vignette
environment (filesystems are hard, man) but if you run that
`mapvizier()` call as written it should work in your environment,
because we’ve also included those files as `.Rda` objects.

## how to think about the mapvizieR object

The mapvizieR object is a floor, not a ceiling. getting your MAP data
into a mapvizieR object ensures that it will work with the plots and
reports in the package; however, you can (and should) feel free to
modify and add to the mapvizieR object to capture information unique to
your region. The roster slot in the object is a good example – there are
certain things that are required by the object, but you can safely add
additional demographic columns (regions, houses, etc) and your object
will still conform.

## what’s in the object?

``` r
names(mapviz)
```

    ## [1] "cdf"       "roster"    "growth_df" "goals"

the mapvizieR object is really just a named list; it has a number of
data frames that plot functions can access. rather than trying to keep
one dataframe to rule them all (which inevitably requires concessions
that aren’t ideal) we get to keep roster, cdf and growth data on
separate objects, and then mix them together when needed to generate
reports.

Right now mapvizieR has 4 objects that live in it.

### cdf

the cdf looks a lot like the AssessmentResults file, with a few
enhancements. notably, it tags grade level to the CDF observation, and
ensures that there aren’t multiple assessment records in the same
subject/season for a student.

``` r
names(mapviz[['cdf']])
```

    ##   [1] "termname"                                 
    ##   [2] "studentid"                                
    ##   [3] "schoolname"                               
    ##   [4] "measurementscale"                         
    ##   [5] "discipline"                               
    ##   [6] "growthmeasureyn"                          
    ##   [7] "wiselectedayfall"                         
    ##   [8] "wiselectedaywinter"                       
    ##   [9] "wiselectedayspring"                       
    ##  [10] "wipreviousayfall"                         
    ##  [11] "wipreviousaywinter"                       
    ##  [12] "wipreviousayspring"                       
    ##  [13] "testtype"                                 
    ##  [14] "testname"                                 
    ##  [15] "testid"                                   
    ##  [16] "teststartdate"                            
    ##  [17] "testdurationminutes"                      
    ##  [18] "testritscore"                             
    ##  [19] "teststandarderror"                        
    ##  [20] "testpercentile"                           
    ##  [21] "falltofallprojectedgrowth"                
    ##  [22] "falltofallobservedgrowth"                 
    ##  [23] "falltofallobservedgrowthse"               
    ##  [24] "falltofallmetprojectedgrowth"             
    ##  [25] "falltofallconditionalgrowthindex"         
    ##  [26] "falltofallconditionalgrowthpercentile"    
    ##  [27] "falltowinterprojectedgrowth"              
    ##  [28] "falltowinterobservedgrowth"               
    ##  [29] "falltowinterobservedgrowthse"             
    ##  [30] "falltowintermetprojectedgrowth"           
    ##  [31] "falltowinterconditionalgrowthindex"       
    ##  [32] "falltowinterconditionalgrowthpercentile"  
    ##  [33] "falltospringprojectedgrowth"              
    ##  [34] "falltospringobservedgrowth"               
    ##  [35] "falltospringobservedgrowthse"             
    ##  [36] "falltospringmetprojectedgrowth"           
    ##  [37] "falltospringconditionalgrowthindex"       
    ##  [38] "falltospringconditionalgrowthpercentile"  
    ##  [39] "wintertowinterprojectedgrowth"            
    ##  [40] "wintertowinterobservedgrowth"             
    ##  [41] "wintertowinterobservedgrowthse"           
    ##  [42] "wintertowintermetprojectedgrowth"         
    ##  [43] "wintertowinterconditionalgrowthindex"     
    ##  [44] "wintertowinterconditionalgrowthpercentile"
    ##  [45] "wintertospringprojectedgrowth"            
    ##  [46] "wintertospringobservedgrowth"             
    ##  [47] "wintertospringobservedgrowthse"           
    ##  [48] "wintertospringmetprojectedgrowth"         
    ##  [49] "wintertospringconditionalgrowthindex"     
    ##  [50] "wintertospringconditionalgrowthpercentile"
    ##  [51] "springtospringprojectedgrowth"            
    ##  [52] "springtospringobservedgrowth"             
    ##  [53] "springtospringobservedgrowthse"           
    ##  [54] "springtospringmetprojectedgrowth"         
    ##  [55] "springtospringconditionalgrowthindex"     
    ##  [56] "springtospringconditionalgrowthpercentile"
    ##  [57] "rittoreadingscore"                        
    ##  [58] "rittoreadingmin"                          
    ##  [59] "rittoreadingmax"                          
    ##  [60] "goal1name"                                
    ##  [61] "goal1ritscore"                            
    ##  [62] "goal1stderr"                              
    ##  [63] "goal1range"                               
    ##  [64] "goal1adjective"                           
    ##  [65] "goal2name"                                
    ##  [66] "goal2ritscore"                            
    ##  [67] "goal2stderr"                              
    ##  [68] "goal2range"                               
    ##  [69] "goal2adjective"                           
    ##  [70] "goal3name"                                
    ##  [71] "goal3ritscore"                            
    ##  [72] "goal3stderr"                              
    ##  [73] "goal3range"                               
    ##  [74] "goal3adjective"                           
    ##  [75] "goal4name"                                
    ##  [76] "goal4ritscore"                            
    ##  [77] "goal4stderr"                              
    ##  [78] "goal4range"                               
    ##  [79] "goal4adjective"                           
    ##  [80] "goal5name"                                
    ##  [81] "goal5ritscore"                            
    ##  [82] "goal5stderr"                              
    ##  [83] "goal5range"                               
    ##  [84] "goal5adjective"                           
    ##  [85] "goal6name"                                
    ##  [86] "goal6ritscore"                            
    ##  [87] "goal6stderr"                              
    ##  [88] "goal6range"                               
    ##  [89] "goal6adjective"                           
    ##  [90] "goal7name"                                
    ##  [91] "goal7ritscore"                            
    ##  [92] "goal7stderr"                              
    ##  [93] "goal7range"                               
    ##  [94] "goal7adjective"                           
    ##  [95] "goal8name"                                
    ##  [96] "goal8ritscore"                            
    ##  [97] "goal8stderr"                              
    ##  [98] "goal8range"                               
    ##  [99] "goal8adjective"                           
    ## [100] "teststarttime"                            
    ## [101] "percentcorrect"                           
    ## [102] "projectedproficiencystudy1"               
    ## [103] "projectedproficiencylevel1"               
    ## [104] "projectedproficiencystudy2"               
    ## [105] "projectedproficiencylevel2"               
    ## [106] "projectedproficiencystudy3"               
    ## [107] "projectedproficiencylevel3"               
    ## [108] "fallwinterspring"                         
    ## [109] "map_year_academic"                        
    ## [110] "grade"                                    
    ## [111] "rn"                                       
    ## [112] "grade_level_season"                       
    ## [113] "grade_season_label"                       
    ## [114] "consistent_percentile"                    
    ## [115] "testquartile"

``` r
mapviz[['cdf']][c(1:2),]
```

    ## # A tibble: 2 × 115
    ## # Groups:   measurementscale, map_year_academic, fallwinterspring, termname,
    ## #   schoolname, grade, grade_level_season [2]
    ##   termname      studentid schoolname measurementscale discipline growthmeasureyn
    ##   <chr>         <chr>     <chr>      <chr>            <chr>      <lgl>          
    ## 1 Spring 2012-… F08000002 Three Sis… Language Usage   Language   TRUE           
    ## 2 Fall 2013-20… F08000002 Mt. Bache… Language Usage   Language   TRUE           
    ## # ℹ 109 more variables: wiselectedayfall <lgl>, wiselectedaywinter <lgl>,
    ## #   wiselectedayspring <lgl>, wipreviousayfall <lgl>, wipreviousaywinter <lgl>,
    ## #   wipreviousayspring <lgl>, testtype <chr>, testname <chr>, testid <int>,
    ## #   teststartdate <date>, testdurationminutes <int>, testritscore <dbl>,
    ## #   teststandarderror <dbl>, testpercentile <int>,
    ## #   falltofallprojectedgrowth <int>, falltofallobservedgrowth <lgl>,
    ## #   falltofallobservedgrowthse <lgl>, falltofallmetprojectedgrowth <lgl>, …

### roster

the mapvizieR call above basically returns the StudentsBySchool file
here; if you are operating with a data warehouse you have some options
here to build your own mapvizieR object with a more extensive roster
file that includes other student assignments (courses, homerooms,
athletics, etc.) Minimally, the roster object has to have a studentid
and the student’s grade level for every test season in the CDF.

**TODO**: describe KIPP NJ’s workflow to show how to build a mapvizieR
object with a custom roster. \### growth_df The growth df is a
transformation of the cdf that has one row per student/subject/growth
window. for instance, a 5th grade Math student will have records for
‘Fall to Fall’, ‘Fall to Spring’, ‘Fall to Winter’, ‘Winter to Spring’,
and ‘Spring to Spring’ growth.  
This dataframe is built automatically. Having your data pre-processed in
this format makes a variety of otherwise complicated analysis extremely
straightforward.

## under the hood

If you look at the source on
[mapvizieR](https://github.com/almartin82/mapvizieR/blob/master/R/mapvizieR_object.R#L23)
you can see the workflow.

- first calls `prep_cdf_long` on the raw cdf/AssessmentResults file
- then calls `prep_roster` on the roster/StudentsBySchool file
- with the roster in hand, it tags the CDF with grade levels by calling
  `grade_levelify_cdf`, which triggers a series of post-processing
  functions that generate labels based on grade level and season.
