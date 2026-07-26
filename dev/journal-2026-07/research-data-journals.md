# Data Journals Landscape: Research Report for an "openwashdata journal"

Research-agent report, 2026-07-26. Companion evidence to `journal-plan-critique-and-approach.md`.

## 1. Existing data journals and their models

| Journal | Publisher / launch | Model | Fees (APC) | Peer review | Indexing / IF | Time to first IF |
|---|---|---|---|---|---|---|
| **Scientific Data** | Nature/Springer, 2014 | "Data Descriptors"; data must live in a recognized public repository | ~$2,190 / €1,890 | Closed, editor-managed | SCIE, Scopus, PubMed; **IF ≈ 9.8** (2026) | ~3 yrs (first IF 4.8, June 2017 JCR) |
| **Earth System Science Data (ESSD)** | Copernicus, 2008 | Data papers with interactive **public discussion review** | ~€1,400 (often waived via institutional agreements) | Open/interactive, 2-stage | SCIE, Scopus; **IF 13.6** (June 2026, 2025 data); JCR Q1 | first IF released **June 2016**, ~7–8 yrs after launch |
| **Data in Brief** | Elsevier, 2014 | Short "data articles," heavy co-submission pipeline from other Elsevier journals | ~$1,240 | Light, fast (9 days to first decision, 58% acceptance) | Scopus, ESCI, DOAJ, PubMed; **IF ≈ 1.9**, CiteScore low | got IF only after 2023 ESCI change |
| **Journal of Open Humanities Data** | Ubiquity Press, 2015 | Data papers for humanities; low-cost OA | low APC (Ubiquity model, a few hundred GBP) | Traditional | Scopus (SJR 0.152, Q3–Q4); ~76 articles in 2025; no meaningful IF | n/a |
| **Geoscience Data Journal** | Wiley/RMetS, 2013 | Data papers linked to repository deposits | ~$2,080 | Traditional | **IF 2.4** | several years |
| **Biodiversity Data Journal** | Pensoft, 2013 | Data papers + integrated ARPHA publishing pipeline (data-to-paper tooling) | ~$485 | Open review | SCIE; **IF 1.3** (2026), Q3 | first IF ~2021 (~8 yrs) |
| **JOSS** | Open Journals, 2016 | Software papers; **free, GitHub-based** | **$0 (diamond OA)** | Fully open, checklist-based on GitHub | Crossref DOIs, DOAJ, Google Scholar, NASA ADS; **NOT in Scopus or Web of Science** despite years of trying → **no impact factor** | never (10 yrs and counting) |
| **JORS** (Journal of Open Research Software) | Ubiquity, 2013 | Software "metapapers" | ~£350 | Traditional | Scopus, DOAJ; no WoS IF | n/a |

Key pattern: data journals with impact factors are all run by established publishers with APCs of $500–$2,200. The zero-fee, GitHub-native model (JOSS) has credibility and citations but **no IF after a decade** — its non-traditional review process is explicitly cited as the barrier to WoS/Scopus inclusion.

## 2. Getting an impact factor as a new journal

- **Path:** ISSN → DOAJ → Scopus and/or Web of Science ESCI → (optionally SCIE). **Since the 2023 JCR, all ESCI journals receive a Journal Impact Factor**, so ESCI is now the fastest IF route — no need to wait for SCIE promotion.
- **WoS ESCI:** 24 quality criteria (ISSN, peer-review policy, ethics statement, timely publication, editorial-board affiliations, scope consistency, international authorship). Clarivate wants ~**2 years of regular publication** before submission; evaluation itself takes months to years; failed applications trigger embargo periods before re-submission.
- **Scopus:** CSAB review, 6–12 months; ~**2 years of publication history** historically required, though the fixed 2-year rule was **dropped in August 2024** (CSAB still wants substantial published content). Real acceptance rate is **under 20%** of suggested titles.
- **DOAJ:** open-access policy, ISSN, named editorial board with affiliations, documented peer review, article-level metadata, consistent publishing record — realistically achievable within year 1 and essentially free.
- **Volume:** no formal minimum, but journals publishing <20–25 articles/year look fragile to evaluators; timeliness/regularity matters as much as volume.
- **Realistic timeline: 3–5 years minimum** from launch to first IF (2 years of content + 1–2 years evaluation + JCR release cycle). Scientific Data's ~3 years is the best case, with Nature's machinery behind it.

