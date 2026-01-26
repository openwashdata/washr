# Set up a pkgdown website for the data package

`setup_website()` uses the openwashdata pkgdown template to create a
website for the data package based on its README.md file. The website
provides a structured and visually appealing presentation of the
package's documentation.

## Usage

``` r
setup_website(has_example = FALSE)
```

## Arguments

- has_example:

  Logical. Should the pkgdown website include a vignette page for
  writing an example? Defaults to FALSE.

## Value

NULL. Error if no README file is found.

## Examples

``` r
if (FALSE) { # \dontrun{
# Set up the pkgdown website including a vignette page
 setup_website(has_example = TRUE)
} # }
```
