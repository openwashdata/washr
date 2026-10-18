# Release checklist

The steps of a washr release, in order. The procedure was first written down in #78 and #66.

1. `R CMD check --as-cran` is clean and `urlchecker::url_check()` reports nothing.
2. The scaffold check workflow is green on `dev`.
3. `PKGREVIEW_FLOOR` names the latest pkgreview release tag. Raise it when pkgreview has released since the last washr release, and rerun the scaffold check.
4. NEWS.md and `cran-comments.md` have their section for the version. Version and Date are set in DESCRIPTION on `dev`.
5. Open the pull request from `dev` into `main` and merge it.
6. The publishing guide is synced: every washr call in the guide is checked against the release.
7. Submit from `main` with `devtools::submit_cran()` and confirm the email.
8. On acceptance, tag the release: `git tag -a vX.Y.Z -m "washr X.Y.Z (CRAN release)"`, then push the tag.
9. On `dev`, run `usethis::use_dev_version()`, merge `main` into `dev` and push `origin/dev`.
10. Tell pkgreview about API changes, so it can raise its `WASHR_FLOOR`.
