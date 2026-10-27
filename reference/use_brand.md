# Install or refresh the openwashdata brand in the active package

`use_brand()` copies the openwashdata brand definition (`_brand.yml`)
and the logo files it references from the central
[openwashdata/brand](https://github.com/openwashdata/brand) repository
into the package root. Re-running the function refreshes an existing
copy and reports which files changed, so consuming packages stay in sync
with the central definition.

Brand values are never edited locally: change them in openwashdata/brand
first and cut a release tag there, then refresh consumers with
`use_brand()`. After a brand release the order is the Quarto extension,
the website, then the data packages.

By default the brand is copied at the latest release tag of the brand
repository, and the tag is recorded in DESCRIPTION as
`Config/washr/brand`, so the package says which brand it carries. A
second run with no new tag changes no file. The brand repository is the
`Config/washr/brand-source` field that
[`update_description()`](https://openwashdata.github.io/washr/reference/update_description.md)
writes (`openwashdata/brand` for openwashdata packages); a group with
its own brand names its repository there, and `none` means there is no
brand to install.

The brand file and the logo directory are added to `.Rbuildignore`, so
they stay out of the built package and `R CMD check` does not report
them as non-standard top-level files.

## Usage

``` r
use_brand(ref = NULL, pkgdown = TRUE, source = NULL)
```

## Arguments

- ref:

  Character. Git reference (branch or tag) of the brand repository to
  copy from. Defaults to the latest release tag. Pass `"main"` to try
  brand changes that are not released yet.

- pkgdown:

  Logical. Should `_pkgdown.yml` be wired to use the brand via bslib?
  Defaults to `TRUE`.

- source:

  Character. Advanced: an alternative source for the brand files, either
  a local directory or a URL prefix. When `NULL` (the default), the raw
  GitHub content of the brand repository at `ref` is used. Mainly useful
  for tests and offline work.

## Value

Invisibly, a character vector of the files written or updated (empty
when everything was already current).

## Details

With `pkgdown = TRUE` (the default), an existing `_pkgdown.yml` is
pointed at the brand through bslib (`template.bslib.brand`), so the next
[`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html)
renders the site with the brand fonts and colors. The wiring adds its
lines to `_pkgdown.yml` and leaves the rest of the file, comments
included, as it is. Only when the `template` block already carries other
bslib settings, or is written on one line, is the file rewritten through
the yaml package, which does not preserve comments. When no
`_pkgdown.yml` exists, the wiring is skipped with a hint to run
[`setup_website()`](https://openwashdata.github.io/washr/reference/setup_website.md)
first. Building the wired site requires the brand.yml package (bslib
asks for it at build time); it is listed in Suggests and installed on
demand.

## See also

Before:
[`setup_website()`](https://openwashdata.github.io/washr/reference/setup_website.md),
which writes the `_pkgdown.yml` this wires. For branded PDF and Word
reports that read the installed `_brand.yml`, the openwashdata Quarto
extension [quarto-owd](https://github.com/openwashdata/quarto-owd).

Other publishing functions:
[`check_publication_readiness()`](https://openwashdata.github.io/washr/reference/check_publication_readiness.md),
[`setup_readme()`](https://openwashdata.github.io/washr/reference/setup_readme.md),
[`setup_website()`](https://openwashdata.github.io/washr/reference/setup_website.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Install the brand and wire the pkgdown site
use_brand()

# Refresh later, without touching _pkgdown.yml
use_brand(pkgdown = FALSE)
} # }
```
