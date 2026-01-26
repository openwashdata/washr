# Generate roxygen2 documentation from a CSV file

This function takes a CSV table with columns `variable_name` and
`description` as input, optionally filters it by `variable_name`, and
outputs roxygen2 documentation for `\describe` and `\item`.

## Usage

``` r
generate_roxygen_docs(input_file_path, output_file_path, df_name = NULL)
```

## Arguments

- input_file_path:

  Path to the input CSV file.

- output_file_path:

  Path to the output file that will contain the roxygen2 documentation.

- df_name:

  Optional name of the variable to filter the input dataframe by.
  Default is NULL.

## Value

Character string of a generated roxygen documentation.

## Examples

``` r
if (FALSE) { # \dontrun{
# Generate roxygen2 documentation from example.csv
generate_roxygen_docs("example.csv", "output.R")
# Generate roxygen2 documentation from example.csv for a specific variable name
generate_roxygen_docs("example.csv", "output.R", df_name = "specific_variable")
} # }
```
