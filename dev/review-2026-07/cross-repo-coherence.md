# Cross-repo coherence review: washr and pkgreview plans

Date: 2026-07-12
Scope: washr plan revision 3 + issues #61-#85 (this review cycle) against pkgreview's v1.1 roadmap + issues #27-#39 and its standing backlog (#8, #12, #13, #15, #16, #17, #20), the pkgreview skills/standards as committed on main, and the ghedatapublishing guide.

## A. Inconsistencies (two plans state conflicting or stale facts)

A1. The caveat retirement is orphaned. pkgreview #23 is CLOSED (completed 2026-07-08): its scope was ADDING the washr 1.0.1 workarounds, which shipped. washr #66 and the washr plan both say the version-conditioning of those caveats is "tracked in openwashdata/pkgreview#23"; nothing open tracks it in either repo. The single most important cross-repo action of washr v1.0.2 has no owner.
Fix: file a new pkgreview issue ("Version-condition the washr 1.0.1 caveats on packageVersion('washr') >= 1.0.2; retire after two clean releases"), attach it to a pkgreview milestone, and update washr #66's downstream bullet to point at it.

A2. pkgreview #37 (v1.3.0 spike) tests a function that does not exist. The spike's procedure is "rerun washr::setup_dictionary() / washr::update_dictionary() and diff", but update_dictionary() is washr #13, an unscheduled v1.2.0 backlog item. As written the spike insta-fails on function-not-found, and its kill criterion ("fail with no washr fix within a month") would close pkgreview #39 as not planned for the wrong reason.
Fix: reword #37 to (a) test the round-trip that exists today (setup_dictionary/fill_dictionary over an edited dictionary) and (b) declare washr #13 a blocking dependency for the update_dictionary half; add "extra user columns survive the round-trip" as an acceptance criterion on washr #13 and cross-link both.

