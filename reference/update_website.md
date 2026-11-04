# Bring an existing \_pkgdown.yml in line with the washr template

`update_website()` adds to an existing `_pkgdown.yml` what the washr
template has gained since the file was written, and refreshes what washr
owns: the footer with the washr version and the publisher sentence, the
link to the website of the organisation in the navbar, the funding and
the community blocks of the sidebar, and the Open Graph image when the
brand is installed. Everything else is kept as it is: the reference
index, hand edits, comments and the brand wiring of
[`use_brand()`](https://openwashdata.github.io/washr/reference/use_brand.md).
A file that is current is left untouched (#145).

The texts and links come from the `Config/washr/` fields in DESCRIPTION
that
[`update_description()`](https://openwashdata.github.io/washr/reference/update_description.md)
writes (`publisher`, `home`, `catalog`, `community`, `funding`); a field
set to `none` leaves its block out. The footer names the washr version
that last ran
[`update_description()`](https://openwashdata.github.io/washr/reference/update_description.md),
which also refreshes that line on its own.

Blocks written by hand are respected. A footer, a navbar or a sidebar
that already carries a component of the same name keeps it, and the
function adds only what is missing. The file is written only when the
result parses as YAML.

## Usage

``` r
update_website(build = FALSE)
```

## Arguments

- build:

  Logical. Rebuild the site with
  [`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html)
  when the file changed? Defaults to `FALSE`.

## Value

Invisibly, the names of the blocks that changed (`"footer"`, `"navbar"`,
`"sidebar"`, `"opengraph"`), or an empty vector when the file was
current.

## See also

Before:
[`setup_website()`](https://openwashdata.github.io/washr/reference/setup_website.md),
which writes a new `_pkgdown.yml` from the template, and
[`use_brand()`](https://openwashdata.github.io/washr/reference/use_brand.md),
which installs the brand this reads for the Open Graph image. Next:
[`check_publication_readiness()`](https://openwashdata.github.io/washr/reference/check_publication_readiness.md).

Other publishing functions:
[`check_publication_readiness()`](https://openwashdata.github.io/washr/reference/check_publication_readiness.md),
[`data_availability_statement()`](https://openwashdata.github.io/washr/reference/data_availability_statement.md),
[`setup_readme()`](https://openwashdata.github.io/washr/reference/setup_readme.md),
[`setup_website()`](https://openwashdata.github.io/washr/reference/setup_website.md),
[`use_brand()`](https://openwashdata.github.io/washr/reference/use_brand.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# After a washr update, bring the site configuration up to date
update_website()

# The same, and rebuild the site
update_website(build = TRUE)
} # }
```
