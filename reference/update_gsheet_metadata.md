# Updates metadata google sheet automatically

This function updates the metadata google sheet with the values from
available metadata. Github username is required to update the maintainer
field.

## Usage

``` r
update_gsheet_metadata(github_profile = "")
```

## Arguments

- github_profile:

  Github username of the maintainer

## Value

NULL. Errors if metadata does not exist

## Examples

``` r
if (FALSE) { # \dontrun{
update_gsheet_metadata("githubusername")
} # }
```
