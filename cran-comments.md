## Version 1.3.0

Minor release. The maintainer is unchanged. It includes the changes of
1.2.1 and 1.2.2, which were released on GitHub only; the version on CRAN
is 1.2.0.

### Changes

- Two new exports: `data_availability_statement()`, which drafts the
  reference entry and the data availability statement for an article that
  uses a data package, and `update_website()` (from 1.2.1), which brings
  an existing `_pkgdown.yml` in line with the organisation profile.
- `setup_rawdata()` and `setup_readme()` handle packages with several
  datasets through a new `datasets` argument; the output for a single
  dataset is unchanged.
- `update_metadata()` writes the schema.org metadata also as a file on the
  package site, pins its download URLs to the release tag, and nests the
  parent organisations (with ROR identifiers) under the publisher.
- `update_zenodo_json()` links the package website in the Zenodo
  description and related identifiers.
- `update_description()` keeps an existing `Date` and sets it on purpose
  with a new `date` argument; `update_dictionary()` migrates older
  dictionary layouts.
- `check_publication_readiness()` gains items for the site metadata file,
  the ROR chain and whether the version follows changes to the data.
- clipr is a new suggested package, used only when
  `data_availability_statement(clipboard = TRUE)` is called and checked
  with `rlang::check_installed()`.

The new readiness item `version_follows_data` runs `git` on the package
directory; its tests create a temporary repository under `tempdir()` and
are skipped when git is not available. No test, example or vignette needs
the network.

The two ror.org addresses in the package (in code and documentation, not
as links in NEWS) answer automated requests with HTTP 429; they resolve
in a browser.

### R CMD check results

0 errors | 0 warnings | 0 notes

### Reverse dependencies

None on CRAN.

## Version 1.2.0

Minor release. The maintainer is unchanged. It includes the changes of
1.1.1, which was released on GitHub only; the version on CRAN is 1.1.0.

### Changes

- Three new exports: `check_publication_readiness()` (a read-only report of
  what a data package still lacks before publication), `update_dictionary()`
  and `update_zenodo_json()`.
- Messages go through cli, which is a new import. washr no longer calls the
  superseded `usethis::ui_*()` functions.
- Every exported function returns the path or paths it wrote, invisibly.
  Before, most returned `NULL`. The documentation states the new values.
- Two argument defaults changed: `use_brand(ref = )` from `"main"` to the
  latest release tag of the brand repository, and
  `update_description(github_user = )` from the openwashdata URL to the
  organisation already listed in `URL`.
- The values that were fixed to one organisation are read from DESCRIPTION
  (`URL`, `License`, and `Config/washr/` fields).
- From 1.1.1: `setup_ci()` writes the workflow file unchanged, `use_brand()`
  reads logo entries written as a list, and `update_citation()` gains a
  `type` argument.

`use_brand()` and `update_citation()` reach the network (GitHub, doi.org)
only when the user calls them. No test, example or vignette needs the
network, and every test writes under `tempdir()`.

### R CMD check results

0 errors | 0 warnings | 0 notes

### Reverse dependencies

None on CRAN.

## Version 1.1.1

Patch release: three fixes and one new argument with a default. Nothing is
removed and the maintainer is unchanged.

### Changes

- `setup_ci()` writes the GitHub Actions workflow file unchanged; the
  template renderer had stripped every `${{ }}` expression.
- `use_brand()` reads logo entries written as a list of path and alt text.
- `update_citation()` gains a `type` argument (default `"dataset"`) so
  CITATION.cff declares the work as a dataset instead of software.

### R CMD check results

0 errors | 0 warnings | 0 notes

### Reverse dependencies

None on CRAN.

## Version 1.1.0

First minor release. The maintainer is unchanged since 1.0.2.

### Changes

- Three new exports: `setup_ci()`, `use_brand()`, and `update_metadata()`,
  the last marked experimental with a lifecycle badge.
- Two exports that 1.0.2 documented as internal helpers, `fill_dictionary()`
  and `generate_roxygen_docs()`, are no longer exported; the functions that
  call them are unchanged. washr has no reverse dependencies on CRAN.
- Imports go from 16 to 10; devtools moves to Suggests behind
  `rlang::check_installed()`.
- Every function is safe to run again; two bug fixes (a dead link in the
  README template, a missing `.Rbuildignore` entry); a new vignette.

### R CMD check results

0 errors | 0 warnings | 0 notes

### Reverse dependencies

None on CRAN.

## Version 1.0.2

This is a patch release containing bug fixes only, with no new API.

### Maintainer change

The previous maintainer, Colin Walder, has left ETH Zurich and his email
address is no longer active. The new maintainer, Lars Schöbitz
(lschoebitz@ethz.ch), is a package co-author and works at the same
institution (Global Health Engineering, ETH Zurich), which holds the
copyright. Colin Walder remains a package author.

### Changes

- Six bug fixes to `update_citation()`, `update_description()`, and
  `setup_readme()`, each with a regression test (see NEWS.md).
- Removed example blocks that wrote to the temporary directory at check
  time, and fixed an example that referenced a nonexistent function.

### R CMD check results

0 errors | 0 warnings | 0 notes
