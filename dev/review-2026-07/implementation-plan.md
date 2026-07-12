# washr implementation plan: issues and milestones

Date: 2026-07-12 (revision 2, same day)
Target: sub-version release cycle (1.0.2 patch, then 1.1.0 minor, then 1.2.0 minor). No 2.0.0.
Premortem mitigations are marked [PM-Rn].

Revision 2 changes (triage after reading the ghedatapublishing guide):
- Published data packages are OUT OF SCOPE: the team fixes the existing fleet separately. The fleet fixture test, fleet pilot, and the fleet kill criterion are removed from this plan. Premortem finding R8 remains recorded in the premortem documents; its mitigation is owned outside this plan.
- Correction to the review: the metadata suite is NOT consumer-free. The ghedatapublishing guide (https://github.com/Global-Health-Engineering/ghedatapublishing) prescribes add_metadata(), update_metadata(), add_creator(), and generate_jsonld() as its FAIR Documentation step. Consequence: the suite is consolidated and fixed, not deleted, and the guide must be updated in lockstep with any renaming (none of these exports has ever been on CRAN, so there is no CRAN deprecation constraint, only guide/package sync).
- Function taxonomy adopted (see below): stable core of seven, experimental FAIR layer with lifecycle badges, internalized plumbing, one removal.
- Issue triage adopted: #57/#58/#59/#60 fix now; #47 resolved as auto-populate and consolidate; #13/#20/#56 to 1.2.0 with #56 as the flagship; #24 folded into the setup_readme template work; #40 folded into the 1.1.0 ergonomics sweep.

Revision 3 changes (engine decision, 2026-07-12):
- Engine decision (Lars): washr is the engine. It gets parameterized long-term so its use case extends beyond openwashdata, no matter the package name. Templates are not lost: they become whisker-style defaults filled from an org config layer (DESCRIPTION-derived facts plus a small override file/options), with openwashdata as the shipped default.
- fairenough consequence: fairenough's genuinely novel pieces are ported into washr as backlog items (validation gates as check_publication_readiness(); AI dictionary descriptions as an optional, key-free-by-default assist behind Suggests). No new engine features land in fairenough; its long-term disposition (thin AI wrapper vs archive) is a team call outside this plan.
- Guide rework tracked as its own issue: move ghedatapublishing to the openwashdata org, rename tool-neutrally, rework against the 1.1.0 washr, with a redirect for the old Pages URL.

## Function taxonomy

Stable core (the guide's chronology; exported forever, hardened first):
setup_rawdata(), setup_dictionary(), setup_roxygen(), update_description(), setup_readme(), setup_website(), update_citation().

Experimental FAIR layer (exported with lifecycle "experimental" badges; API may change):
update_metadata() consolidated and auto-populated (absorbs add_metadata() and add_creator()), generate_jsonld() after its schema fixes.

Internalized (unexported in 1.1.0; never released on CRAN so no deprecation cycle, guide updated in lockstep):
update_access(), update_attributes(), update_biblio(), fill_dictionary(), generate_roxygen_docs(), add_creator() (creators derive from Authors@R, which the guide populates via usethis::use_author()).

Removed from the package:
update_gsheet_metadata() (absent from the guide, hardcodes a private org sheet; moves to org tooling alongside the #56 Zenodo direction).

## Gate 0 (before any other work) [PM-R2]

Issue G0: Verify the CRAN maintainer channel.
Confirm cwalder@ethz.ch is monitored and the maintainer of record can confirm a CRAN submission. If not, prepare the maintainer change (new cre in Authors@R, explanation in cran-comments.md) so it rides the 1.0.2 submission. Confirm who receives CRAN check emails today.
Acceptance: a named person committed to confirming the submission email within 48 hours of submission.
Kill criterion: if unresolved within 2 weeks, pause the CRAN track and distribute fixes via GitHub release + r-universe for downstream while the maintainer change runs in parallel.

## Milestone 1: v1.0.2 "CRAN patch, released bugs only" (target: branch ready in 2 weeks, on CRAN within ~6 weeks)

Scope rule: fixes for defects present in CRAN 1.0.1 only. Zero new API. Diff kept surgical against the accepted 1.0.1 tarball.

Work items (existing issues #57, #58, #59, #60 plus new issues):

1.1 CI triggers [new issue]. Add push/pull_request triggers for dev and release/** plus workflow_dispatch to R-CMD-check.yaml (and dev to pkgdown.yaml, deploy still gated to main). First commit on the release branch [PM: prerequisite].

1.2 Fix #57: update_citation(doi = NULL) default with early validation.

1.3 Fix #58 and badge idempotency: no badge when doi is NULL; replace an existing DOI badge instead of appending; clear error when the badges-end marker is missing; README unchanged on error.

1.4 Fix #60: no inst/CITATION.bk1 litter, mechanism chosen after empirically pinning current cffr behavior [PM-R5].

1.5 Fix #59 plus URL preservation [companion new issue]: update_description() read-merge-write for Config/Needs/website AND the URL field; existence check honors the file argument.

1.6 Fix setup_readme() data loss [new issue]: never delete an existing README.Rmd without explicit confirmation; error non-interactively; add force argument.

1.7 Regression-test harness [new issue] [PM-R5]: reproduce all five released bugs on a real R toolchain with current CRAN cffr/desc/usethis before coding; every fix merges with a regression test demonstrated to fail on unfixed 1.0.1 code (fail-first evidence in the PR); full-file snapshot tests for DESCRIPTION and CITATION.cff; replace the vacuous update_description test with behavioral assertions.

1.8 Release engineering [new issue]: cut release/1.0.2 from 11a29c4; retro-tag v1.0.0 (4875bfc) and v1.0.1 (11a29c4); NEWS 1.0.2 section; refresh Date; remove the dontshow devtools::create(tempdir()) example landmines; fix the phantom update_dictionary() example in fill_dictionary; delete stale CRAN-SUBMISSION; forward-merge PR to main green BEFORE the CRAN submission is sent [PM-R1]; submit, confirm within 48h, tag v1.0.2 on acceptance.

Cross-repo (openwashdata/pkgreview, tracked there as #23) [PM-R6]:
Do not delete the 1.0.1 caveats; version-condition them on packageVersion("washr") >= 1.0.2. Bump the review-standard VERSION per pkgreview rules; verify against fixtures/pkgreviewtest. Remove caveats entirely only after two consecutive clean downstream releases on >= 1.0.2.

## Milestone 2: v1.1.0 "harden the core, consolidate the FAIR layer" (target: design decision in 4 weeks, release ~3 months; decision-gated, not date-gated)

Reframed success criterion [PM-R7]: NOT "suite on CRAN". Success = the #47 design decision is implemented and the release ships only what meets the test bar, with the FAIR layer explicitly lifecycle-badged experimental. If the FAIR consolidation is not ready at the ship/defer point, 1.1.0 ships as core-hardening plus dependency cleanup only, and the FAIR layer follows in 1.2.0. That outcome counts as success.

2.1 Metadata design decision (blocks all FAIR-layer code) [PM-R4]. One page, one named owner (Lars), 4-week deadline. Direction is pre-agreed by this triage: canonical sources are DESCRIPTION (authors via Authors@R) + dictionary.csv (variables) + CITATION.cff/DOI; update_metadata() auto-populates everything derivable and reports remaining blank fields; the guide keeps its FAIR step as one call. The decision doc settles field mappings and what the generated artifacts are for. Zenodo automation (#56) explicitly out of scope for 1.1.0. Closes #47 by document, not by milestone assignment.
Kill criterion: no agreed decision in 4 weeks means the FAIR layer is out of 1.1.0.

2.2 Consolidate the FAIR layer: update_metadata() creates the metadata skeleton itself (absorbing add_metadata()), auto-populates from the canonical sources, derives creators from Authors@R (absorbing add_creator()), is non-interactive (no readline; overwrite argument) and idempotent (read-merge-write, stable output across re-runs), and ends by listing exactly which fields remain blank and where. lifecycle experimental badge.

2.3 Remove update_gsheet_metadata() from the package; move to org tooling (relates #56 direction). googlesheets4 and its auth stack leave Imports with it.

2.4 Fix generate_jsonld(): real schema.org @context; version, license, and date from DESCRIPTION instead of hardcoded values; create inst/extdata before writing; stable output across re-runs; correct multi-dataset representation. lifecycle experimental badge.

2.5 Trim the export surface: internalize update_access(), update_attributes(), update_biblio(), fill_dictionary(), generate_roxygen_docs(), add_creator(). Fix or obsolete the internal-layer bugs while at it: update_access repo-URL derivation from Package/URL and dead worldhdi line, encodingFormat recycling for multi-dataset packages, update_attributes schema mismatch. Nothing stays exported that is slated for deletion.

2.6 Dependency cut: Imports 16 to ~8. Drop lubridate, tibble, stringr, dplyr (trivial replacements); evict devtools (pkgdown::build_site + rmarkdown::render); googlesheets4 leaves with 2.3, dataspice with 2.2; standardize on one CSV IO. Add Depends: R (>= 4.1.0) or remove native pipes; drop the utils (>= 4.3.3) constraint.

2.7 Idempotency and ergonomics sweep for the stable core: every function that rewrites user files follows read-merge-write and is safe to re-run. Includes: setup_website() idempotent so the guide's "answer No to the prompt" instruction becomes unnecessary; setup_website() .gitignore crash fix; inst/templates/_pkgdown.yml url field fixed to the Pages URL (shrinks pkgreview template divergence); setup_roxygen() re-run preserves user content below @format and errors clearly when @format is missing (closes the actionable half of #40); setup_dictionary() type detection for multi-class columns.

2.8 setup_readme() improvements: add the has_example argument the guide already documents; template includes an example-plot section (absorbs the intent of #24, which can then be closed).

2.9 Test bar: behavioral test per export (existence-only and bare expect_error do not count); mocking infra (prompt wrapper, injectable targets); fail-first proof for every bugfix test; coverage workflow added.

2.10 Docs: end-to-end vignette mirroring the ghedatapublishing chronology (written only after 2.1); README toolkit overview + CRAN badge; @family tags; _pkgdown.yml site url fixed from openwashdata-dev to openwashdata; NEWS discipline (1.0.2.9000 dev versioning immediately after the patch).

2.11 Guide sync (cross-repo, Global-Health-Engineering/ghedatapublishing): update the guide in lockstep with 2.2/2.5/2.8 (function consolidation, has_example, prompt removal); fix the guide's washr link (currently points to the openwashdata-dev fork); add "guide matches released washr" as a standing release checklist item so drift is caught at release time.

2.12 Ship/defer decision, then CRAN 1.1.0, tag, forward-merge gate as in 1.8.

## Milestone 3: v1.2.0 "workflow automation" (backlog, schedule after 1.1.0 ships)

- #56 (flagship): update_zenodo() using the Zenodo REST API (user token) to set upload type Dataset, related identifiers, and notes from package metadata, collapsing the guide's most manual chapter to one call. Org-agnostic, token-based; the org-specific parts stay in org tooling.
- #13: update_dictionary() preserving hand-written descriptions across data iterations (also strengthens update_metadata auto-population).
- #20: labelled data support (codebook to labels, human-readable codebook page).
- Parameterization: org config layer so washr works beyond openwashdata (engine decision). Whisker-style templates as overridable defaults; org facts from DESCRIPTION plus config; no hardcoded openwashdata anywhere outside default values.
- check_publication_readiness(): workflow status gates encoding the guide's chronology; port fairenough's validate_*_completed() design.
- Optional AI-assisted dictionary descriptions: port fairenough's gendict() as an opt-in assist (Suggests: ellmer), never a prerequisite; the key-free path stays primary.
- setup_repo(): thin wrapper over usethis::create_package() + use_git() + use_github(organisation = ...) so the guide's repository chapter loses its raw terminal git commands (the most beginner-hostile step in the guide). Nice-to-have, not core; the guide's manual path remains documented as fallback.
- Messaging standardization (cli, invisible returns).
- Guide rework (cross-repo): move ghedatapublishing to the openwashdata org, rename tool-neutrally, rework against the shipped 1.1.0 API; old Pages URL gets a redirect stub; academy inbound links updated.
- #24: close when 2.8 ships, superseded by the README template example section.

## Standing kill criteria and watch signals

1. CRAN submission unconfirmed after 2 weeks or maintainer unreachable: switch distribution to GitHub release + r-universe for downstream, pursue maintainer change in parallel [PM-R2, PM-R3].
2. 1.0.2 merged but not submitted within 2 weeks of branch-ready: the bandwidth failure is happening; cut scope to the bug fixes (#57-#60, setup_readme, URL wipe) plus release engineering and submit [PM-R3].
3. git log main..release/1.0.2 non-empty two weeks after the v1.0.2 tag: stop all M2 work until the forward-merge lands [PM-R1].
4. Empty DOI badges or CITATION.bk1 in any downstream release PR after pkgreview flips: old washr still resolving somewhere; re-enable the version-conditioned caveats [PM-R6].
5. #47 design thread references the website catalog, FAIR ambitions or #56 instead of field mappings and function signatures for two consecutive weeks: scope is inflating; the owner decides with what exists [PM-R4].
6. Any FAIR-layer function surviving into 1.1.0 behind a "temporary" flag that the design decision said to remove: it ships in 1.2.0 or dies; flags are not a compromise [PM-R7].
