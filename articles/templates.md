# Report Templates

This vignette illustrates the available report template layouts in
`templates.R`.

``` r
require(mapvizieR)
```

    ## Loading required package: mapvizieR

``` r
require(grid)
```

    ## Loading required package: grid

``` r
require(dplyr)
```

    ## Loading required package: dplyr

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
knitr::opts_chunk$set(
  dev = 'svg',
  fig.width = 5,
  fig.height = 3
)

p01 <- grobTree(
  rectGrob(gp=gpar(fill='orange', alpha=0.9)), textGrob('p01')
)
p02 <- grobTree(
  rectGrob(gp=gpar(fill='gray', alpha=0.9)), textGrob('p02')
)
p03 <- grobTree(
  rectGrob(gp=gpar(fill='pink', alpha=0.9)), textGrob('p03')
)
p04 <- grobTree(
  rectGrob(gp=gpar(fill='blue', alpha=0.9)), textGrob('p04')
)
p05 <- grobTree(
  rectGrob(gp=gpar(fill='red', alpha=0.9)), textGrob('p05')
)
p06 <- grobTree(
  rectGrob(gp=gpar(fill='green', alpha=0.9)), textGrob('p06')
)
```

## template 01

Template 01 is a 2 column grid.

``` r
template_01(p01, p02) %>% grid.draw()
```

![](templates_files/figure-html/unnamed-chunk-2-1.png)

## template 02

Template 02 is a 3 column grid.

``` r
template_02(p01, p02, p03) %>% grid.draw()
```

![](templates_files/figure-html/unnamed-chunk-3-1.png)

## template 03

Template 03 is a 2 x 2 column grid.

``` r
template_03(p01, p02, p03, p04) %>% grid.draw()
```

![](templates_files/figure-html/unnamed-chunk-4-1.png)

## template 04

Template 04 is a 3 column grid, focused on the center, with 2 row grids
on each side.

``` r
template_04(p01, p02, p03, p04, p05) %>% grid.draw()
```

![](templates_files/figure-html/unnamed-chunk-5-1.png)

## template 05

Template 05 is a 2 *row* grid.

``` r
template_05(p01, p02) %>% grid.draw()
```

![](templates_files/figure-html/unnamed-chunk-6-1.png)

## template 06

Template 05 is a 2 column grid.

``` r
template_06(p01, p02, p03, p04, p05, p06) %>% grid.draw()
```

![](templates_files/figure-html/unnamed-chunk-7-1.png)
