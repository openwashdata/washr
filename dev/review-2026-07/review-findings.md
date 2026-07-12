# washr thorough review: consolidated findings

Date: 2026-07-12
Method: five parallel review agents (code correctness, CRAN compliance, tests/CI, documentation/website, API design/downstream fit), followed by a cross-review discussion round in which each reviewer received the others' positions, rebutted them, and voted on release slicing.
State reviewed: main at 7380c12; CRAN release 1.0.1 (commit 11a29c4, Nov 2024).

## Ground truth established before the fan-out

- CRAN has washr 1.0.1. Since then, main accumulated a large unreleased metadata suite (PRs #46, #54): add_creator, add_metadata, generate_jsonld, update_access, update_attributes, update_biblio, update_gsheet_metadata, update_metadata, plus edits to setup_roxygen and update_citation. DESCRIPTION still says 1.0.1, Date 2024-11-01.
- Open bugs #57, #58, #59, #60 were filed 2026-07-08 from the fslogisticskampala release. Verified by inspecting commit 11a29c4: all four defects exist in the released CRAN 1.0.1 code. CRAN users are affected today.
- The repository has no git tags. CI (R-CMD-check, pkgdown) triggers only on main/master, so nothing that merged to dev was ever checked.
- No R interpreter was available in the review environment; all findings are from static analysis (one reviewer verified library behavior against upstream cffr/dataspice/usethis sources).

## Highest-severity findings

1. Data loss (critical, previously unreported): setup_readme() unconditionally deletes an existing README.Rmd and replaces it with the template, even when the user declines the usethis overwrite prompt (R/setup_readme.R:28-30). Verified against usethis write_over() semantics.
2. The update_citation cluster (released, bugs #57/#58/#60): doi argument required with no default (R/update_citation.R:24); doi = NULL builds a broken empty badge https://zenodo.org/badge/DOI/.svg written into README.Rmd (R/update_citation.R:60-62); cffr::cff_write_citation leaves inst/CITATION.bk1 backups that ship inside the tarball (R/update_citation.R:43); badge insertion is non-idempotent (appends duplicates) and the while loop crashes if the badges-end marker is missing.
3. update_description() destructive rewrites (released, bug #59 plus new finding): clobbers Config/Needs/website down to "rmarkdown" (R/update_description.R:43) and replaces the whole URL field, wiping pkgdown site URLs (R/update_description.R:50-51); the file argument is half-honored (existence check reads getwd()); usethis::use_ccby_license() runs unconditionally.
4. The unreleased metadata suite is not release quality (about a dozen latent defects):
   - update_access builds GitHub URLs using the dataset file name as the repository name; wrong links for any package where they differ or with multiple datasets (R/update_access.R:35-36); dead hardcoded worldhdi URL at line 18.
   - encodingFormat recycling mislabels every file when a package has more than one dataset (R/update_access.R:32-38).
   - add_metadata "overwrite" branch is a no-op that reports success (dataspice::create_spice copies with overwrite = FALSE) (R/add_metadata.R:30-32).
   - update_gsheet_metadata hardcodes a private org Google Sheet ID, appends duplicate rows on every run, requires interactive auth, and crashes when CITATION lacks a DOI (R/update_gsheet_metadata.R:56-84).
   - generate_jsonld: "@context" is not a valid JSON-LD context, license/version hardcoded, datePublished changes every run, writes to inst/extdata without creating it (R/generate_jsonld.R:53-99).
   - update_attributes writes the raw dictionary columns into a file that claims the dataspice attributes schema (R/update_attributes.R:26).
   - Bare readline() prompts in add_creator/add_metadata silently misbehave non-interactively.
5. Tests: 8 of 17 exports have zero coverage (the entire suite plus update_citation); the sole update_description test is vacuous (asserts a file exists that the fixture already created). Bugs #57-60 all escaped through this gap.
6. CI: R-CMD-check and pkgdown trigger only on main/master; dev, where all work lands, is never checked. One-line fix, highest leverage.
7. CRAN compliance: missing Depends R >= 4.1.0 despite native pipe use in the suite files; nonsensical utils (>= 4.3.3) constraint; devtools as a hard Import; 16 Imports where about 8 are justified (lubridate for one today() call, tibble for one tibble() call, stringr for two str_remove calls with an unescaped-dot regex bug, dplyr replaceable, googlesheets4 and dataspice serve org-internal or disputed functions); dontshow example blocks run devtools::create(tempdir()) at check time (latent check error); all 17 man pages wrap the entire example in dontrun; stale Date; stale CRAN-SUBMISSION file (says 1.0.0); no NEWS entry for anything after 1.0.1.
8. Docs: the only vignette contains installation instructions and zero functions; fill_dictionary example calls a nonexistent update_dictionary(); generate_jsonld docs promise a different output path than the code; _pkgdown.yml url points at openwashdata-dev instead of openwashdata; update_metadata claims to update "all" metadata but updates three of six files.
9. Downstream (decisive for sequencing): pkgreview, the production consumer, invokes exactly two washr functions: update_description() and update_citation(). The unreleased metadata suite has zero pkgreview consumers. pkgreview carries documented "washr 1.0.1 caveats" (workarounds) for all four released bugs; the skills reference washr from CRAN, so only a CRAN release deletes those workarounds.

CORRECTION (revision 2, same day): "zero downstream consumers" was too narrow. The ghedatapublishing guide (https://github.com/Global-Health-Engineering/ghedatapublishing) prescribes add_metadata(), update_metadata(), add_creator(), and generate_jsonld() as its FAIR Documentation step, so guide followers are consumers of the suite. Consequence adopted in implementation-plan.md: consolidate and fix the FAIR layer (lifecycle experimental) rather than defer or delete it wholesale, and update the guide in lockstep with any renaming. The guide also documents setup_readme(has_example = TRUE), which does not exist (has_example belongs to setup_website()), and links to the openwashdata-dev fork: guide/package drift is itself a finding.

## Discussion outcome

Unanimous vote (5 of 5), after the CRAN reviewer retracted its incorrect claim that the bugs were unreleased:

Option (a): cut release/1.0.2 from 11a29c4, ship a surgical CRAN patch for the five released bugs with regression tests, then reshape the metadata suite and ship it as 1.1.0 later.

Rejected: (b) single hardened 1.1.0 from main (holds a data-loss fix hostage to a redesign; launders an unreviewed API out under bugfix pressure); (c) 1.1.0 from main with the suite stripped (error-prone NAMESPACE/Imports surgery for no gain over the release branch).

Agreed constraints:
- Patch scope rule: released defects only, zero new API, diff kept surgical against the accepted 1.0.1 tarball.
- Every fix merges with its regression test (seven tests scoped, about a day of work).
- First commit on the release branch extends CI triggers (release/**, dev, workflow_dispatch); green check on the tagged commit gates submission.
- Retro-tag v1.0.0 (4875bfc) and v1.0.1 (11a29c4) for anchors.
- The suite does not ship in any release until issue #47 is resolved by a written design decision, all readline() interactivity is removed, the Google Sheet ID is out of the package, and every export has a behavioral test. CRAN export deletion forces deprecation cycles, so exports must be final before they ship.
- The week 1.0.2 reaches CRAN, pkgreview deletes or version-conditions its 1.0.1 caveats (tracked in openwashdata/pkgreview#23), verified against fixtures/pkgreviewtest.
