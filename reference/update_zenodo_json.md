# Write the Zenodo metadata file of the data package

`update_zenodo_json()` writes `.zenodo.json` at the package root. Zenodo
reads this file when a GitHub release is archived and takes the metadata
of the record from it: the resource type (Dataset), the community, the
title, the description, the creators with their ORCID iDs, the license,
the keywords and the version. Without the file, Zenodo files a data
package as Software in no community, because its GitHub integration
reads only a few fields of `CITATION.cff`.

Nothing in the file is hand edited: to change a value, change its source
and run the function again. Running it twice produces no change.
[`update_citation()`](https://openwashdata.github.io/washr/reference/update_citation.md)
calls it, so the citation files and `.zenodo.json` are written in one
step and stay in line with each other.

The sources are:

|  |  |
|----|----|
| Key | Source |
| title, description, version | `Title`, `Description`, `Version` in DESCRIPTION |
| upload_type | always `dataset` |
| creators | `Authors@R` roles `aut` and `cre`; ORCID and affiliation from the `comment` field |
| license | `License` in DESCRIPTION, as the identifier Zenodo uses (e.g., `cc-by-4.0`) |
| keywords | `X-schema.org-keywords` in DESCRIPTION, comma separated |
| communities | `Config/washr/zenodo-community` in DESCRIPTION: `openwashdata` for an openwashdata package, none for another organisation until it sets one |
| related_identifiers | the source article DOIs in `X-schema.org-isBasedOn` in DESCRIPTION |

## Usage

``` r
update_zenodo_json()
```

## Value

The path of `.zenodo.json`, invisibly.

## Details

Zenodo uses `.zenodo.json` in place of `CITATION.cff` for the record,
and it reads the file from the release tag. Commit the file before you
create the release, and run the function again whenever DESCRIPTION
changes.

Set `Config/washr/zenodo-community` in DESCRIPTION to file the record in
another community, to several (comma separated), or to `none` for no
community.

A source article is written as a related identifier with the relation
`isDerivedFrom`. Zenodo then drops its own link to the release tag on
GitHub, so the repository from the `URL` field is added as a second
related identifier.

When washr does not know the license, the file carries none. Zenodo then
takes the license GitHub detects for the repository, and CC0 1.0 for a
dataset when GitHub detects none.

## See also

Before:
[`update_description()`](https://openwashdata.github.io/washr/reference/update_description.md),
which writes the DESCRIPTION fields this reads.
[`update_citation()`](https://openwashdata.github.io/washr/reference/update_citation.md)
calls this function. Next: the GitHub release that Zenodo archives.

Other metadata functions:
[`update_citation()`](https://openwashdata.github.io/washr/reference/update_citation.md),
[`update_description()`](https://openwashdata.github.io/washr/reference/update_description.md),
[`update_metadata()`](https://openwashdata.github.io/washr/reference/update_metadata.md)

## Examples

``` r
if (FALSE) { # \dontrun{
update_zenodo_json()
} # }
```
