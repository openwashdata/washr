# Function to create a JSON-LD document from available metadata

This function follows a standard JSON-LD template and autopopulates it
with metadata from the dataset. The function checks for appropriate
files being available before executing. The JSON-LD document is saved to
the metadata folder.

## Usage

``` r
generate_jsonld()
```

## Value

NULL. Error messages are displayed if dictionary or metadata files are
not found.

## Examples

``` r
if (FALSE) { # \dontrun{
generate_jsonld()
} # }
```
