# Set up the R CMD check workflow for the data package

`setup_ci()` writes the GitHub Actions workflow that runs `R CMD check`
on every push and pull request to `main` and `dev`, on macOS, Windows
and three versions of R on Linux. The openwashdata review standard
requires this workflow with the `dev` trigger, so a package scaffolded
with washr passes that part of the review floor by construction.

The workflow lands in `.github/workflows/R-CMD-check.yaml` and `.github`
is added to `.Rbuildignore`. When `README.Rmd` exists with badge
markers, the matching R CMD check badge is added between them (the
README template from
[`setup_readme()`](https://openwashdata.github.io/washr/reference/setup_readme.md)
carries it already). An existing workflow file is kept as it is, so the
function is safe to run again.

## Usage

``` r
setup_ci()
```

## Value

The path of the workflow file, invisibly.

## See also

Next:
[`setup_rawdata()`](https://openwashdata.github.io/washr/reference/setup_rawdata.md).
The badge appears in the README written by
[`setup_readme()`](https://openwashdata.github.io/washr/reference/setup_readme.md).

Other setup functions:
[`setup_dictionary()`](https://openwashdata.github.io/washr/reference/setup_dictionary.md),
[`setup_rawdata()`](https://openwashdata.github.io/washr/reference/setup_rawdata.md),
[`setup_roxygen()`](https://openwashdata.github.io/washr/reference/setup_roxygen.md)

## Examples

``` r
if (FALSE) { # \dontrun{
setup_ci()
} # }
```