A3. washr's scaffold cannot produce a package that passes pkgreview's required floor. pkgreview #27 puts "R-CMD-check workflow present with dev trigger" in the REQUIRED tests tier, but washr creates no GitHub Actions workflow anywhere (verified: no use_github_action or workflow templates in R/ or inst/). Every contributor package fails the floor by construction until someone hand-adds CI, contradicting pkgreview #30's goal that contributors self-serve to the floor with washr.
Fix: new washr issue (v1.1.0 fits, near #73): scaffold the standard R-CMD-check workflow with the dev trigger (usethis::use_github_action or a shipped template). Adopt the general principle in both plans: "a freshly washr-scaffolded package passes the pkgreview required tier by construction", and make it an acceptance criterion of the pkgreview fixture gate eventually.

## B. Gaps (work both plans need that neither contains)

B1. CITATION.cff keywords get wiped every release. pkgreview #35 adds advisory CITATION.cff keywords and already notes "verify manually after washr::update_citation() since washr may not write them". washr::update_citation() regenerates CITATION.cff wholesale from DESCRIPTION via cffr, so hand-added keywords are destroyed on every release; the manual verification becomes permanent recurring work, which is the caveat pattern all over again.
Fix: washr side: preserve or merge existing CITATION.cff keywords in update_citation() (or source keywords from a config/DESCRIPTION field). Fold into washr #67's field-mapping scope and #73's idempotency sweep; keywords should be one mapping across CITATION.cff, dataspice biblio, and the future Zenodo record.

B2. The license clobber is tasked nowhere. update_description() runs usethis::use_ccby_license() unconditionally (rewrites License and LICENSE.md regardless of current state). washr #63 cites it as context but its task list covers only URL/Config-Needs/file-arg. Harmless for openwashdata data packages (CC BY is the floor), wrong for the #81 generalization and for any non-data-package use.
Fix: add a task to washr #63 (set only when absent) or #81 (license default from config).

B3. The engine decision has not reached pkgreview. pkgreview #20 (fairenough pipeline discussion) still poses "fairenough OR fairenough-in-a-skill to start a package?" as open, and pkgreview #30 says "the guidebook should name whichever entry point that discussion lands on". The decision (washr is the engine, fairenough capabilities port into washr, washr #81-#83) was recorded only in washr's plan.
Fix: comment the decision on pkgreview #20 with a link to the washr plan; #30's guidebook names washr as the entry point.

B4. pkgreview has no milestone-setup issue. Its roadmap says the three milestones must be created manually, but that instruction lives only in docs/roadmap-v1.1.md on an unmerged branch; there is no assigned issue like washr #79.
Fix: either extend washr #79's checklist to cover both repos or file the pkgreview twin.

## C. Overlaps (same capability planned twice with no ownership split)

C1. Zenodo automation is split across repos without a contract. pkgreview #12 (inbo/checklist pattern) plans ".zenodo.json to the washr template", CI version-consistency checks, and de-pausing /create-release; washr's v1.2.0 flagship is update_zenodo() via the Zenodo REST API (#56); pkgreview #35 adds the manual floor. Three issues, two repos, no cross-references, and #12 assigns washr-template work from pkgreview's backlog.
Fix: declare the split: washr owns package-side artifacts and the API function (.zenodo.json/CITATION.cff templates, update_zenodo()); pkgreview owns the skill-flow changes that consume them. Cross-link #12, #35, washr #56.

C2. The mechanical check layer is planned twice. pkgreview #13 (deterministic check script, "candidate home: the washr package") and washr #82 (check_publication_readiness(), porting fairenough's validate gates) are the same capability.
Fix: washr #82 implements the engine (gates as functions), pkgreview #13 consumes it from the skills and defines the machine-checked subset of the checklist; keep #33's reworded items compatible, as #33 already intends. Cross-link all three.

C3. Three overlapping teaching artifacts. pkgreview #30 (contributor guidebook, v1.1.0, 4 weeks), the ghedatapublishing rework (washr #85, after washr 1.1.0), and the washr vignette (washr #76) address overlapping audiences. Risk: the canonical-content duplication that pkgreview's own CLAUDE.md rule 4 exists to prevent, now at the guide level.
Fix: declare the hierarchy now: vignette = condensed function walkthrough inside the package; guidebook = floor/intake-focused contributor onboarding (ships v1.1.0 because the intake screen needs it); reworked guide = the full narrative, absorbing or superseding the guidebook when washr #85 executes. Note the planned merge in both #30 and washr #85.

C4. The _pkgdown.yml template divergence is only half-fixed. pkgreview's corrected template differs from washr's in two ways: the url field (covered by washr #73) and the multi-dataset reference block plus explanatory comments (covered nowhere). Until washr's template matches, pkgreview must keep its fork, which its own rules call a defect magnet.
Fix: extend washr #73 to adopt the reference block and comments from pkgreview's copy, with the goal that pkgreview's fork reduces to a pointer.

## D. Timing and resource problems

D1. Two timeboxed milestones stack on one maintainer starting the same day. pkgreview v1.1.0 is timeboxed at 4 weeks; washr v1.0.2 targets branch-ready in 2 weeks and CRAN inside 6. Both premortems independently named maintainer bandwidth the most likely failure, and the two plans were written without a shared calendar.
Fix: sequence explicitly. Week 1-2: washr release branch (small, mechanical, unblocks CRAN wait) plus Gate 0. Weeks 2-6: pkgreview v1.1.0 while the CRAN submission is in flight. The caveat retirement (A1) rides pkgreview's #32 release if washr 1.0.2 is accepted by then; otherwise it becomes a small standard patch release after.

D2. standards.md is edited by two uncoordinated releases. pkgreview #32 rewrites standards.md (tiers, PII-first, dictionary emphasis); the caveat retirement (A1) edits the same file's washr-caveat block. Done separately, that is two standard VERSION bumps in quick succession and stamped-version churn for in-flight reviews.
Fix: same as D1: one combined edit in #32 when timing allows.

D3. Fixture gate runs execute washr functions. The metadata checklist instructs running update_description()/update_citation() with the 1.0.1 caveat steps; a gate run on a machine with washr 1.0.2 but pre-retirement skills will perform obsolete surgery (delete a correct badge, restore fields that were not stripped). This is the premortem R6 scenario inside pkgreview's own acceptance gate.
Fix: the version-conditioning (A1) covers gate runs too; until it lands, gate runs should pin washr 1.0.1 or note the discrepancy.

D4. Milestone name collision. Both repos now use v1.1.0 and v1.2.0 as milestone names meaning different things (review standard version vs package version). Cross-repo conversation ("blocked on v1.1.0") is ambiguous.
Fix: qualify in milestone descriptions (washr package v1.1.0 / review standard v1.1.0); no renaming needed.

D5. Plan documents live on unmerged review branches. All 13 new pkgreview issues link docs/roadmap-v1.1.md on claude/tidyverse-review-premortem-8vnivi; all washr issues reference dev/review-2026-07/ on claude/washr-review-premortem-5idwlc. If the branches are deleted after merge, every link 404s.
Fix: merge both review-docs branches to their mainlines (pkgreview via its dev-to-main flow), or re-point issue links to main after merge.

## E. Verified consistent (spot-checks that passed)

- pkgreview consumes only update_description() and update_citation(); both survive every washr rename in v1.1.0 (#71 unexports helpers, not these). The package-resident standards file needs no function-name changes.
- pkgreview's v1.1 roadmap explicitly keeps the 5-column dictionary schema to avoid the washr ownership collision; washr's plan makes no schema changes before #13. No conflict in the v1.1 line.
- pkgreview #27's required metadata tier (CC BY 4.0, update_citation-generated citation) matches washr's openwashdata defaults before and after #81 (config default remains CC BY).
- washr #62 (CI on dev) matches pkgreview's floor requirement of dev-triggered R-CMD-check, and both repos use the same dev-to-main release discipline.
- The two premortems arrived independently at the same top risk (single-maintainer bandwidth) and compatible mitigations (timeboxes, one-session issues, ship-what-is-gated).

## Priority order

1. A1 (orphaned caveat retirement): the one item that silently defeats washr v1.0.2's purpose.
2. A3 (scaffold cannot pass the floor): contradicts the central throughput goal of pkgreview v1.1.0.
3. D1/D2 (sequencing and the double standards.md edit): decide before either milestone starts.
4. B1 (keywords wiped), A2 (spike tests nonexistent function): cheap wording fixes now, expensive confusion later.
5. C1-C3 ownership splits and B3 decision propagation: one comment or cross-link each.
