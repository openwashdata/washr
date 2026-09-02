
<!-- README.md is generated from README.Rmd. Please edit that file -->

# washr

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/washr)](https://CRAN.R-project.org/package=washr)
[![R-CMD-check](https://github.com/openwashdata/washr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/openwashdata/washr/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/openwashdata/washr/graph/badge.svg)](https://app.codecov.io/gh/openwashdata/washr)
[![License: GPL
v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

<!-- badges: end -->

washr turns a cleaned dataset into a documented R data package that
follows the FAIR principles, with a website, a citation file and machine
readable metadata. It is the toolkit behind the
[openwashdata](https://openwashdata.org/pages/gallery/data/) data
packages, and it works for any group that publishes open data as an R
package.

## Installation

From CRAN:

``` r
install.packages("washr")
```

Or the development version from
[GitHub](https://github.com/openwashdata/washr):

``` r
# install.packages("remotes")
remotes::install_github("openwashdata/washr")
```

## What washr does

The stable core scaffolds and documents the package, one function per
step, in the order you run them:

- `setup_ci()` adds the R CMD check workflow the review standard
  requires.
- `setup_rawdata()` creates `data-raw/` and the processing script.
- `setup_dictionary()` writes the variable dictionary from the data
  objects.
- `setup_roxygen()` writes the roxygen documentation from the
  dictionary.
- `update_description()` completes `DESCRIPTION` to the openwashdata
  standard.
- `setup_readme()` writes the README from the template.
- `setup_website()` writes the pkgdown configuration and builds the
  site.
- `use_brand()` installs the openwashdata brand for the site.
- `update_citation()` writes the citation files, with the DOI once there
  is one.

The FAIR layer is one experimental function. `update_metadata()` derives
a schema.org description of the dataset from the files above and embeds
it in the site, where dataset search engines read it.

Every function reads what is there, merges its changes, and is safe to
run again.

## How to use washr

The [Get
started](https://openwashdata.github.io/washr/articles/washr.html) page
walks through the workflow in order, and the
[Reference](https://openwashdata.github.io/washr/reference/index.html)
page documents each function. The [publishing
guide](https://global-health-engineering.github.io/ghedatapublishing/)
covers the same steps with more explanation and the parts outside R,
such as the GitHub repository and the Zenodo release.
