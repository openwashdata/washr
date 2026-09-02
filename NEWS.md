# washr (development version)

- New `use_brand()` installs the openwashdata brand (`_brand.yml` and the
  logo files it references) from the central openwashdata/brand repository
  into the active package, refreshes an existing copy idempotently, and
  wires an existing `_pkgdown.yml` to the brand through bslib so the
  package site renders with the brand fonts and colors (#109).

- `setup_readme()` no longer writes a dead license link. The README template
  carried the package name placeholder in URL encoded form, so whisker never
  substituted it and every generated README linked to
  `.../%7B%7B%7Bpackagename%7D%7D%7D/blob/main/LICENSE.md` (#101).

- `update_citation()` adds `CITATION.cff` to `.Rbuildignore`, so `R CMD check`
  no longer reports a non-standard file at the top level of the data package.
  cffr only adds the entry itself when handed a file path, and washr hands it
  a cff object (#102).

- `update_gsheet_metadata()` is removed. It appended a row to a private
  openwashdata Google Sheet, needed interactive Google authentication, and
  never shipped on CRAN. googlesheets4 leaves Imports with it. The catalogue
  update becomes org-internal tooling outside the package (#69).

- `update_metadata()` is rewritten as the one FAIR step (lifecycle:
  experimental). It derives a schema.org Dataset description from
  DESCRIPTION, `data-raw/dictionary.csv`, `CITATION.cff` and the files in
  `inst/extdata`, writes it as JSON-LD into `pkgdown/templates/in-header.html`
  so every page of the site carries it, and ends by listing the fields it
  could not fill. Spatial and temporal coverage and keywords live in
  DESCRIPTION as `X-schema.org-spatialCoverage`,
  `X-schema.org-temporalCoverage` and `X-schema.org-keywords`. It no longer
  calls the dataspice helpers, creates no `data/metadata` folder, and writes
  no `inst/extdata/metadata.json`; existing copies of both are ignored.
  `generate_jsonld()` is no longer exported (it is the internal builder), and
  lubridate leaves Imports (#68, #70, #67).

- The dataspice helpers are removed: `add_metadata()`, `add_creator()`,
  `update_access()`, `update_attributes()` and `update_biblio()`. None of
  them shipped on CRAN. `update_metadata()` replaced their output, and a
  package that still carries `data/metadata/` keeps it; washr ignores the
  folder. `fill_dictionary()` and `generate_roxygen_docs()` are no longer
  exported; `setup_dictionary()` and `setup_roxygen()` call them. The export
  surface is now nine functions. dataspice, dplyr, readr, stringr and tibble
  leave Imports with the removed code (#71, #100, #72).

- devtools moves from Imports to Suggests. `update_citation()` still rebuilds
  README.md through `devtools::build_readme()`, because the README loads the
  data package, and asks to install devtools when it is missing; the site
  rebuild calls `pkgdown::build_site()` directly. `setup_website()` no longer
  renders the example article on its own, since the site build renders it.
  The version constraint on utils is dropped; utils is a base package and the
  constraint silently required R 4.3.3. With the seven packages removed by
  the FAIR layer work, Imports go from 16 to 10 (#72).

- Idempotency and ergonomics sweep of the core (#73). Every function that
  rewrites a file follows read-merge-write and is safe to re-run:
  - `setup_website()` keeps an existing `_pkgdown.yml` as it is and only
    rebuilds the site, so the guide's "answer No when prompted" step goes
    away; it no longer crashes without a `.gitignore`; and it leaves `docs`
    ignored when a pkgdown workflow deploys the site, or when the new
    `track_docs = FALSE` argument says so (#104). The example article is
    created once.
  - The `_pkgdown.yml` template carries the Pages URL as the site URL, the
    explanatory comments, and a reference index with one entry per data
    object, matching the openwashdata review standard's template.
  - `update_citation()` re-run without a `doi` keeps the DOI already on
    file instead of dropping it, moves keywords typed into `CITATION.cff` by
    hand to `X-schema.org-keywords` in DESCRIPTION (their canonical home,
    from where cffr carries them forward), and rebuilds the README only when
    the badge changes.
  - `setup_roxygen()` re-run regenerates only the `@format` block and keeps
    everything below it (`@source`, `@examples`, and other text), writes
    nothing when the result is unchanged, and errors clearly when a file has
    no `@format` line instead of crashing.
  - `setup_dictionary()` records the first class of multi-class columns
    (`POSIXct`, `ordered`, `Date`) instead of a deparsed vector.
  - Loading a `.rda` file with several objects, or a file that is not an
    `.rda`, now errors with the file name and the reason instead of
    documenting the first object or crashing.

- `setup_readme()` gains `has_example`, the argument the guide documents.
  With `has_example = TRUE` the README carries an Example section with a
  commented ggplot2 scaffold for a first plot, pairing with the argument of
  the same name on `setup_website()`. The function now stops with a clear
  message when `data/` holds no data object instead of writing a README with
  `NA` in it, and says which data object the template documents when there
  are several (#74, supersedes #24).

- Test bar (#75). Every export has a behavioral test that asserts on file
  content or output; every `expect_error()` names its message; the
  `setup_rawdata()` tests check the rendered template. `update_citation()`
  gains `build`, so scripts and tests can regenerate the citation files
  without the README and site rebuilds. The r-lib test coverage workflow
  reports coverage to Codecov on every push and pull request.

# washr 1.0.2

Patch release: bug fixes only, no new API. New maintainer: Lars Schöbitz.

- `update_citation()` no longer requires a `doi` argument; calling it without
  one generates the citation files without a DOI, for use before a release
  exists (#57).
- `update_citation(doi = NULL)` no longer injects a broken empty DOI badge
  into README.Rmd. Re-running with a DOI replaces an existing badge instead
  of duplicating it, heals a broken empty badge left by earlier versions,
  and a missing `<!-- badges: end -->` marker now gives a clear error (#58).
- `update_description()` preserves existing `URL` and `Config/Needs/website`
  entries and merges them with the openwashdata defaults instead of
  replacing them (#59, #63).
- `update_description()` no longer overwrites an existing license; CC BY 4.0
  is only set when the package has no license yet (#63).
- `update_description()` honors its `file` argument when checking for the
  DESCRIPTION file (#63).
- `update_citation()` cleans up the `*.bk1` backup files that cffr leaves
  behind when overwriting `CITATION.cff` and `inst/CITATION` (#60).
- `setup_readme()` no longer deletes an existing README.Rmd; it stops with
  an error unless the new `force = TRUE` argument is passed (#64).

# washr 1.0.1

- Implementing reviewer's comments, resubmission to CRAN

# washr 1.0.0

-   Initial CRAN submission.
