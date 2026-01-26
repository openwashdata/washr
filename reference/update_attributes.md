# Update metadata attributes file

Updates the attributes file in the metadata folder with data from the
dictionary file in the data-raw folder. This file is esentially a copy
of the dictionary file. If the dictionary file does not exist, the user
is asked to create it first. Always overwrites existing attributes file
with the latest dictionary file.

## Usage

``` r
update_attributes()
```

## Value

NULL. Error if dictionary file is not found.

## Examples

``` r
if (FALSE) { # \dontrun{
update_attributes()
} # }
```
