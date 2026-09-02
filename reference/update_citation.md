# Update the citation file for the dataset.

Create a citation \*.cff file for the dataset from a given DOI (Digital
Object Identifier). When a DOI is supplied, it adds the DOI badge to the
README RMarkdown file and re-builds the README.md and pkgdown website if
they exist. Before a release exists, call it without arguments to
generate the citation files without a DOI or badge.

## Usage

``` r
update_citation(doi = NULL, build = TRUE)
```

## Arguments

- doi:

  DOI (Digital Object Identifier), e.g., 10.5281/zenodo.11185699.

- build:

  Logical. Rebuild README.md and the pkgdown site after the citation
  files change? Defaults to `TRUE`. Set to `FALSE` to regenerate the
  citation files alone, e.g., in scripts and tests. Defaults to NULL for
  the pre-release call, in which case no DOI is recorded and no badge is
  added.

## Value

NULL. A citation .cff file is written under the root directory.

## See also

Before:
[`setup_website()`](https://openwashdata.github.io/washr/reference/setup_website.md).
Run again with the DOI after the Zenodo release;
[`update_metadata()`](https://openwashdata.github.io/washr/reference/update_metadata.md)
then picks the DOI up.

Other metadata functions:
[`update_description()`](https://openwashdata.github.io/washr/reference/update_description.md),
[`update_metadata()`](https://openwashdata.github.io/washr/reference/update_metadata.md)

## Examples

``` r
if (FALSE) { # \dontrun{
  update_citation(doi = "10.5281/zenodo.11185699")
  # Regenerate the citation files without rebuilding README.md and the site
  update_citation(build = FALSE)
} # }
```
