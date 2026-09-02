# Generate and embed the schema.org metadata of the data package

**\[experimental\]**

`update_metadata()` derives a schema.org Dataset description from the
canonical sources of the package and writes it as a JSON-LD block into
the head of every pkgdown page, where dataset search engines read it.
Nothing is hand edited: to change a value, change its source and run the
function again. Running it twice produces no change. It ends by listing
the fields it could not fill and where to fill them.

The sources are:

|  |  |
|----|----|
| Field | Source |
| name, description, version, datePublished, license | `Title`, `Description`, `Version`, `Date`, `License` in DESCRIPTION |
| url | the pkgdown site (a `github.io` entry in `URL`), else the repository |
| keywords | `X-schema.org-keywords` in DESCRIPTION, comma separated |
| spatialCoverage, temporalCoverage | `X-schema.org-spatialCoverage` and `X-schema.org-temporalCoverage` in DESCRIPTION |
| creator, maintainer, funder, publisher | `Authors@R` roles `aut`/`cre`, `cre`, `fnd`, `cph`; ORCID from the `comment` field |
| identifier, sameAs | the DOI in `CITATION.cff`, written by [`update_citation()`](https://openwashdata-dev.github.io/washr/reference/update_citation.md) |
| variableMeasured | `data-raw/dictionary.csv` |
| distribution | every file in `inst/extdata` that belongs to a dataset, one entry per file |

The JSON-LD lands in `pkgdown/templates/in-header.html`, which pkgdown
picks up on the next site build. The file also keeps the `in_header`
includes from `_pkgdown.yml` working. It is not shipped in the package
tarball.

## Usage

``` r
update_metadata(quiet = FALSE)
```

## Arguments

- quiet:

  Logical. Suppress the messages and the report of blank fields.
  Defaults to `FALSE`.

## Value

The Dataset description as a list, invisibly. The `"blank"` attribute
names the fields that could not be filled and says where to fill them.

## Examples

``` r
if (FALSE) { # \dontrun{
update_metadata()
} # }
```
