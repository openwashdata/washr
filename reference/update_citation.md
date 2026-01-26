# Update the citation file for the dataset.

Create a citation \*.cff file for the released dataset from a given
DOI(Digital Object Identifier). It adds the DOI badge to the README
RMarkdown file and re-build the README.md and pkgdown website if exists.

## Usage

``` r
update_citation(doi)
```

## Arguments

- doi:

  DOI(Digital Object Identifier), e.g., 10.5281/zenodo.11185699

## Value

NULL. A citation .cff file is written under the root directory.

## Examples

``` r
if (FALSE) { # \dontrun{
  update_citation(doi = "10.5281/zenodo.11185699")
} # }
```
