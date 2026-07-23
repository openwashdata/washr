# washr (development version)

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
