# Create the data-raw directory with a data-processing.R template

`setup_rawdata()` creates a directory for raw data and an example script
named `data_processing.R` for importing, processing and exporting the
tidy data. The template assumes that the dataset name is the same as the
data package name.

## Usage

``` r
setup_rawdata()
```

## Value

NULL. This function will create a directory "data-raw" under the package
directory.

## See also

Before:
[`setup_ci()`](https://openwashdata.github.io/washr/reference/setup_ci.md).
Next:
[`setup_dictionary()`](https://openwashdata.github.io/washr/reference/setup_dictionary.md)
once the processing script has exported the tidy data with
[`usethis::use_data()`](https://usethis.r-lib.org/reference/use_data.html).

Other setup functions:
[`setup_ci()`](https://openwashdata.github.io/washr/reference/setup_ci.md),
[`setup_dictionary()`](https://openwashdata.github.io/washr/reference/setup_dictionary.md),
[`setup_roxygen()`](https://openwashdata.github.io/washr/reference/setup_roxygen.md)

## Examples

``` r
if (FALSE) { # \dontrun{
  setup_rawdata()
} # }
```