## 3. JOSS as the closest analog

- **Mechanics:** submission = a repo + short (~1,000-word) Markdown paper. Review happens as **GitHub issues in `openjournals/joss-reviews`**, driven by **editorialbot** (open-source, reused by rOpenSci — directly relevant since openwashdata already uses R-package review conventions). Reviewers work through a public checklist; review is collaborative and iterative, not accept/reject.
- **Costs:** famously ~**$3–6 per paper** (JOSS's own 2019 blog: ~$2.71/paper at 300 papers/yr): Crossref DOIs $1/article, Crossref membership ~$275/yr, Portico archiving ~$250/yr, hosting ~$228/yr. Fiscally sponsored by **NumFOCUS** under "Open Journals"; Sloan Foundation grant support.
- **Scale/credibility:** 2,000th paper in May 2023; **400+ papers/yr**; ISSN, DOAJ-listed, Google Scholar-indexed, widely cited (papers like astropy accrue thousands of citations) — credibility came from community adoption, not indexing.
- **The caveat that matters most:** JOSS has **not** been accepted by Scopus or WoS, so no impact factor. If IF is a hard requirement, pure JOSS-cloning is insufficient — you'd need JOSS-style mechanics plus a more conventional-looking editorial layer (formal editorial board, documented review policy, regular "issues"/volumes, ethics statements) to pass Clarivate's 24 criteria.
- Sister journals: **JORS** (Ubiquity, predates JOSS, ~£350 APC) and **JOSE, Journal of Open Source Education** (2018, same Open Journals infrastructure).

## 4. Is a WASH-niche data journal viable?

- **Journal of Water, Sanitation and Hygiene for Development** (IWA Publishing, OA): IF ~1.4–1.8, Q3 — the sector flagship; publishes research/practice papers, **no data-paper article type**.
- **npj Clean Water** (Springer Nature): IF ~11, APC ~$2,990 — high-end, technology-focused, no data papers.
- **Water Research, Water Research X** (Elsevier/IWA): research only; data goes to Data in Brief via Elsevier's co-submission pipeline.
- **Gap: real.** No WASH-specific data journal exists. WASH datasets currently route to generic venues (Data in Brief at $1,240, Scientific Data at $2,190) — both fee-bearing and neither tailored to practitioner data from low-resource settings, where APCs are a genuine barrier. A free venue is a differentiator, and it aligns with Gates Foundation economics (below).

## 5. Lighter-weight credit mechanisms (the competition)

- **DataCite DOIs** via Zenodo/Dryad/figshare/OSF: datasets are already first-class, citable outputs; Zenodo mints DataCite DOIs free. openwashdata packages can get DOIs today at zero cost.
- **Gates Foundation 2025 OA policy** (highly relevant to WASH funding): mandatory preprints, immediate OA, **underlying data must be openly available**, and Gates **no longer pays APCs** (with a PLOS no-APC partnership 2025–27). This punishes APC journals and favors a diamond-OA venue — an argument *for* the model.
- **CRediT taxonomy** (now ANSI/NISO standard) gives contributor-level credit including "Data curation."
- **Data citation metrics** (DataCite Event Data, Make Data Count, Google Dataset Search) are growing but not yet career currency; hiring committees still read journal lines on CVs. That gap — datasets are citable but not "countable" for promotion — is precisely the niche a data journal fills. Evidence consistently shows papers with open data are cited more.

## 6. Risks

1. **No IF for years, possibly ever.** JOSS's decade-long exclusion shows unconventional review can permanently block WoS/Scopus. Scopus real acceptance <20%.
2. **Starvation:** niche data journals run thin — Journal of Open Humanities Data manages ~76 articles/yr with a whole discipline behind it; Ubiquity's Open Health Data publishes a trickle. WASH is far smaller. A journal publishing <10 papers/yr will look dead to indexers and authors alike. (Counter-example of closure: Open Medicine folded in 2014 citing funding.)
3. **Predatory-perception risk** for a new no-name journal: mitigate with named editorial board (ETH/Global South mix), ISSN, DOAJ listing early, transparent review, COPE-style policies.
4. **Volunteer burnout:** JOSS survives on volunteer editors plus bot automation and Sloan/NumFOCUS backing; a WASH journal has a much smaller volunteer pool. Budget for automation (editorialbot is open source) and a paid managing-editor fraction.
5. **Strategic risk:** by the time an IF arrives (2030+), data-citation metrics and funder mandates may have devalued it. A hedge: launch JOSS-style now (DOIs, DOAJ, Google Scholar), pursue Scopus/ESCI opportunistically, and treat IF as an option rather than the value proposition.

Sources: [Scientific Data (Wikipedia)](https://en.wikipedia.org/wiki/Scientific_Data_(journal)), [Scientific Data metrics](https://journalsinsights.com/journals/scientific-data), [ESSD first IF announcement](https://www.earth-system-science-data.net/about/news_and_press/2016-06-17_first-impact-factor-for-essd.html), [ESSD metrics](https://www.journalmetrics.org/journal/earth-system-science-data), [Data in Brief insights](https://www.sciencedirect.com/journal/data-in-brief/about/insights), [Data in Brief metrics](https://researcher.life/journal/data-in-brief/12850), [JOSS about](https://joss.theoj.org/about), [FZ Jülich on JOSS indexing](https://www.fz-juelich.de/en/rse/the_latest/should-i-publish-in-the-journal-of-open-source-software), [JOSS cost models blog](https://blog.joss.theoj.org/2019/06/cost-models-for-running-an-online-open-journal), [JOSS 2000th paper](https://blog.joss.theoj.org/2023/05/JOSS-publishes-2000th-paper), [JOSS design & first-year review (PeerJ CS)](https://peerj.com/articles/cs-147/), [Open Journals joins NumFOCUS](https://numfocus.org/blog/open-journals-joins-numfocus-sponsored-projects), [editorialbot docs](https://joss.readthedocs.io/en/latest/editorial_bot.html), [Scholarly Kitchen on ESCI IFs](https://scholarlykitchen.sspnet.org/2022/07/26/the-end-of-journal-impact-factor-purgatory-and-numbers-to-the-thousandths/), [Clarivate journal evaluation criteria](https://clarivate.com/academia-government/scientific-and-academic-research/research-discovery-and-referencing/web-of-science/web-of-science-core-collection/editorial-selection-process/journal-evaluation-process-selection-criteria/), [Scopus content policy](https://www.elsevier.com/products/scopus/content/content-policy-and-selection), [Scopus policy changes blog](https://blog.scopus.com/scopus-content-policy-and-selection-changes/), [Scholastica on Scopus indexing](https://blog.scholasticahq.com/post/how-to-get-journals-indexed-scopus/), [JWSHD (IWA)](https://iwaponline.com/washdev), [JWSHD metrics](https://researcher.life/journal/journal-of-water-sanitation-and-hygiene-for-development/318), [npj Clean Water metrics](https://www.journalmetrics.org/journal/npj-clean-water), [Biodiversity Data Journal IF](https://www.journalmetrics.org/journal/biodiversity-data-journal), [Geoscience Data Journal (Wiley)](https://www.wiley.com/en-us/journals/Geoscience+Data+Journal-p-20496060), [JOHD metrics](https://www.resurchify.com/impact/details/21101102022), [JORS about](https://openresearchsoftware.metajnl.com/about), [JOSE about](https://jose.theoj.org/about), [Gates 2025 OA policy](https://openaccess.gatesfoundation.org/open-access-policy/2025-open-access-policy/), [Scholarly Kitchen on Gates policy](https://scholarlykitchen.sspnet.org/2024/04/15/gates-2025-open-access-policy/), [Science on Gates preprint mandate](https://www.science.org/content/article/bold-bid-avoid-open-access-fees-gates-foundation-says-grantees-must-post-preprints), [Zenodo data citation guide](https://zenodo.org/records/5523291), [Open Medicine closure (Wikipedia)](https://en.wikipedia.org/wiki/Open_Medicine_(John_Willinsky_journal))
