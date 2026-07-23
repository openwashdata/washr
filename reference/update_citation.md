# Update the citation file for the dataset.

Create a citation \*.cff file for the dataset from a given DOI (Digital
Object Identifier). When a DOI is supplied, it adds the DOI badge to the
README RMarkdown file and re-builds the README.md and pkgdown website if
they exist. Before a release exists, call it without arguments to
generate the citation files without a DOI or badge.

## Usage

``` r
update_citation(doi = NULL)
```

## Arguments

- doi:

  DOI (Digital Object Identifier), e.g., 10.5281/zenodo.11185699.
  Defaults to NULL for the pre-release call, in which case no DOI is
  recorded and no badge is added.

## Value

NULL. A citation .cff file is written under the root directory.

## Examples

``` r
if (FALSE) { # \dontrun{
  update_citation(doi = "10.5281/zenodo.11185699")
} # }
```
