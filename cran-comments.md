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
