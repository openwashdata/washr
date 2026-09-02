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
update_description(
  file = ".",
  github_user = "https://github.com/openwashdata/"
)
```

## Arguments

- file:

  Character. The file path to the DESCRIPTION file of the R package.
  Defaults to the current working directory.

- github_user:

  Character. The URL path to the GitHub user or organization that hosts
  the current package. Defaults to "https://github.com/openwashdata".

## Value

NULL. Update fields directly in DESCRIPTION file.

## See also

Before:
[`setup_roxygen()`](https://openwashdata.github.io/washr/reference/setup_roxygen.md).
Next:
[`update_metadata()`](https://openwashdata.github.io/washr/reference/update_metadata.md)
for the schema.org metadata, then
[`setup_readme()`](https://openwashdata.github.io/washr/reference/setup_readme.md).

Other metadata functions:
[`update_citation()`](https://openwashdata.github.io/washr/reference/update_citation.md),
[`update_metadata()`](https://openwashdata.github.io/washr/reference/update_metadata.md)

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
