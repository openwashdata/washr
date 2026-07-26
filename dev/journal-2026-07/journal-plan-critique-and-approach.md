# openwashdata journal: plan critique and structured approach

Date: 2026-07-26
Status: strategy document, decision-support for the maintainer (Lars). No code changes implied for washr v1.0.2/v1.1.0 scope.
Companion evidence: `research-data-journals.md`, `research-submission-governance.md`, `research-openwashdata-ecosystem.md` in this directory.

## The plan under critique

Add a CRAN-like submission layer to the openwashdata catalogue (defined maintainer with
email, terms of reference clarifying responsibility) as preparation for an openwashdata
journal — a data journal for WASH with an eventual impact factor, so that researchers and
practitioners get credit for primary raw data, on the thesis that written articles are
becoming mechanical to produce while original raw data becomes the scarce, valuable input.

## Verdict in one paragraph

The submission layer is unambiguously right and should be built regardless of the journal
— it formalizes what CRAN already forces on washr itself and what pkgreview already
sketches, and it closes gaps that are visible from the outside today (no maintenance
policy, maintainers hidden, no contributor agreement, no versioning policy). The journal
is a real gap with genuinely good timing, but the plan as stated contains one structural
tension that must be resolved by design, not discovered later: the lightweight
GitHub-native model that fits openwashdata's community (JOSS-style) is precisely the model
that has failed for ten years to obtain an impact factor, while the impact factor is the
stated core incentive. Both are achievable, but only if the journal is deliberately built
to look conventional to Clarivate/Scopus while operating openly — and only if throughput
(~20–25 reviewed publications/year) can be sustained, which at the catalogue's current
rate (~17 datasets/year, heavily concentrated on few maintainers) is not yet true.

## A. What the evidence supports (strengths of the plan)

1. **The gap is real.** No WASH-specific data journal exists. The sector flagship
   (Journal of Water, Sanitation and Hygiene for Development, IWA) has no data-paper
   article type. WASH datasets currently route to Data in Brief (~$1,240 APC) or
   Scientific Data (~$2,190 APC) — fee walls that exclude exactly the Global South
   practitioners openwashdata serves.

2. **Funder timing favors a diamond-OA venue.** The Gates Foundation 2025 OA policy
   stopped paying APCs entirely and mandates open data. A zero-fee data journal is
   aligned with where the biggest WASH funder is pushing.

3. **The impact factor is more attainable than JOSS's history suggests — via one
   specific door.** Since the 2023 JCR, every journal in Web of Science ESCI receives an
   impact factor. ESCI has 24 quality criteria but they are procedural (ISSN, named
   editorial board with affiliations, documented peer review policy, ethics statements,
   timely regular publication, international authorship) — not "be Nature". Realistic
   timeline: ~2 years of regular publishing + 1–2 years evaluation = first IF in year
   3–5. Scopus's fixed 2-year history rule was dropped in 2024, but real acceptance of
   suggested titles is under 20%.

4. **Most of the machinery already exists in-house.** washr scaffolds the artifact;
   pkgreview's tiered checklist and GitHub-issue reviews (e.g. solidwastekampala#17) are
   a proto-editorial process; Zenodo DOIs exist for 40/50 published packages; JOSS's
   editorialbot is open source and already reused by rOpenSci. openwashdata is closer to
   JOSS-grade mechanics than almost any journal founder ever is at this stage.

5. **The core value thesis is directionally sound.** Data descriptors are largely
   mechanical given a well-documented dataset — a washr package with a complete
   dictionary, README and metadata nearly *is* the data paper. That is an asymmetric
   advantage: the marginal cost of a paper on top of a reviewed openwashdata package is
   close to zero, which no incumbent data journal can match.

## B. Where the plan is exposed (weaknesses and blind spots)

1. **The JOSS paradox — the central tension.** JOSS is free, GitHub-based, credible,
   heavily cited, and after a decade still has no impact factor because Scopus/WoS view
   its checklist-driven open review as unconventional. You cannot copy JOSS's mechanics
   wholesale and also promise an IF. Resolution: keep the open GitHub review as the
   *mechanism*, but wrap it in the conventional *form* indexers evaluate — named
   editorial board, formally documented two-reviewer policy, editorial decisions recorded
   per article, ISSN, regular volumes, COPE-aligned ethics pages, archival arrangement.
   ESSD proves open interactive review can carry an IF (13.6) when the editorial form is
   conventional.

2. **Throughput is the binding constraint, not money.** JOSS's marginal cost is ~$3–6
   per paper; money is a non-issue. But a journal publishing under ~20 papers/year looks
   dead to indexers and authors. The catalogue has published 50 datasets in ~3 years, 17
   of 50 by a single maintainer, and the intake funnel is untested as a review pipeline.
   Journal of Open Humanities Data manages ~76 articles/year with an entire discipline
   behind it. The ds4owd academy (40+ graduates/cohort, each required to bring a
   dataset) is the credible pipeline — but conversion from "graduate with dataset" to
   "reviewed publication" is unproven. The go/no-go for the journal must be a measured
   throughput gate, not enthusiasm.

