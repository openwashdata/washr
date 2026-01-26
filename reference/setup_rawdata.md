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

## Examples

``` r
if (FALSE) { # \dontrun{
  setup_rawdata()
} # }
```
