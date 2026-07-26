# Dataset Discoverability for openwashdata: Findings

Research-agent report, 2026-07-26. Companion evidence to `journal-plan-critique-and-approach.md`.
Question: Zenodo records are reportedly not indexed by Google Scholar — what is actually true, and what are the levers for FAIR, *findable* data publishing?

## 1. Zenodo × Google Scholar — verified status

**Zenodo confirms it is not indexed by Google Scholar for datasets, and explains why.** The official FAQ ([support.zenodo.org, "Is Zenodo indexed by Google Scholar?"](https://support.zenodo.org/help/en-gb/29-indexing/61-is-zenodo-indexed-by-google-scholar)) states: Scholar "only indexes text content (articles)," so non-article resource types are out of scope; and Scholar infers resource type from **URL patterns** (e.g. `/articles/` vs `/data/`), which Zenodo cannot provide because users can change a record's resource type after publishing and Zenodo won't break stable URLs. Zenodo says it has met with Google repeatedly without resolution. So the cause is **both** Scholar's article-only scope **and** Zenodo's inability to signal type via URL — not primarily missing Highwire tags.

**Scholar's inclusion rules** ([Inclusion Guidelines for Webmasters](https://scholar.google.com/intl/en/scholar/inclusion.html)): pages must look like scholarly articles (title, authors, abstract, full text/PDF), one article per unique URL, with Highwire Press tags — minimum `citation_title`, `citation_author` (first author), `citation_publication_date`; PDFs linked via `citation_pdf_url`. A pkgdown data page fails this test regardless of markup — there is no article-like PDF. Scholar does contain *some* dataset records (Webometrics runs a ["Transparent Ranking" of data repositories by Google Scholar presence](https://repositories.webometrics.info/en/data), and a [2024 Scientometrics study](https://link.springer.com/article/10.1007/s11192-024-05073-5) compared dataset citation coverage across GS/WoS/Scopus/DataCite), but this is incidental, not a reliable channel. **Verified conclusion: no amount of metadata tuning gets a Zenodo dataset record into Scholar.**

## 2. Google Dataset Search — the actual dataset channel

- Works purely from **schema.org/Dataset markup (JSON-LD) or DCAT** on ordinary crawled web pages ([Google's Dataset structured-data docs](https://developers.google.com/search/docs/appearance/structured-data/dataset)). Required: `name`, `description`; recommended: `creator`, `license`, `sameAs` (DOI), `distribution`, `isAccessibleForFree`.
- **Zenodo IS indexed by Dataset Search** — stated in Zenodo's own FAQ (Dataset Search reads Zenodo's embedded schema.org metadata). So openwashdata datasets are likely already there, and would appear twice-over if pkgdown pages also carried valid markup.
- For pkgdown sites: embed Dataset JSON-LD in each package page's head (pkgdown supports custom head includes via templates), ensure a **sitemap** (pkgdown generates `sitemap.xml`), and register **openwashdata.org in Search Console**; pages typically appear "within a few days" of crawl.
- Usage evidence is real but modest: grew from ~500K schema.org datasets in 2016 to ~30M+ ([Noy/Brickley, "Google Dataset Search by the Numbers"](https://arxiv.org/pdf/2006.06894); [HDSR paper](https://hdsr.mitpress.mit.edu/pub/psnc8zsr/release/2)); ~45M datasets/13K sources per [Wikipedia](https://en.wikipedia.org/wiki/Google_Dataset_Search). *Inference:* far less used than Scholar by academics, but it is the only Google surface purpose-built for datasets.

## 3. DataCite ecosystem — what the Zenodo DOI buys

Verified: a DataCite DOI feeds [**DataCite Commons**](https://commons.datacite.org/) (citations, views, downloads per record), the **OpenAIRE Research Graph** (Zenodo is an OpenAIRE product; all records flow to [OpenAIRE Explore](https://www.openaire.eu/zenodo-guide)), and **BASE** via Zenodo's OAI-PMH endpoint. Zenodo is covered by the **Web of Science Data Citation Index** (per [re3data record](https://www.re3data.org/repository/r3d100010468)) — subscription-only, but real. [Make Data Count](https://makedatacount.org/find-a-tool/) and the Wellcome-funded [**Data Citation Corpus**](https://support.datacite.org/docs/data-citation-corpus) aggregate data citations to DataCite DOIs. **Limitation (verified pattern):** citations accrue only when papers cite the DOI formally in reference lists *and* publishers deposit the link — coverage is thin, and none of this surfaces in Scholar profiles. Scopus does not systematically index datasets.

## 4. The data-paper workaround — the established fix

A short **data descriptor with a Crossref DOI** (Scientific Data, Earth System Science Data, Data in Brief) is an article: Scholar indexes it, it accrues citations to the author's profile, and its `relatedIdentifiers`/references link to the DataCite dataset DOI. This is the standard "Scholar visibility via paper, data credit via DOI" pattern. **Free interim path (verified):** preprints. [EarthArXiv explicitly documents](https://eartharxiv.github.io/google_scholar.html) that Scholar crawls it ~weekly; [OSF Preprints are fully Scholar-indexed](https://help.osf.io/article/230-preprint-faqs) after CDL/COS optimized metadata with Google. A data-descriptor preprint on OSF/EarthArXiv gets Scholar presence at zero cost, before or without journal submission.

## 5. ETH channel

The [ETH Research Collection](https://library.ethz.ch/en/researching-and-publishing/publishing-and-registering/publishing-research-data.html) is a combined publications + data repository with its own DOIs (10.3929/…) and is covered by the Data Citation Index. *Inference (strong):* as a standard institutional repository it is Scholar-indexed for **text items** — depositing a PDF data descriptor/report there is another Scholar route for an ETH-affiliated group; its dataset records face the same Scholar limits as Zenodo's.

## 6. Ranked action checklist (impact ÷ effort)

1. **Write short data descriptors and post as preprints (OSF/EarthArXiv-style), citing the Zenodo DOI** — the only free, reliable path into Google Scholar. Upgrade the best ones to Data in Brief / Scientific Data later. *(High impact, medium effort.)*
2. **Embed schema.org/Dataset JSON-LD in every pkgdown package page** (name, description, creator with ORCID, license, `sameAs` = Zenodo DOI, distribution = CSV/RDA URLs); validate with Google's **Rich Results Test** and the **Schema Markup Validator**; verify openwashdata.org in **Search Console** with sitemap submitted. *(High impact, low effort — templatable across all packages.)*
3. **DataCite metadata completeness on Zenodo**: full creators/ORCIDs, ContactPerson, funding, and `relatedIdentifiers` (`IsDescribedBy`/`IsSupplementTo`) linking dataset ↔ descriptor both ways — this drives DataCite Commons, OpenAIRE, and the Data Citation Corpus. *(Medium impact, low effort.)*
4. **CITATION.cff in every repo** (via `cffr`) → GitHub "Cite this repository" box; note `.zenodo.json` overrides CFF for Zenodo deposits, so keep both consistent ([Zenodo docs](https://help.zenodo.org/docs/github/describe-software/), [rOpenSci cffr](https://ropensci.org/blog/2021/11/23/cffr/)). *(Medium impact, very low effort.)*
5. **Croissant JSON-LD** (schema.org extension; [MLCommons](https://mlcommons.org/2024/03/croissant_metadata_announce/)) for AI/ML consumers — supported by Dataset Search, Hugging Face, Kaggle; NeurIPS now requires it. Worth adding once item 2 exists. *(Low-medium impact today, low incremental effort.)*
6. **ETH Research Collection deposits** of descriptor PDFs; **Wikidata** entries only opportunistically. *(Low priority.)*

**Bottom line:** Scholar invisibility is structural to Zenodo datasets, not fixable by openwashdata; the levers are (a) article-shaped descriptors/preprints for Scholar, (b) JSON-LD + Search Console for Dataset Search, (c) DataCite relatedIdentifiers for machine-readable paper↔data credit.
