# washr implementation plan: issues and milestones

Date: 2026-07-12
Target: sub-version release cycle (1.0.2 patch, then 1.1.0 minor, then 1.2.0 minor). No 2.0.0.
This is the premortem-revised plan. Mitigations from the premortem are marked [PM-Rn].

## Gate 0 (before any other work) [PM-R2]

Issue 0.1: Verify the CRAN maintainer channel.
Confirm cwalder@ethz.ch is monitored and Colin is available to confirm a CRAN submission. If not, prepare the maintainer change (new cre in Authors@R, explanation in cran-comments.md) so it rides the 1.0.2 submission. Also confirm who receives CRAN check emails today.
Acceptance: a named person committed to confirming the submission email within 48 hours of submission.
Kill criterion: if this cannot be resolved within 2 weeks, pause the CRAN plan and publish fixes via GitHub release + r-universe for downstream while the maintainer change is sorted out.

## Milestone 1: v1.0.2 "CRAN patch, released bugs only" (target: branch ready in 2 weeks, on CRAN within ~6 weeks)

Scope rule: fixes for defects present in CRAN 1.0.1 only. Zero new API. Diff kept surgical against the accepted 1.0.1 tarball [discussion consensus].

Issue 1.1: Extend CI triggers.
Add push/pull_request triggers for dev and release/** plus workflow_dispatch to R-CMD-check.yaml (and dev to pkgdown.yaml, deploy still gated to main). First commit on the release branch [PM: prerequisite for everything].

Issue 1.2: Cut release/1.0.2 from 11a29c4; retro-tag v1.0.0 (4875bfc) and v1.0.1 (11a29c4).

Issue 1.3: Empirically pin current dependency behavior before coding [PM-R5].
On a machine with current CRAN cffr/desc/usethis: reproduce all five bugs from 1.0.1, record actual behavior (does current cffr still write .bk1? how does desc_set reflow DESCRIPTION?). Every regression test must be demonstrated to FAIL on the unfixed 1.0.1 code before the fix lands (fail-first proof in the PR description).

Issue 1.4: Fix #57: update_citation(doi = NULL) default with early validation. Regression test.

Issue 1.5: Fix #58 and badge idempotency: no badge when doi is NULL; replace an existing DOI badge instead of appending; clear error when the badges-end marker is missing. Regression tests including README unchanged on error.

Issue 1.6: Fix #60: no inst/CITATION.bk1 litter (mechanism chosen from the evidence in 1.3). Regression test runs update_citation twice.

Issue 1.7: Fix #59 and URL preservation: update_description() read-merge-write for Config/Needs/website and the URL field; full-file DESCRIPTION snapshot test to catch reflow side effects [PM-R5]. Replace the vacuous existing test with behavioral assertions (Language, URL, BugReports, Date).

Issue 1.8: Fix setup_readme() data loss: never delete an existing README.Rmd without explicit confirmation; add force argument; error non-interactively. Regression test: decline path preserves content byte-identical. (New bug: file as washr issue.)

Issue 1.9: Real-fleet fixture tests [PM-R8].
Add a fixture copied from a real published package as shipped (fslogisticskampala: its 1.0.1-generated, hand-patched DESCRIPTION, CITATION.cff, README.Rmd). Run the fixed update_citation/update_description against it and snapshot the diff. Acceptance: the diff contains only intended changes; DOI in CITATION.cff still matches the minted Zenodo DOI.

Issue 1.10: Release chores.
NEWS.md 1.0.2 section; refresh Date; remove the dontshow devtools::create(tempdir()) example landmines; fix the phantom update_dictionary() example in fill_dictionary; delete stale CRAN-SUBMISSION; roxygen for the fixed functions describes the fixed behavior.

Issue 1.11: Forward-merge gate [PM-R1].
Open the release/1.0.2 -> main merge PR (fixes plus all seven-plus tests) and get it green BEFORE the CRAN submission is sent. Submission is blocked until main contains the regression tests.

Issue 1.12: Submit to CRAN, confirm within 48h, tag v1.0.2 on acceptance.

Issue 1.13: Fleet pilot and re-run playbook [PM-R8].
After CRAN acceptance: re-run the fixed functions on ONE older published package, diff everything, document a re-run playbook (what to re-run, what to never touch, how DOIs are preserved). Only after the pilot passes does pkgreview modify its skills.

Cross-repo (openwashdata/pkgreview, tracked there as #23) [PM-R6]:
Do not delete the 1.0.1 caveats. Version-condition them: skills check packageVersion("washr") at runtime; caveat steps apply when < 1.0.2, are skipped when >= 1.0.2. Bump the review-standard VERSION per pkgreview rules; verify against fixtures/pkgreviewtest. Caveats are removed entirely only after two consecutive clean downstream releases on >= 1.0.2.

## Milestone 2: v1.1.0 "API consolidation" (target: decision in 4 weeks, release ~3 months; decision-gated, not date-gated)

Reframed success criterion [PM-R7]: NOT "suite on CRAN". Success = the #47 design decision is implemented and the release ships only what meets the test bar. An explicit ship/defer decision point sits at the end. If the suite is not ready, 1.1.0 ships as a cleanup minor (Imports cut, Depends fix, idempotency sweep) and the suite moves to 1.2.0 or dies. That outcome counts as success, not failure.

Issue 2.1: Metadata design decision (blocks all suite code) [PM-R4].
One page, one named owner (Lars), 4-week deadline: what is the canonical metadata source (DESCRIPTION + dictionary.csv proposed); what do the generated artifacts exist for (website catalog? Zenodo? JSON-LD discovery?); what happens to the packages that already ran add_metadata(). Zenodo automation (#56) explicitly out of scope for 1.1.0. Issue #47 is closed by this document, not by milestone assignment.
Kill criterion: no agreed decision in 4 weeks means the suite is out of 1.1.0.

Issue 2.2: Implement setup_metadata()/update_metadata() per the decision: auto-populated, non-interactive (no readline; overwrite arguments; usethis-style prompts only when interactive), idempotent (read-merge-write, stable output across re-runs).

Issue 2.3: Delete the Google Sheet sync from the package (not flag-gated: deleted) [PM-R7]. Move to org tooling alongside the #56 Zenodo direction; drop googlesheets4 from Imports.

Issue 2.4: Fix or obsolete the remaining suite defects: update_access repo-URL derivation from Package/URL, encodingFormat recycling, generate_jsonld (@context schema.org, version/license/date from DESCRIPTION, dir.create, stable output), update_attributes schema, add_metadata overwrite no-op. Any function not redesigned gets unexported rather than shipped.

Issue 2.5: Trim the export surface: update_access/update_attributes/update_biblio internal; decide fill_dictionary and generate_roxygen_docs. Nothing exports that is slated for deprecation.

Issue 2.6: Dependency cut: Imports 16 -> ~8. Drop lubridate, tibble, stringr, dplyr (trivial replacements); evict devtools (pkgdown::build_site + rmarkdown::render); googlesheets4/dataspice leave with 2.3/2.2; standardize on one CSV IO. Add Depends: R (>= 4.1.0) or remove native pipes; drop the utils (>= 4.3.3) constraint.

Issue 2.7: Test bar [tests reviewer nonnegotiable]: behavioral test per export; mocking infra (prompt wrapper, injectable targets); fixtures including a real-fleet fixture; fail-first proof for every bugfix test; coverage workflow added.

Issue 2.8: Docs: end-to-end vignette teaching the full workflow order (written only after 2.1); README toolkit overview + CRAN badge; @family tags; fix _pkgdown.yml org URL; fix inst/templates/_pkgdown.yml url field (shrinks pkgreview template divergence); NEWS.

Issue 2.9: Idempotency sweep: every function that rewrites user files (setup_readme, badge insertion, desc writers, roxygen regeneration) follows read-merge-write and is safe to re-run [code reviewer systemic rule].

Issue 2.10: Ship/defer decision, then CRAN 1.1.0, tag, forward-merge gate as in 1.11.

## Milestone 3: v1.2.0 "features" (backlog, schedule after 1.1.0 ships)

- #13 update_dictionary() preserving existing descriptions
- #40 setup_roxygen() re-run ergonomics (plus the crash when @format is missing)
- #20 labelled data support
- #24 plot/table templates
- #56 Zenodo API automation (org tooling first, package integration only if it earns it)
- Messaging standardization (cli, invisible returns)

## Standing kill criteria and watch signals

1. CRAN submission unconfirmed after 2 weeks or maintainer unreachable: switch distribution to GitHub release + r-universe for downstream, pursue maintainer change in parallel [PM-R2, PM-R3].
2. 1.0.2 merged but not submitted within 2 weeks of branch-ready: the bandwidth failure is happening; cut scope to Issues 1.4-1.7 + 1.10-1.12 only and submit [PM-R3].
3. git log main..release/1.0.2 non-empty two weeks after the v1.0.2 tag: stop all M2 work until the forward-merge lands [PM-R1].
4. Empty DOI badges or CITATION.bk1 in any downstream release PR after pkgreview flips: old washr still resolving somewhere; re-enable the version-conditioned caveats [PM-R6].
5. #47 design thread references the website catalog, FAIR ambitions or #56 instead of function signatures for two consecutive weeks: scope is inflating; the owner decides with what exists [PM-R4].
6. Any suite function surviving into 1.1.0 behind a "temporary" flag: it ships in 1.2.0 or dies; flags are not a compromise [PM-R7].