3. **The maintainer requirement is necessary but insufficient — washr's own history
   proves it.** The v1.0.2 release was gated on exactly this failure: CRAN mail going to
   a departed maintainer's dead mailbox (premortem R2). WASH practitioners and NGO staff
   churn faster than academics. A CRAN-style "one person, one email" rule will fail
   routinely. The policy needs, from day one: an institutional fallback contact
   (DataCite's `ContactPerson` contributor type explicitly supports organizational
   contacts), a succession path (rOpenSci documents maintainer handover; Bioconductor
   runs a staged one-year end-of-life for unresponsive maintainers), and archival-not-
   deletion as the end state. openwashdata itself (the org) must be the maintainer of
   last resort, and the ToR must say so.

4. **Single-maintainer bandwidth — your own premortems' top risk — scales worst in a
   journal.** Both the washr and pkgreview premortems independently named maintainer
   bandwidth the most likely failure for ordinary package milestones. A journal is an
   editorial commitment with no ship date and volunteer burnout is the documented killer
   of small journals. The mitigations are structural: an editorial board that actually
   handles submissions (not a letterhead board), bot automation for everything checkable
   (the `check_publication_readiness()` gate, #82, is the R CMD check analog), and a
   paid managing-editor fraction — which is exactly what the ORD Phase 2 "data stewards"
   proposal could fund.

5. **The impact-factor thesis has a hedging problem.** By the time a first IF can arrive
   (realistically 2030±1), data-citation infrastructure (DataCite Event Data, Make Data
   Count) and funder mandates may have shifted how data credit is counted; conversely,
   hiring committees still read journal lines today and will for years. Both halves
   matter: the journal's value proposition must stand *without* the IF (DOI, citable
   venue, peer-review quality signal, discoverability, community), with the IF treated
   as an option that arrives later — not the promise made to early authors. Never market
   the IF before it exists; that is the predatory-journal tell.

6. **Three layers are being conflated, and they have different clocks.** (a) The
   submission/maintainership layer — cheap, needed now, valuable even if no journal ever
   launches. (b) The editorial review process — pkgreview formalized into published
   review criteria with external reviewers; valuable standalone as a "certified
   catalogue". (c) The journal wrapper — ISSN, paper DOIs, editorial board, indexing
   applications; a separate, gated decision. Building them as one bet risks the whole
   stack on the hardest layer. Built as a→b→c, each layer de-risks the next and (c) can
   be abandoned without losing (a) and (b).

