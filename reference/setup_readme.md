# Generate the README RMarkdown file

`setup_readme()` uses the openwashdata README template to generate
README files based on datasets retrieved from the `data/` directory. It
helps in creating consistent and informative README documentation for
your data packages. The repository links, the install line and the
license come from DESCRIPTION, so run
[`update_description()`](https://openwashdata.github.io/washr/reference/update_description.md)
first.

The Citation section states in plain text which version to cite with
which DOI, links the authors page of the site and `CITATION.cff`, and
names the source article of republished data from
`X-schema.org-isBasedOn`. The download links point at the release tag of
the version in DESCRIPTION, and at the main branch for a development
version. pkgdown builds the `llms.txt` of the site from the README, so
this is also what AI tools read about the package.

The template documents the first data object in `data/`
(alphabetically); add a section per further object by hand. It stops
when `data/` holds no data object, because every data section needs one.

## Usage

``` r
setup_readme(force = FALSE, has_example = FALSE)
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
[`setup_website()`](https://openwashdata.github.io/washr/reference/setup_website.md),
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
} # }
```
