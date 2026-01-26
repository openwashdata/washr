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

## Examples

``` r
#> ✔ Setting active project to "/tmp/RtmprKHluX".
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
#> ✔ Setting active project to "<no active project>".
if (FALSE) { # \dontrun{
setup_dictionary()
# Once the dictionary is created, go to data-raw/dictionary.csv and complete the column description.
setup_roxygen()
} # }
```
