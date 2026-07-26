# openwashdata ecosystem — factual research report (July 2026)

Research-agent report, 2026-07-26. Companion evidence to `journal-plan-critique-and-approach.md`.

**Method note:** The research environment's egress proxy blocked direct fetches of openwashdata.org, CRAN, github.io and zenodo.org. Findings were assembled from web search, the public source repo of the website (`openwashdata/website` — the site is a Quarto site whose catalogue CSV is committed to the repo), the CRAN GitHub mirror (`cran/washr`), and the local washr checkout. Genuinely unverifiable items are flagged.

## 1. openwashdata.org catalogue

- The Data page is a searchable table driven by a Google Sheet (`googlesheets4::read_sheet`), snapshotted to `pages/gallery/data/data_data/tbl-01-openwashdata-datasets.csv` in the website repo. Current snapshot: **56 datasets — 50 "published", 6 "in-progress"**, publication dates 2023-07-11 through 2026-02-26 (so still actively publishing).
- Columns per dataset: id, pkg_name, maintainer (GitHub username), source (ngo 24, academic 20, government 3, private 3, multi-lateral 2), difficulty, status, description, location, date_published, GitHub link, pkgdown website link, DOI, temporal_coverage, keywords. **The public table displays only** id, name, location, status, description, published date and website link — maintainer, source, DOI and keywords are in the data but not shown.
- **DOIs: 40 of 50 published packages have a Zenodo DOI (10.5281/zenodo.*); 10 do not.** DOIs come from the manual Zenodo–GitHub release integration (per the "Data Publishing with washr" guide, chapter `creating_doi.qmd`): first release tagged 0.0.1, upload type switched to "Dataset", DOI badge added to README. ETH Research Collection deposit is described as applying "only to GHE workflow submissions".
- Citation guidance exists per package: washr generates `CITATION.cff` and `inst/CITATION` (`update_citation()`), and READMEs carry DOI + CC BY 4.0 badges (verified on washmalawi). Default dataset license is **CC BY 4.0**.
- **Contribution process:** no web form. "Donate data" (navbar) points to GitHub issues on `openwashdata/data`; the README there instructs: open an issue titled "[data] …", describe the data, do **not** upload files, then the team follows up. The Get Started page tells contributors to get an ORCID iD, a GitHub account, and join the Matrix chat. A 2024-05-17 blog post ("Data donation") walks contributors step-by-step.

## 2. washr on CRAN

- **CRAN version: 1.0.1, published 2024-11-07** (maintainer then: Colin Walder). Title: "Publication Toolkit for Water, Sanitation and Hygiene (WASH) Data"; GPL (>= 3); authors Zhong, Götschmann, Walder, Schöbitz; copyright Global Health Engineering, ETH Zurich; docs at openwashdata.github.io/washr.
- The GitHub repo has since released **1.0.2** (patch: bug fixes to `update_citation()`, `update_description()`, `setup_readme()`; **maintainer changed to Lars Schöbitz**) — the CRAN mirror still shows 1.0.1 as of this research, so 1.0.2 does not appear to be on CRAN yet. Dev version 1.0.2.9000 (Date 2026-07-23).
- What it does: scaffolds an R data package in a consistent structure — tidy data export (`setup_rawdata`), data dictionary (`setup_dictionary`), DESCRIPTION defaults incl. CC BY 4.0 (`update_description`), README (`setup_readme`), pkgdown website with openwashdata theming (`setup_website`), citation files (`update_citation(doi=)`). The full end-to-end process is documented in the Quarto book "Data Publishing with washr" (Global-Health-Engineering/ghedatapublishing).

## 3. Broader offering

- **Academy:** "data science for openwashdata" (ds4owd) — free 10-week course (9 × 2.5 h Zoom + ~3 h/week homework), certificate, requires participants to bring a dataset to share. Iteration 001 produced ~40 graduates; iteration 002 recently wrapped with 40+ graduates (course site ds4owd-002.github.io/website). Site lists "Graduates 2024" and "Graduates 2026" pages.
- **Community:** chat is **Matrix** (ETH `staffchat.ethz.ch`, ~100 active members per the Phase 2 proposal), not Slack; monthly newsletter (~200 recipients); ~10 unique site visitors/day. There is a Code of Conduct page.
- **Funding:** explicitly stated — footer: "This project was supported by the Open Research Data Program of the ETH Board." Phase 1 Explore project "Open WASH data by building Open Science Competencies and Community" ran Mar 2023–Aug 2024; a **Phase 2 Explore proposal** ("Open WASH data by establishing Data Stewards and increasing FAIRness", Schöbitz & Tilley, submitted 2024-02-29) proposes data stewards in Malawi/South Africa, a 12-module data-stewardship curriculum, increased FAIRness, and a governance structure/sounding board. Funding amounts not published.

## 4. Gaps relevant to a journal layer

- **No maintenance policy found** anywhere on the site, guide, or repos.
- **Maintainers/contacts:** tracked internally (GitHub usernames in the sheet; 17 of 50 published packages maintained by one person, emmanuellmhango) but **not displayed** in the public catalogue; contact is a generic ghe@mavt.ethz.ch.
- **No terms of use or contributor agreement found** — only the Code of Conduct and per-package CC BY 4.0 licenses.
- **Versioning:** ad hoc — packages carry versions (e.g., washmalawi 1.0.1) and Zenodo versions DOIs per GitHub release, but there is no stated dataset-versioning policy.
- **No peer review:** the intake is a GitHub issue plus team-assisted cleaning; nothing resembling editorial or scientific review is described publicly. (washr 1.0.1's CRAN "review" was CRAN's technical review only. The pkgreview-based data reviews, e.g. solidwastekampala#17, are internal and not described on the public site.)

## 5. Relationship to academic publishing

- **No data papers found** accompanying any package; publication endpoints are GitHub + pkgdown + Zenodo (+ ETH Research Collection for GHE-internal data). A 2023 webinar was titled "a data sharing workflow that may please the publishers", indicating publisher-facing ambitions, but no journal partnership is stated.
- **No peer-reviewed paper about the project itself found**; the citable outputs are the ORD proposals (posted with citation metadata) and the datasets. The `washopenresearch` package (DOI 10.5281/zenodo.11185699) analyses open-data statements in WASH literature — the closest thing to meta-research output.
- **Citations:** could not verify any citations to openwashdata packages; note Zenodo datasets are not indexed by Google Scholar (Zenodo FAQ), which itself is a discoverability gap. Google Scholar could not be queried directly from the research environment.

Sources: [openwashdata.org](https://openwashdata.org/), [Data catalogue](https://openwashdata.org/pages/gallery/data/), [website source repo](https://github.com/openwashdata/website), [washr on CRAN](https://cran.r-project.org/web/packages/washr/index.html), [washr pkgdown](https://openwashdata.github.io/washr/), [ghedatapublishing guide](https://global-health-engineering.github.io/ghedatapublishing/), [Phase 2 proposal](https://openwashdata.org/pages/gallery/proposal-02/), [ORD portal project page](https://open-research-data-portal.ch/projects/open-wash-data-by-building-open-science-competencies-and-community/), [openwashdata/data](https://github.com/openwashdata/data), [GHE ETH page](https://ghe.ethz.ch/open-science/projects/openwashdata.html).
