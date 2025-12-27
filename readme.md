# mapvizieR

[![R-CMD-check](https://github.com/almartin82/mapvizieR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/almartin82/mapvizieR/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/almartin82/mapvizieR/branch/master/graph/badge.svg)](https://codecov.io/gh/almartin82/mapvizieR)
[![CRAN
status](https://www.r-pkg.org/badges/version/mapvizieR)](https://CRAN.R-project.org/package=mapvizieR)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)

## Overview

mapvizieR provides a comprehensive suite of visualization and analysis
tools for [NWEA MAP](https://www.nwea.org/map-growth/) assessment data.
It helps educators and analysts explore student growth, achievement, and
progress through intuitive visualizations and data transformations.

## Installation

``` r
# Install from GitHub (recommended)
# install.packages("pak")
pak::pak("almartin82/mapvizieR")

# Or use devtools
# install.packages("devtools")
devtools::install_github("almartin82/mapvizieR")
```

## Quick Start

### 1. Prepare Your Data

mapvizieR works with two primary data inputs from NWEA MAP:

- **CDF (Comprehensive Data File)**: Student-level test results
- **Roster**: Student demographic and enrollment information

``` r
library(mapvizieR)

# Read your MAP data files
cdf <- read_cdf("path/to/your/cdf_file.csv")
roster <- read_roster("path/to/your/roster_file.csv")
```

### 2. Create a mapvizieR Object

``` r
# Create the main mapvizieR object
mapviz <- mapvizieR(
  cdf = cdf,
  roster = roster,
  growth_norms = 2015  # Use 2015 NWEA growth norms
)
```

### 3. Explore Your Data

``` r
# Summary statistics
summary(mapviz)

# Get student growth data
growth_df <- mapviz$growth_df

# Filter by specific criteria
filtered <- mv_filter(
  mapviz,
  roster_filter = quote(schoolname == "My School")
)
```

## Key Visualizations

mapvizieR includes many visualization functions for exploring MAP data:

### Student Growth Plots

``` r
# Becca Plot: Student-level growth visualization
becca_plot(
  mapvizieR_obj = mapviz,
  studentids = students$studentid,
  measurementscale = "Mathematics",
  start_fws = "Fall",
  start_year = 2023,
  end_fws = "Spring",
  end_year = 2024
)
```

### Cohort Analysis

``` r
# Galloping Elephants: Distribution over time
galloping_elephants(
  mapvizieR_obj = mapviz,
  studentids = students$studentid,
  measurementscale = "Reading",
  first_and_spring_only = FALSE
)
```

### Goal Tracking

``` r
# HAID Plot: Historical achievement and growth
haid_plot(
  mapvizieR_obj = mapviz,
  studentids = students$studentid,
  measurementscale = "Mathematics",
  start_fws = "Fall",
  start_year = 2023,
  end_fws = "Spring",
  end_year = 2024
)
```

## Theming and Colors

mapvizieR 0.4.0 introduces consistent theming for visualizations:

``` r
library(ggplot2)

# Use the mapvizieR theme
ggplot(data, aes(x, y)) +
  geom_point() +
  theme_mapvizier()

# Quartile color scales
ggplot(data, aes(x, y, fill = quartile)) +
  geom_col() +
  scale_fill_quartile()

# Get color palettes
mapvizier_quartile_colors()
mapvizier_growth_colors()
```

## Requirements

- R \>= 4.1.0
- ggplot2 \>= 3.4.0
- dplyr \>= 1.1.0

## Documentation

- [Package website](https://almartin82.github.io/mapvizieR) - Full
  documentation and vignettes
- [Function
  reference](https://almartin82.github.io/mapvizieR/reference/) -
  Complete API documentation

## For Developers

Internal development documentation and analysis is maintained in a
private repository. Contributors with repository access can request an
invite to
[mapvizieR-analysis](https://github.com/almartin82/mapvizieR-analysis)
for: - Architecture documentation - Code audits and modernization
notes - Test regression analysis - Implementation planning documents

Contact the maintainers for access.

## Contributing

Contributions are welcome! Please see our [contributing
guidelines](https://almartin82.github.io/mapvizieR/CONTRIBUTING.md) for
details.

1.  Fork the repository
2.  Create a feature branch (`git checkout -b feature/amazing-feature`)
3.  Commit your changes (`git commit -m 'Add amazing feature'`)
4.  Push to the branch (`git push origin feature/amazing-feature`)
5.  Open a Pull Request

## License

MIT License. See
[LICENSE](https://almartin82.github.io/mapvizieR/LICENSE) for details.

## Citation

If you use mapvizieR in your research or reporting, please cite it:

    @software{mapvizieR,
      author = {Martin, Andrew},
      title = {mapvizieR: Visualizations and Analysis for NWEA MAP Data},
      url = {https://github.com/almartin82/mapvizieR},
      year = {2024}
    }

## Related Projects

- [NWEA MAP Growth](https://www.nwea.org/map-growth/) - The assessment
  system
- [tidyverse](https://www.tidyverse.org/) - R packages for data science
