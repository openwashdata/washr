# Create the data-raw directory with a data-processing.R template

`setup_rawdata()` creates a directory for raw data and an example script
named `data_processing.R` for importing, processing and exporting the
tidy data. The export block of the script writes one
[`usethis::use_data()`](https://usethis.r-lib.org/reference/use_data.html)
line per dataset and then exports each dataset to `inst/extdata` as CSV
and XLSX in one loop over the names, for a single dataset as well.
Without `datasets`, the one dataset is named after the package.

## Usage

``` r
setup_rawdata(datasets = NULL)
```

## Arguments

- datasets:

  Character vector of the names of the tidy data objects the script
  exports, such as `c("trips", "trucks")`. The default `NULL` names one
  dataset after the package. Each name has to be a syntactically valid R
  name (`make.names(x) == x`), because it becomes an object in the
  script; the function stops otherwise. `data/` is not read: the names
  are the objects the script is about to create.

## Value

The path of the processing script, invisibly. The function creates the
directory "data-raw" under the package directory.

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
[`setup_roxygen()`](https://openwashdata.github.io/washr/reference/setup_roxygen.md),
[`update_dictionary()`](https://openwashdata.github.io/washr/reference/update_dictionary.md)

## Examples

``` r
if (FALSE) { # \dontrun{
  setup_rawdata()
  # A package with two datasets
  setup_rawdata(datasets = c("trips", "trucks"))
} # }
```
