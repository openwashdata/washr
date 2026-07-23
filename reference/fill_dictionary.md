# Fill in the dictionary file based on the tidy data information

Fill in the dictionary file based on the tidy data information

## Usage

``` r
fill_dictionary(dict_path, data_dir)
```

## Arguments

- dict_path:

  Path to the dictionary csvfile.

- data_dir:

  Path to the directory of the tidy R data objects. Defaults to data/

## Value

A tibble data frame of dataset dictionary with an empty description
column to be written.

## Examples

``` r
if (FALSE) { # \dontrun{
fill_dictionary(dict_path = "data-raw/dictionary.csv", data_dir = "data/")
} # }
```
