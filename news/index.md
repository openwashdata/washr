# Changelog

## washr (development version)

- New
  [`use_brand()`](https://openwashdata-dev.github.io/washr/reference/use_brand.md)
  installs the openwashdata brand (`_brand.yml` and the logo files it
  references) from the central openwashdata/brand repository into the
  active package, refreshes an existing copy idempotently, and wires an
  existing `_pkgdown.yml` to the brand through bslib so the package site
  renders with the brand fonts and colors
  ([\#109](https://github.com/openwashdata/washr/issues/109)).

- [`setup_readme()`](https://openwashdata-dev.github.io/washr/reference/setup_readme.md)
  no longer writes a dead license link. The README template carried the
  package name placeholder in URL encoded form, so whisker never
  substituted it and every generated README linked to
  `.../%7B%7B%7Bpackagename%7D%7D%7D/blob/main/LICENSE.md`
  ([\#101](https://github.com/openwashdata/washr/issues/101)).

- [`update_citation()`](https://openwashdata-dev.github.io/washr/reference/update_citation.md)
  adds `CITATION.cff` to `.Rbuildignore`, so `R CMD check` no longer
  reports a non-standard file at the top level of the data package. cffr
  only adds the entry itself when handed a file path, and washr hands it
  a cff object
  ([\#102](https://github.com/openwashdata/washr/issues/102)).

## washr 1.0.2

CRAN release: 2026-07-26

Patch release: bug fixes only, no new API. New maintainer: Lars
Schöbitz.

- [`update_citation()`](https://openwashdata-dev.github.io/washr/reference/update_citation.md)
  no longer requires a `doi` argument; calling it without one generates
  the citation files without a DOI, for use before a release exists
  ([\#57](https://github.com/openwashdata/washr/issues/57)).
- `update_citation(doi = NULL)` no longer injects a broken empty DOI
  badge into README.Rmd. Re-running with a DOI replaces an existing
  badge instead of duplicating it, heals a broken empty badge left by
  earlier versions, and a missing `<!-- badges: end -->` marker now
  gives a clear error
  ([\#58](https://github.com/openwashdata/washr/issues/58)).
- [`update_description()`](https://openwashdata-dev.github.io/washr/reference/update_description.md)
  preserves existing `URL` and `Config/Needs/website` entries and merges
  them with the openwashdata defaults instead of replacing them
  ([\#59](https://github.com/openwashdata/washr/issues/59),
  [\#63](https://github.com/openwashdata/washr/issues/63)).
- [`update_description()`](https://openwashdata-dev.github.io/washr/reference/update_description.md)
  no longer overwrites an existing license; CC BY 4.0 is only set when
  the package has no license yet
  ([\#63](https://github.com/openwashdata/washr/issues/63)).
- [`update_description()`](https://openwashdata-dev.github.io/washr/reference/update_description.md)
  honors its `file` argument when checking for the DESCRIPTION file
  ([\#63](https://github.com/openwashdata/washr/issues/63)).
- [`update_citation()`](https://openwashdata-dev.github.io/washr/reference/update_citation.md)
  cleans up the `*.bk1` backup files that cffr leaves behind when
  overwriting `CITATION.cff` and `inst/CITATION`
  ([\#60](https://github.com/openwashdata/washr/issues/60)).
- [`setup_readme()`](https://openwashdata-dev.github.io/washr/reference/setup_readme.md)
  no longer deletes an existing README.Rmd; it stops with an error
  unless the new `force = TRUE` argument is passed
  ([\#64](https://github.com/openwashdata/washr/issues/64)).

## washr 1.0.1

CRAN release: 2024-11-07

- Implementing reviewer’s comments, resubmission to CRAN

## washr 1.0.0

- Initial CRAN submission.
