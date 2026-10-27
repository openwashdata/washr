# Check whether the data package is ready for publication

`check_publication_readiness()` walks through the publication workflow
and reports, item by item, what is in place and what is missing. For
every gap it names the step and the washr function that closes it, so a
skipped step shows up here and not as an error in a later function. The
function only reads the package. It writes nothing.

The items are the mechanically decidable part of the openwashdata review
standard for the metadata, the data dictionary, the documentation and
the check workflow of a package. Each item has a stable `id`, so a
script or a review tool can pick the rows it needs.

|  |  |  |
|----|----|----|
| Area | `id` | Passes when |
| metadata | `license` | `License` in DESCRIPTION is CC BY 4.0, the license of the standard |
| metadata | `description_complete` | `Title`, `Description` and `Authors@R` no longer hold the placeholder text of a new package |
| metadata | `citation_cff` | `CITATION.cff` is present |
| metadata | `citation_version` | the `version` in `CITATION.cff` equals `Version` in DESCRIPTION |
| metadata | `citation_authors` | `CITATION.cff` and `inst/CITATION` carry real authors, not "Firstname Lastname" |
| metadata | `zenodo_json` | `.zenodo.json` is present and equals what DESCRIPTION gives now |
| metadata | `keywords` | DESCRIPTION carries `X-schema.org-keywords`; the detail says whether `CITATION.cff` agrees |
| metadata | `coverage` | DESCRIPTION carries `X-schema.org-spatialCoverage` and `X-schema.org-temporalCoverage` |
| metadata | `title_length` | `Title` has at most 65 characters |
| data | `data_present` | `data/` holds at least one `.rda` file that loads |
| data | `dictionary_present` | `data-raw/dictionary.csv` is present |
| data | `dictionary_coverage` | the dictionary covers every variable of every data object |
| data | `dictionary_descriptions` | no description is empty or a placeholder |
| data | `dictionary_schema` | the five washr columns in order, UTF-8 without a byte order mark, one class name per `variable_type` |
| docs | `roxygen_docs` | every data object has a help page in `man/` |
| docs | `readme` | `README.Rmd` and the rendered `README.md` are present |
| docs | `rd_source` | at least one help page in `man/` carries a source |
| docs | `readme_extdata_links` | `README.md` links a `.csv` or `.xlsx` file under `inst/extdata/` |
| docs | `readme_citation` | `README.md` names the DOI that `CITATION.cff` carries |
| docs | `vignettes_location` | no `.Rmd` or `.qmd` file sits directly in `vignettes/` |
| docs | `pkgdown_config` | `_pkgdown.yml` is present |
| docs | `pkgdown_analytics` | `_pkgdown.yml` carries the analytics header |
| docs | `pkgdown_url` | `url` in `_pkgdown.yml` is the Pages URL, not the repository URL |
| docs | `pkgdown_funding` | `_pkgdown.yml` carries the funding text of the organisation |
| docs | `pkgdown_brand` | the brand entry in `_pkgdown.yml` matches the organisation |
| docs | `pkgdown_llm_docs` | `_pkgdown.yml` does not switch off the `llms.txt` of the site (`llm-docs: false`) |
| docs | `docs_untracked` | git tracks no file under `docs/` while the pkgdown workflow deploys the site |
| tests | `check_workflow` | `.github/workflows/R-CMD-check.yaml` is present |
| tests | `check_workflow_dev` | every `branches:` list in that workflow includes `dev` |
| tests | `check_badge` | `README.Rmd` carries the R CMD check badge |

An item that cannot be decided is reported as not applicable, with the
reason: for example the version comparison when `CITATION.cff` is
missing, or the `docs/` item when the package has no pkgdown workflow.
Not applicable items never count against the package.

## Usage

``` r
check_publication_readiness(path = ".", profile = NULL)
```

## Arguments

- path:

  Path to the root of the data package. Defaults to the working
  directory.

- profile:

  A named list with what the organisation expects of its packages. With
  `NULL`, the default, the package is held to its own values: the
  `Config/washr/` fields in its DESCRIPTION that
  [`update_description()`](https://openwashdata.github.io/washr/reference/update_description.md)
  writes. A review tool passes the profile of the organisation instead.
  All entries are optional:

  - `license`: the license the package has to carry, `"CC BY 4.0"` by
    default, or `"any"` to accept every license that is set. A package
    of another organisation that is held to its own values gets `"any"`.

  - `analytics`: `"plausible"` (the default) or `"none"`. With `"none"`
    the analytics item is not applicable.

  - `site_url_pattern`: the Pages URL of a package, with `<package>` in
    place of the package name. Without it, any `github.io` URL passes.

  - `funding_text`: the funding sentence that `_pkgdown.yml` has to
    carry word for word. Without it, the funding item is not applicable.

  - `keywords_required`: keywords every package of the organisation has
    to carry.

  - `brand`: `"none"` when the organisation has no brand, or the name of
    its brand. Without it, the brand item is not applicable.

## Value

A data frame of class `washr_readiness`, invisibly, with one row per
item and the columns `id`, `area`, `check` (the item in words), `status`
(`"pass"`, `"fail"` or `"na"` for not applicable), `detail` (what was
found) and `fix` (the step that closes the gap). The attribute `ready`
is `TRUE` when no item fails, `washr_version` holds the installed washr
version, and `package` the name and version of the package that was
checked. Printing the object shows the report again.

## See also

Before: every step of the workflow, up to
[`update_citation()`](https://openwashdata.github.io/washr/reference/update_citation.md)
and
[`setup_website()`](https://openwashdata.github.io/washr/reference/setup_website.md).
Next: fix the items that fail and run it again, then release the
package.

Other publishing functions:
[`setup_readme()`](https://openwashdata.github.io/washr/reference/setup_readme.md),
[`setup_website()`](https://openwashdata.github.io/washr/reference/setup_website.md),
[`use_brand()`](https://openwashdata.github.io/washr/reference/use_brand.md)

## Examples

``` r
if (FALSE) { # \dontrun{
check_publication_readiness()

# Keep the result and work with the items that fail
readiness <- check_publication_readiness()
readiness[readiness$status == "fail", c("id", "detail", "fix")]
attr(readiness, "ready")
} # }
```
