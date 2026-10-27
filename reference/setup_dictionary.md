# Create a dictionary file for tidy data sets

`setup_dictionary()` generates a dictionary CSV file in the `data/`
directory. The dictionary file contains information on the tidy data
sets such as directory, file names, variable names, variable types, and
descriptions. If tidy data exists, the dictionary is populated with
relevant information; otherwise, it creates an empty dictionary CSV
file.

## Usage

``` r
setup_dictionary()
```

## Value

The path of the dictionary file, invisibly. Error if raw data is not
found or not in a package directory.

## See also

Before:
[`setup_rawdata()`](https://openwashdata.github.io/washr/reference/setup_rawdata.md).
Next:
[`setup_roxygen()`](https://openwashdata.github.io/washr/reference/setup_roxygen.md)
once the descriptions in `data-raw/dictionary.csv` are written. When the
data changes later,
[`update_dictionary()`](https://openwashdata.github.io/washr/reference/update_dictionary.md)
brings the dictionary in line with it and keeps the descriptions.

Other setup functions:
[`setup_ci()`](https://openwashdata.github.io/washr/reference/setup_ci.md),
[`setup_rawdata()`](https://openwashdata.github.io/washr/reference/setup_rawdata.md),
[`setup_roxygen()`](https://openwashdata.github.io/washr/reference/setup_roxygen.md),
[`update_dictionary()`](https://openwashdata.github.io/washr/reference/update_dictionary.md)

## Examples

``` r
if (FALSE) { # \dontrun{
setup_rawdata()
# Go to data_processing.R, clean the raw data and export tidy data
setup_dictionary()
} # }
```
