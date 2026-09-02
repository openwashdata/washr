# Generate the README RMarkdown file

`setup_readme()` uses the openwashdata README template to generate
README files based on datasets retrieved from the `data/` directory. It
helps in creating consistent and informative README documentation for
your data packages.

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

NULL. This function creates a README.Rmd under the package directory.

## See also

Before:
[`update_description()`](https://openwashdata.github.io/washr/reference/update_description.md).
Next:
[`setup_website()`](https://openwashdata.github.io/washr/reference/setup_website.md),
which builds the site from README.md.

Other publishing functions:
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
