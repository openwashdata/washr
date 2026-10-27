# Update the citation file for the dataset.

Create a citation \*.cff file for the dataset from a given DOI (Digital
Object Identifier). When a DOI is supplied, it adds the DOI badge to the
README RMarkdown file (the Zenodo badge, or a generic DOI badge when
`Config/washr/doi-provider` in DESCRIPTION names another provider) and
re-builds the README.md and pkgdown website if they exist. Before a
release exists, call it without arguments to generate the citation files
without a DOI or badge.

The same run writes `.zenodo.json` through
[`update_zenodo_json()`](https://openwashdata.github.io/washr/reference/update_zenodo_json.md),
so the metadata Zenodo reads at release time comes from the same
DESCRIPTION as the citation files.

## Usage

``` r
update_citation(doi = NULL, build = TRUE, type = c("dataset", "software"))
```

## Arguments

- doi:

  DOI (Digital Object Identifier), e.g., 10.5281/zenodo.11185699.
  Defaults to `NULL` for the call before the release, in which case no
  DOI is recorded and no badge is added.

- build:

  Logical. Rebuild README.md and the pkgdown site after the citation
  files change? Defaults to `TRUE`. Set to `FALSE` to regenerate the
  citation files alone, e.g., in scripts and tests.

- type:

  The CFF `type` of the work: `"dataset"` (the default, a data package)
  or `"software"`. Before 1.1.1 the file always said software, the cffr
  default. Zenodo's GitHub integration ignores this field; the resource
  type of a deposit comes from `.zenodo.json`, which always says
  dataset.

## Value

The paths of the three files written, `CITATION.cff`, `inst/CITATION`
and `.zenodo.json`, invisibly.

## Details

When the data comes from a published article, list the article DOI in
DESCRIPTION as `X-schema.org-isBasedOn`, e.g.,
`X-schema.org-isBasedOn: https://doi.org/10.2166/wh.2026.173`. Separate
several DOIs with commas. `update_citation()` looks up each DOI at
doi.org and writes it as a `references` entry in CITATION.cff, with a
message that asks users to cite both the data package and the article.
`inst/CITATION` then holds both entries, so
[`citation()`](https://rdrr.io/r/utils/citation.html) prints both. The
package itself stays the work cited by GitHub's "Cite this repository".
A DOI that cannot be looked up keeps its entry from the existing
CITATION.cff. Other references in CITATION.cff or `inst/CITATION` are
dropped, because DESCRIPTION is their canonical source (#134).

## See also

Before:
[`setup_website()`](https://openwashdata.github.io/washr/reference/setup_website.md).
Run again with the DOI after the Zenodo release;
[`update_metadata()`](https://openwashdata.github.io/washr/reference/update_metadata.md)
then picks the DOI up.
[`update_zenodo_json()`](https://openwashdata.github.io/washr/reference/update_zenodo_json.md)
for the Zenodo metadata file alone.

Other metadata functions:
[`update_description()`](https://openwashdata.github.io/washr/reference/update_description.md),
[`update_metadata()`](https://openwashdata.github.io/washr/reference/update_metadata.md),
[`update_zenodo_json()`](https://openwashdata.github.io/washr/reference/update_zenodo_json.md)

## Examples

``` r
if (FALSE) { # \dontrun{
  update_citation(doi = "10.5281/zenodo.11185699")
  # Regenerate the citation files without rebuilding README.md and the site
  update_citation(build = FALSE)
} # }
```
