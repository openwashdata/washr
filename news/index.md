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

- `update_gsheet_metadata()` is removed. It appended a row to a private
  openwashdata Google Sheet, needed interactive Google authentication,
  and never shipped on CRAN. googlesheets4 leaves Imports with it. The
  catalogue update becomes org-internal tooling outside the package
  ([\#69](https://github.com/openwashdata/washr/issues/69)).

- [`update_metadata()`](https://openwashdata-dev.github.io/washr/reference/update_metadata.md)
  is rewritten as the one FAIR step (lifecycle: experimental). It
  derives a schema.org Dataset description from DESCRIPTION,
  `data-raw/dictionary.csv`, `CITATION.cff` and the files in
  `inst/extdata`, writes it as JSON-LD into
  `pkgdown/templates/in-header.html` so every page of the site carries
  it, and ends by listing the fields it could not fill. Spatial and
  temporal coverage and keywords live in DESCRIPTION as
  `X-schema.org-spatialCoverage`, `X-schema.org-temporalCoverage` and
  `X-schema.org-keywords`. It no longer calls the dataspice helpers,
  creates no `data/metadata` folder, and writes no
  `inst/extdata/metadata.json`; existing copies of both are ignored.
  `generate_jsonld()` is no longer exported (it is the internal
  builder), and lubridate leaves Imports
  ([\#68](https://github.com/openwashdata/washr/issues/68),
  [\#70](https://github.com/openwashdata/washr/issues/70),
  [\#67](https://github.com/openwashdata/washr/issues/67)).

- The dataspice helpers are removed: `add_metadata()`, `add_creator()`,
  `update_access()`, `update_attributes()` and `update_biblio()`. None
  of them shipped on CRAN.
  [`update_metadata()`](https://openwashdata-dev.github.io/washr/reference/update_metadata.md)
  replaced their output, and a package that still carries
  `data/metadata/` keeps it; washr ignores the folder.
  [`fill_dictionary()`](https://openwashdata-dev.github.io/washr/reference/fill_dictionary.md)
  and
  [`generate_roxygen_docs()`](https://openwashdata-dev.github.io/washr/reference/generate_roxygen_docs.md)
  are no longer exported;
  [`setup_dictionary()`](https://openwashdata-dev.github.io/washr/reference/setup_dictionary.md)
  and
  [`setup_roxygen()`](https://openwashdata-dev.github.io/washr/reference/setup_roxygen.md)
  call them. The export surface is now nine functions. dataspice, dplyr,
  readr, stringr and tibble leave Imports with the removed code
  ([\#71](https://github.com/openwashdata/washr/issues/71),
  [\#100](https://github.com/openwashdata/washr/issues/100),
  [\#72](https://github.com/openwashdata/washr/issues/72)).

- devtools moves from Imports to Suggests.
  [`update_citation()`](https://openwashdata-dev.github.io/washr/reference/update_citation.md)
  still rebuilds README.md through
  [`devtools::build_readme()`](https://devtools.r-lib.org/reference/build_readme.html),
  because the README loads the data package, and asks to install
  devtools when it is missing; the site rebuild calls
  [`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html)
  directly.
  [`setup_website()`](https://openwashdata-dev.github.io/washr/reference/setup_website.md)
  no longer renders the example article on its own, since the site build
  renders it. The version constraint on utils is dropped; utils is a
  base package and the constraint silently required R 4.3.3. With the
  seven packages removed by the FAIR layer work, Imports go from 16 to
  10 ([\#72](https://github.com/openwashdata/washr/issues/72)).

- Idempotency and ergonomics sweep of the core
  ([\#73](https://github.com/openwashdata/washr/issues/73)). Every
  function that rewrites a file follows read-merge-write and is safe to
  re-run:

  - [`setup_website()`](https://openwashdata-dev.github.io/washr/reference/setup_website.md)
    keeps an existing `_pkgdown.yml` as it is and only rebuilds the
    site, so the guide’s “answer No when prompted” step goes away; it no
    longer crashes without a `.gitignore`; and it leaves `docs` ignored
    when a pkgdown workflow deploys the site, or when the new
    `track_docs = FALSE` argument says so
    ([\#104](https://github.com/openwashdata/washr/issues/104)). The
    example article is created once.
  - The `_pkgdown.yml` template carries the Pages URL as the site URL,
    the explanatory comments, and a reference index with one entry per
    data object, matching the openwashdata review standard’s template.
  - [`update_citation()`](https://openwashdata-dev.github.io/washr/reference/update_citation.md)
    re-run without a `doi` keeps the DOI already on file instead of
    dropping it, moves keywords typed into `CITATION.cff` by hand to
    `X-schema.org-keywords` in DESCRIPTION (their canonical home, from
    where cffr carries them forward), and rebuilds the README only when
    the badge changes.
  - [`setup_roxygen()`](https://openwashdata-dev.github.io/washr/reference/setup_roxygen.md)
    re-run regenerates only the `@format` block and keeps everything
    below it (`@source`, `@examples`, and other text), writes nothing
    when the result is unchanged, and errors clearly when a file has no
    `@format` line instead of crashing.
  - [`setup_dictionary()`](https://openwashdata-dev.github.io/washr/reference/setup_dictionary.md)
    records the first class of multi-class columns (`POSIXct`,
    `ordered`, `Date`) instead of a deparsed vector.
  - Loading a `.rda` file with several objects, or a file that is not an
    `.rda`, now errors with the file name and the reason instead of
    documenting the first object or crashing.

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
