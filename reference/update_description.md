# Update the DESCRIPTION file to conform with openwashdata standards

This function updates the DESCRIPTION file of an R package to comply
with openwashdata standards. It ensures that fields such as `License`,
`Language`, `Date`, `URL`, and others are correctly specified. Existing
`URL` and `Config/Needs/website` entries are preserved and merged with
the openwashdata defaults. A CC BY 4.0 license is only set when the
package does not have a license yet; an existing license is left
untouched.

## Usage

``` r
update_description(file = ".", github_user = NULL)
```

## Arguments

- file:

  Character. The file path to the DESCRIPTION file of the R package.
  Defaults to the current working directory.

- github_user:

  Character. The URL of the GitHub user or organization that hosts the
  package, e.g., `"https://github.com/yourorg"`. Defaults to the
  organisation of the repository already listed in `URL`, and to
  `"https://github.com/openwashdata"` when `URL` lists none.

## Value

The path of the DESCRIPTION file, invisibly. The fields are updated in
the file.

## Details

DESCRIPTION is where the other functions read the facts of the package:
the GitHub organisation and the repository from `URL`, the license from
`License`, the people from `Authors@R`. The values that DESCRIPTION has
no standard field for are written as `Config/washr/` fields, and every
other function reads them from there:

|  |  |  |
|----|----|----|
| Field | Used for | openwashdata default |
| `Config/washr/funding` | the funding sentence in the sidebar of the site | the ETH Board Open Research Data Program |
| `Config/washr/analytics-domain` | the Plausible analytics header of the site | `openwashdata.github.io` |
| `Config/washr/doi-provider` | the DOI badge of the README | `zenodo` |
| `Config/washr/zenodo-community` | the community in `.zenodo.json` | `openwashdata` |
| `Config/washr/brand-source` | the GitHub repository [`use_brand()`](https://openwashdata.github.io/washr/reference/use_brand.md) copies from | `openwashdata/brand` |
| `Config/washr/version` | the washr version that last ran this function |  |

A field that you edited is never overwritten, so a group other than
openwashdata publishes with its own values by editing them. When
`github_user` names another organisation than the one in `URL`, the
repository in `URL` is replaced and the fields that still hold the
defaults of the old organisation follow. Set a field to `none` to switch
its feature off. For a package under another GitHub organisation the
funding, analytics, community and brand fields are written as `none`,
because the openwashdata values would be wrong there. One more field is
only ever written by hand: `Config/washr/pages-domain`, for a site that
is not served from `<organisation>.github.io`.

## See also

Before:
[`setup_roxygen()`](https://openwashdata.github.io/washr/reference/setup_roxygen.md).
Next:
[`update_metadata()`](https://openwashdata.github.io/washr/reference/update_metadata.md)
for the schema.org metadata, then
[`setup_readme()`](https://openwashdata.github.io/washr/reference/setup_readme.md).

Other metadata functions:
[`update_citation()`](https://openwashdata.github.io/washr/reference/update_citation.md),
[`update_metadata()`](https://openwashdata.github.io/washr/reference/update_metadata.md),
[`update_zenodo_json()`](https://openwashdata.github.io/washr/reference/update_zenodo_json.md)

## Examples

``` r
if (FALSE) { # \dontrun{
 # Update DESCRIPTION file in the current package
update_description()

 # Update DESCRIPTION file in a specific package
update_description(file = "path/to/your/package/DESCRIPTION")

 # Update DESCRIPTION file with a specific GitHub user
update_description(github_user = "https://github.com/yourusername")
} # }

```