7. **Smaller factual gaps to close on the way** (from the ecosystem scan): 10 published
   packages lack DOIs; maintainers are tracked internally but not displayed publicly;
   Zenodo records are not indexed by Google Scholar (a data *paper* with a Crossref DOI
   fixes discoverability that datasets alone don't get); there is no stated versioning
   policy; the guide's ETH Research Collection path applies only to GHE-internal
   submissions.

## C. Structured approach

### Phase 1 — Submission layer ("the CRAN layer"), target: alongside the September 2026 milestones

Deliverable is one public policy document plus small mechanical changes. Do not let it
balloon into the journal.

1. **Write the openwashdata Dataset Publication Policy (the terms of reference).** One
   page-scale document, CRAN-policy style, versioned in a public repo. Contents:
   - **Maintainer**: every dataset names one maintainer with a monitored email
     (DESCRIPTION `cre`, surfaced as DataCite `ContactPerson`), plus a required
     institutional fallback contact; openwashdata is maintainer of last resort.
   - **Obligations**: respond to data issues within a stated window (e.g. 4 weeks);
     keep contact details current; a bouncing address starts the clock on the
     end-of-life process.
   - **End-of-life/succession** (Bioconductor template): staged outreach → public call
     for a new maintainer (rOpenSci pattern) → archival with the DOI and record kept
     citable. Archive, never delete.
   - **Floor requirements**: CC BY 4.0 (or opt-out justification), complete dictionary,
     passing `R CMD check`, DOI minted before "published" status, PII screening
     attestation (pkgreview already has the PII chapter).
   - **Versioning**: semantic dataset versioning; Zenodo versioned DOIs; what
     constitutes a new version vs a new dataset.
   - **Responsibility split**: what the maintainer warrants (provenance, consent/PII,
     license authority) vs what openwashdata provides (hosting, tooling, review,
     archival). This is the clause that protects both sides and is currently absent.
2. **Mechanical changes, mostly already planned**: surface the maintainer + DOI in the
   public catalogue table (data exists in the sheet already); mint the 10 missing DOIs;
   `check_publication_readiness()` (#82) becomes the automated submission gate; the
   intake issue template on openwashdata/data gains the policy checklist (maintainer,
   fallback contact, license authority, PII attestation).
3. **Explicitly out of scope**: anything requiring new services, the journal name, ISSN.
   The washr v1.0.2/v1.1.0 plan is already full; this phase consumes policy-writing
   bandwidth, not engineering bandwidth.

### Phase 2 — Editorial layer ("the rOpenSci layer"), 2027

Formalize what pkgreview already does into something that reads as peer review to an
outsider.

1. Publish the **review criteria** as a standalone document: merge pkgreview's tiers
   with the Data Curation Network CURATE(D) checklist and ESSD's three reviewer
   questions (significant/complete? usable with adequate metadata? claims evaluable?).
2. **Two-named-reviewer open review** on GitHub issues (rOpenSci/ESSD hybrid): one
   technical (runs the checks — largely bot-assisted), one domain (WASH substance).
   Editor role assigns and closes. Every accepted dataset gets a citable review record.
3. **Recruit 3–5 handling editors** now, not at journal launch: ds4owd graduates + the
   Phase 2 data stewards + 1–2 external WASH academics. This is also the future
   editorial board forming, and the earliest test of whether the volunteer pool exists.
4. **Pilot**: run ~10 datasets (mix of new intake and existing fleet) through the full
   pipeline in two quarters. Measure: elapsed time, editor-hours per dataset, reviewer
   acceptance rate when asked. These numbers are the Phase 3 gate.

### Phase 3 — Journal wrapper, decision gated (~2028)

**Gate to launch** (all three, measured, not vibes): sustained reviewed throughput ≥
20/year for two consecutive quarters; ≥ 3 active handling editors who are not Lars;
funding line for a managing-editor fraction (ORD Phase 2 or successor). If the gate
fails, stop at Phase 2 — a certified, reviewed catalogue with DOIs is a respectable
permanent end state, and nothing from Phases 1–2 is wasted.

If launched:

1. **Form**: short data descriptors (2–4 pages) generated substantially from the package
   (README + dictionary + provenance narrative) — washr eventually gains
   `generate_paper()`; the dataset DOI (Zenodo/DataCite) and the paper DOI (Crossref,
   $1/article + ~$275/year membership) are distinct and cross-linked. Diamond OA,
   no fees, ever.
2. **Infrastructure**: Open Journals stack (editorialbot) or plain Quarto + GitHub —
   marginal cost per paper is single-digit dollars; Portico/CLOCKSS archival
   arrangement early (indexers check).
3. **Conventional shell around open review**: ISSN at launch; publisher of record
   decided deliberately (ETH library imprint vs association vs foundation — affects
   perceived independence and continuity); editorial board with international and
   Global South representation, listed with affiliations; COPE-aligned policies;
   fixed publication cadence (continuous publication, quarterly issue rollups).
4. **Indexing sequence**: DOAJ within year 1 (near-free, achievable, the anti-predatory
   signal); Google Scholar via proper paper metadata (fixes the Zenodo invisibility);
   apply to Scopus and WoS ESCI after ~2 years of regular publishing; treat the IF as
   arriving year 4–5 if at all. A failed application triggers an embargo — do not apply
   early.
5. **Positioning**: "the venue where WASH data becomes a first-class, peer-reviewed,
   citable publication — free for authors and readers." The IF is never the pitch until
   it exists.

### Standing kill criteria (in the house premortem style)

- Phase 1 policy not agreed within 6 weeks of starting: cut to maintainer + EOL clauses
  only and ship; the rest iterates.
- Phase 2 pilot shows > ~8 editor-hours per dataset after bot automation: the review
  design is too heavy for the volunteer pool — simplify the checklist before scaling.
- Phase 3 gate unmet by end of 2028: park the journal, keep the certified catalogue,
  revisit yearly.
- Any pressure to promise the impact factor to prospective authors before a first JCR
  listing: refuse; it is the predatory-journal tell and would burn the credibility the
  whole plan depends on.

## D. On the vision itself

The thesis — raw primary data appreciating while article-writing commoditizes — is
directionally right and is, in fact, an argument that the *packages* are the product and
the journal is credit infrastructure around them. Two refinements. First, if article
production is mechanical, a journal whose papers are mechanically derived must locate its
value precisely in what is *not* mechanical: the review (provenance, consent, methods,
reusability judgment) and the maintenance contract (a maintained dataset with a
responsive contact is worth more than a static deposit — no incumbent journal offers
that; openwashdata can, and Phase 1 is what makes it true). Second, the moat is not the
impact factor — anyone can eventually get one — it is the workflow-community-stewardship
stack (washr + academy + data stewards + review) that makes WASH data *maintained* rather
than merely deposited. The journal converts that stack into academic currency; it should
never be mistaken for the stack itself.
