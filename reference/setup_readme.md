# Generate the README RMarkdown file

`setup_readme()` uses the openwashdata README template to generate
README files based on datasets retrieved from the `data/` directory. It
helps in creating consistent and informative README documentation for
your data packages. The repository links, the install line and the
license come from DESCRIPTION, so run
[`update_description()`](https://openwashdata.github.io/washr/reference/update_description.md)
first.

The Citation section names the publisher with its website, states in
plain text which version to cite with which DOI, links the authors page
of the site and `CITATION.cff`, and names the source article of
republished data from `X-schema.org-isBasedOn`. When the package names
its site (the `url` of `_pkgdown.yml` or a site entry in the DESCRIPTION
`URL` field), the section also links `metadata.jsonld` on the site, the
schema.org metadata that
[`update_metadata()`](https://openwashdata.github.io/washr/reference/update_metadata.md)
writes, so the link reaches the `llms.txt` of the site. When
[`use_brand()`](https://openwashdata.github.io/washr/reference/use_brand.md)
has installed the logo (`man/figures/logo.png`), the title line shows
it, linked to the website of the organisation. The download links point
at the release tag of the version in DESCRIPTION, and at the main branch
for a development version. pkgdown builds the `llms.txt` of the site
from the README, so this is also what AI tools read about the package.

The Data section has one section per data object: a preview of the first
rows and the table of its variables from `data-raw/dictionary.csv`.
Without `datasets`, every data object in `data/` gets a section, in
alphabetical order. With several objects the introduction of the Data
section names their number. The Example section, with
`has_example = TRUE`, starts from the first object. An object without
rows in the dictionary gets a warning, because its table of variables
would be empty. The function stops when `data/` holds no data object,
because every data section needs one.

## Usage

``` r
setup_readme(force = FALSE, has_example = FALSE, datasets = NULL)
```

## Arguments

- force:

  Logical. If FALSE (the default), the function stops when a README.Rmd
  already exists. Set to TRUE to overwrite the existing file.

- has_example:

  Logical. Should the README include an Example section with a commented
  ggplot2 scaffold for a first plot of the data? Defaults to FALSE.
  Pairs with the `has_example` argument of
  [`setup_website()`](https://openwashdata.github.io/washr/reference/setup_website.md),
  which adds the matching article to the site.

- datasets:

  Character vector. The data objects in `data/` that get a section, in
  this order, such as `c("trips", "trucks")`. The default `NULL` takes
  every data object in `data/`, alphabetically. A name that is not a
  data object in `data/` stops the run.

## Value

The path of README.Rmd, invisibly.

## See also

Before:
[`update_description()`](https://openwashdata.github.io/washr/reference/update_description.md).
Next:
[`setup_website()`](https://openwashdata.github.io/washr/reference/setup_website.md),
which builds the site from README.md.

Other publishing functions:
[`check_publication_readiness()`](https://openwashdata.github.io/washr/reference/check_publication_readiness.md),
[`data_availability_statement()`](https://openwashdata.github.io/washr/reference/data_availability_statement.md),
[`setup_website()`](https://openwashdata.github.io/washr/reference/setup_website.md),
[`update_website()`](https://openwashdata.github.io/washr/reference/update_website.md),
[`use_brand()`](https://openwashdata.github.io/washr/reference/use_brand.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Generate the README file after setting up the dictionary
setup_dictionary()
# Complete and save the dictionary CSV file with variable descriptions
setup_readme()
# With an Example section to fill with a first plot
setup_readme(has_example = TRUE)
# Sections for two of the data objects only
setup_readme(datasets = c("trips", "trucks"))
} # }
```
