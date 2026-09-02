# Install or refresh the openwashdata brand in the active package

`use_brand()` copies the openwashdata brand definition (`_brand.yml`)
and the logo files it references from the central
[openwashdata/brand](https://github.com/openwashdata/brand) repository
into the package root. Re-running the function refreshes an existing
copy and reports which files changed, so consuming packages stay in sync
with the central definition.

Brand values are never edited locally: change them in openwashdata/brand
first, then refresh consumers with `use_brand()`.

## Usage

``` r
use_brand(ref = "main", pkgdown = TRUE, source = NULL)
```

## Arguments

- ref:

  Character. Git reference (branch or tag) of openwashdata/brand to copy
  from. Defaults to `"main"`.

- pkgdown:

  Logical. Should `_pkgdown.yml` be wired to use the brand via bslib?
  Defaults to `TRUE`.

- source:

  Character. Advanced: an alternative source for the brand files, either
  a local directory or a URL prefix. When `NULL` (the default), the raw
  GitHub content of openwashdata/brand at `ref` is used. Mainly useful
  for tests and offline work.

## Value

Invisibly, a character vector of the files written or updated (empty
when everything was already current).

## Details

With `pkgdown = TRUE` (the default), an existing `_pkgdown.yml` is
pointed at the brand through bslib (`template.bslib.brand`), so the next
[`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html)
renders the site with the brand fonts and colors. The wiring rewrites
`_pkgdown.yml` through the yaml package, which does not preserve
comments in that file. When no `_pkgdown.yml` exists, the wiring is
skipped with a hint to run
[`setup_website()`](https://openwashdata-dev.github.io/washr/reference/setup_website.md)
first. Building the wired site requires the brand.yml package (bslib
asks for it at build time); it is listed in Suggests and installed on
demand.

## Examples

``` r
if (FALSE) { # \dontrun{
# Install the brand and wire the pkgdown site
use_brand()

# Refresh later, without touching _pkgdown.yml
use_brand(pkgdown = FALSE)
} # }
```
