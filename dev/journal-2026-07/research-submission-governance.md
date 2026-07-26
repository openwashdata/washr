# Submission & Governance Models for Package/Data Repositories

Research-agent report, 2026-07-26. Companion evidence to `journal-plan-critique-and-approach.md`.
Informs a CRAN-like submission layer for openwashdata. All findings drawn from the primary policy documents cited at the end.

## 1. The CRAN model

CRAN's governance rests on the **CRAN Repository Policy** (a single living HTML/PDF document, revision-numbered). Key maintainer requirements:

- **Single designated maintainer with a valid email.** Each package `DESCRIPTION` names one `Maintainer` with a working address. CRAN corresponds only with that person; **a bouncing email is grounds for archival.** Maintainers "give the right to use that package name to CRAN when they submit" — so CRAN can orphan and reassign a package.
- **Response obligations.** When CRAN flags a policy or check problem, maintainers are given a firm deadline (typically 2 weeks). Failure to respond or fix results in archival: "Packages for which R CMD check gives an 'ERROR' ... will be archived ... unless the maintainer has set a firm deadline for an upcoming update (and keeps to it)."
- **Archival, not deletion.** Packages "will not normally be removed ... however, they may be archived." Archived packages leave the active repository but remain in the historical archive. **Orphaned packages may not be strict dependencies** (Depends/Imports/LinkingTo) of other packages.
- **License requirements.** Must be an accepted open-source license (standardized in R's license list), with any non-standard terms in a `LICENSE` file. Ownership/copyright must be declarable.
- **Submission pipeline.** Two-stage: (a) **automated** — `R CMD check --as-cran` must pass with no ERRORs/WARNINGs; incoming checks run automatically on submission; (b) **human review** by the small CRAN team. A separate **Submission Checklist** governs resubmissions, and there are limits on update frequency (roughly one release per 1–2 months) to reduce reviewer load.
- **Maintainer changes** require "the written agreement of the previous maintainer (unless the package has been formally orphaned)."

**What makes it work:** hard automation gate (most defects caught before a human looks), a stable written policy, and permanent archival. **Known pain points** (documented by community analyses and *R Packages*): a **volunteer reviewer bottleneck** — a handful of people do CRAN review on top of day jobs and R core work; **maintainer burden** from strict, sometimes opaque, feedback and tight fix deadlines; and **package archival cascades** when an upstream dependency is archived. Each `NOTE` consumes scarce human oversight, so submissions with zero NOTEs pass faster.

## 2. rOpenSci software peer review (closest template)

rOpenSci's **Dev Guide** ("Packages: Development, Maintenance, and Peer Review") defines an editorial, journal-like model conducted **openly on GitHub issues**:

- **Editorial model.** A submission opens an issue; an **Editor-in-Chief / handling editor** checks scope and assigns **two reviewers**. Review is public and conversational in the issue thread. Two software-review streams exist (data-lifecycle packages, and statistical software with its own **standards** in the separate *Statistical Software Peer Review* guide).
- **Automation.** The **`ropensci-review-bot`** runs `pkgcheck` (built on `pkgstats`) on submission and posts a report into the issue — "the primary source of information used to inform initial editorial decisions." Authors can run `pkgcheck` locally first.
- **Maintainer responsibilities** are explicit: keep the package working, respond to issues, follow the **Code of Conduct**, and maintain the package after acceptance (it moves into the rOpenSci GitHub org / suite).
- **Package Curation Policy** (Dev Guide ch. 17): staff-maintained packages are continuously built; on a **biannual/annual** basis rOpenSci reviews packages "failing for over a month" and moves persistently failing, unmaintained ones to the **`ropensci-archive`** GitHub org. Prioritization is by downloads, reverse-dependencies, and strategic goals.
- **JOSS partnership / fast-track.** rOpenSci-accepted packages that are in JOSS scope and add a short paper get a **fast-tracked JOSS review** at JOSS editors' discretion (JOSS normally requires two reviewers; previously rOpenSci/pyOpenSci-reviewed packages are exempted from re-review).

This is the strongest single template for openwashdata: open review, bot-driven checks, explicit maintainer contract, and an archival lifecycle.

## 3. Data-repository certification & stewardship norms

- **CoreTrustSeal** (Requirements 2023–2025): **16 requirements** covering organizational infrastructure, digital-object management, and technology, built on the **FAIR** principles. Directly relevant clauses: **R09 Preservation Plan**, **R10 Quality Assurance**, **R11 Workflows**, plus **continuity-of-access** provisions (a repository must plan for what happens if it ceases operations). Certification requires documented, evidenced responses per requirement.
- **DataCite Metadata Schema 4.5** — mandatory properties include **Creator** (`creatorName`); **Contributor** is optional but *if used* `contributorType` and `contributorName` are **mandatory**. The **`ContactPerson`** contributor type = "Person with knowledge of how to access, troubleshoot, or otherwise field issues related to the resource" — the schema-native way to encode a **dataset maintainer/contact**. This maps cleanly to a required-maintainer field. Contacts can be organizational.
- **FAIR operationalized** — Findable (persistent ID + rich metadata), Accessible, Interoperable (standard vocabularies), Reusable (clear license + provenance). Certification schemes translate these into checkable repository practices.
- **Dryad** — a **staffed curation model**: human curators check *every* dataset for file readability, metadata completeness, license, README quality, and sensitive/identifiable data before the **DOI is registered**; curators contact submitters by email for fixes. Curation is a gate to publication.
- **Zenodo (contrast)** — **no scientific curation**: "Zenodo does not assess the scientific correctness or quality of submissions"; depositors bear responsibility for meeting research standards. Only **automated + manual spam moderation** and optional **community-level review policies** exist. This is the low-friction, low-assurance end of the spectrum.

## 4. Terms-of-reference / responsibility documents

- **CRAN Policy** — the canonical single-document ToR (see §1).
- **rOpenSci** — a layered set worth emulating: **Code of Conduct**, a **maintainer guide**, and the **Package Curation Policy** (archival + succession) together form the responsibility contract.
- **JOSS** — public **author** and **reviewer** guidelines plus a **review checklist**: OSI-approved `LICENSE` file must physically exist; **substantial scholarly effort** (≥ ~3 person-months); functionality, tests, documentation, and community-contribution guidelines all checked.
- **Bioconductor** — most relevant on maintainer accountability: maintainers must keep the `DESCRIPTION` email **accurate and reachable** (bounces jeopardize the package); `BiocCheck` enforces guidelines; a **one-year End-of-Life / deprecation process** applies to packages that fail build/check with an unresponsive maintainer, after automated and private-email outreach. Deprecated packages get a load-time warning and a strikethrough on the build report.
- **DOAJ / COPE** — if a journal layer is added, these supply editorial-integrity and publication-ethics norms (transparency, misconduct handling); note as a future add-on.

## 5. Data-specific submission review criteria in practice

- **ESSD (Earth System Science Data)** publishes a **formal review-criteria checklist**. Reviewers assess: is the dataset **significant** (unique, useful, **complete** — and not artificially split to inflate publications); is it **usable** in its current format/size with **appropriate formal metadata**; and does the accompanying text contain all information needed to **evaluate every claim** about the data. Data must sit in a suitable, quality-assured repository (ESSD's separate **Repository Criteria**).
- **Scientific Data** applies analogous technical-soundness and metadata-completeness checks (its "Data Descriptor" model).
- **Data Curation Network — CURATE(D) checklist:** **C**heck files/documentation, **U**nderstand (run/QA the data), **R**equest missing info/changes, **A**ugment metadata for findability, **T**ransform formats for reuse, **E**valuate for FAIRness, **D**ocument the curation steps. This is a ready-made, standardized reviewer checklist for datasets.

## 6. Sustainability & succession

The recurring risk — a maintainer leaving academia, retiring, or dying — is addressed differently across communities:

- **CRAN:** archival + name-reassignment; orphaned packages barred as hard dependencies.
- **Bioconductor:** explicit one-year EOL/deprecation for unresponsive maintainers with staged email outreach.
- **rOpenSci:** the most proactive — a documented **"Changing package maintainers"** chapter, **annual maintainer surveys** to surface people ready to step down, **"Call for Contributors"** newsletter recruitment for orphaned packages, encouragement of **co-maintainership**, and `ropensci-archive` as a dignified end state. It explicitly names the human cause: "people change jobs, move locations, retire, and unfortunately die."
- **Institutional vs personal maintainership:** DataCite's `ContactPerson` can be an **organizational** point of contact, and CoreTrustSeal's continuity-of-access requirement pushes repositories toward institutional rather than purely personal stewardship — the most robust hedge against individual departure.

**Design implications for openwashdata:** adopt rOpenSci's open-GitHub-issue + review-bot model as the spine; require a named maintainer with a reachable email as a DataCite `ContactPerson` (allowing an institutional fallback); write a single ToR document combining CRAN-style obligations, a Code of Conduct, and an explicit deprecation/succession policy (Bioconductor's one-year EOL is a concrete template); gate submissions with automated checks (a washr equivalent of `pkgcheck`) plus a human curation step using a CURATE(D)-derived dataset checklist; and archive rather than delete.

## Sources

- [CRAN Repository Policy](https://cran.r-project.org/web/packages/policies.html) · [Checklist for CRAN submissions](https://cran.r-project.org/web/packages/submission_checklist.html) · [Reasons packages are archived (analysis)](https://llrs.dev/post/2021/12/07/reasons-cran-archivals/) · [CRAN review pain points (analysis)](https://llrs.dev/post/2021/01/31/cran-review/) · [R Packages (2e), Releasing to CRAN](https://r-pkgs.org/release.html)
- [rOpenSci Dev Guide — Software Peer Review policies](https://devguide.ropensci.org/softwarereview_policies.html) · [Package Curation Policy](https://devguide.ropensci.org/maintenance_curation.html) · [Changing package maintainers](https://devguide.ropensci.org/maintenance_changing_maintainers.html) · [rOpenSci Statistical Software Peer Review](https://stats-devguide.ropensci.org/) · [Editorial Challenges blog](https://ropensci.org/blog/2022/04/19/software-review-editorial-challenges/)
- [CoreTrustSeal Requirements 2023–2025](https://zenodo.org/records/7051237)
- [DataCite Metadata Schema 4.5 — Contributor](https://datacite-metadata-schema.readthedocs.io/en/4.5/properties/contributor/) · [contributorType (ContactPerson)](https://datacite-metadata-schema.readthedocs.io/en/4.5/appendices/appendix-1/contributorType/)
- [Dryad — Dataset curation](https://datadryad.org/help/guides/curation) · [Zenodo — content suitability / curation FAQ](https://support.zenodo.org/help/en-gb/2-content/141-what-content-is-not-suitable-for-zenodo)
- [JOSS Review criteria](https://joss.readthedocs.io/en/latest/review_criteria.html) · [JOSS Review checklist](https://joss.readthedocs.io/en/latest/review_checklist.html)
- [Bioconductor Package End of Life / Deprecation Policy](https://contributions.bioconductor.org/package-end-of-life-policy.html) · [Package guidelines](https://master.bioconductor.org/developers/package-guidelines/)
- [ESSD Review criteria](https://www.earth-system-science-data.net/peer_review/review_criteria.html) · [ESSD Repository criteria](https://www.earth-system-science-data.net/policies/repository_criteria.html)
- [Data Curation Network — CURATE(D) steps](https://datacuration.network/outputs/workflows/) · [CURATED checklist v.2 (U. Minnesota)](https://conservancy.umn.edu/items/2449305b-4cdc-4fbc-9902-2795b020c939)

Note: several primary sites (`cran.r-project.org`, `datadryad.org`, `openwashdata.org`) returned HTTP 403 to direct fetch through the research environment's proxy; findings for those were assembled from search-indexed content and mirror pages, which reproduced the relevant clauses verbatim.
