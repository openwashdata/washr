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

NULL. Error if raw data is not found or not in a package directory.

## Examples

``` r
#> ✔ Setting active project to "/tmp/RtmprKHluX".
#> ✔ Creating R/.
#> ✔ Writing DESCRIPTION.
#> Package: RtmprKHluX
#> Title: What the Package Does (One Line, Title Case)
#> Version: 0.0.0.9000
#> Authors@R (parsed):
#>     * First Last <first.last@example.com> [aut, cre]
#> Description: What the package does (one paragraph).
#> License: `use_mit_license()`, `use_gpl3_license()` or friends to
#>     pick a license
#> Encoding: UTF-8
#> Roxygen: list(markdown = TRUE)
#> RoxygenNote: 7.3.3
#> ✔ Writing NAMESPACE.
#> ✔ Setting active project to "<no active project>".
if (FALSE) { # \dontrun{
setup_rawdata()
# Go to data_processing.R, clean the raw data and export tidy data
setup_dictionary()
} # }
```
