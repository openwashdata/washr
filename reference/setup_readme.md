# Generate the README RMarkdown file

`setup_readme()` uses the openwashdata README template to generate
README files based on datasets retrieved from the `data/` directory. It
helps in creating consistent and informative README documentation for
your data packages.

## Usage

``` r
setup_readme(force = FALSE)
```

## Arguments

- force:

  Logical. If FALSE (the default), the function stops when a README.Rmd
  already exists. Set to TRUE to overwrite the existing file.

## Value

NULL. This function creates a README.Rmd under the package directory.

## Examples

``` r
if (FALSE) { # \dontrun{
# Generate the README file after setting up the dictionary
setup_dictionary()
# Complete and save the dictionary CSV file with variable descriptions
setup_readme()
} # }
```
