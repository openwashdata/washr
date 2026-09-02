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
