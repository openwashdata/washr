# Set up roxygen documentation for all tidy data sets using the dictionary

Creates or updates Roxygen documentation for all tidy data sets found in
the dictionary file.

When first run, this function creates the Roxygen documentation with
placeholders for the title and description field. The dictionary should
include columns for directory, file name, variable name, variable type,
and description. This function generates Roxygen comments with this
information, facilitating consistent and thorough documentation for your
data sets.

When re-run this function, this function updates only the variable
description entries in the Roxygen documentation files within R/
directory. The title and description fields remain unchanged.

## Usage

``` r
setup_roxygen()
```

## Value

NULL. This function creates documentation files inside "R/". Error if
tidy data cannot be found.

## See also

Before:
[`setup_dictionary()`](https://openwashdata.github.io/washr/reference/setup_dictionary.md).
Next:
[`update_description()`](https://openwashdata.github.io/washr/reference/update_description.md).

Other setup functions:
[`setup_dictionary()`](https://openwashdata.github.io/washr/reference/setup_dictionary.md),
[`setup_rawdata()`](https://openwashdata.github.io/washr/reference/setup_rawdata.md)

## Examples

``` r
if (FALSE) { # \dontrun{
setup_dictionary()
# Once the dictionary is created, go to data-raw/dictionary.csv and complete the column description.
setup_roxygen()
} # }
```
