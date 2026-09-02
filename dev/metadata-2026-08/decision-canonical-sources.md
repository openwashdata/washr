# Metadata design decision: canonical sources and field mappings

Owner: Lars Schöbitz. Started 2026-08-19, agreed 2026-08-20, ahead of the 2026-09-16 due date (#67). Resolves #47. Governs #68, #69, #70, #71, #87. Binding.

## Decision

Three canonical sources hold every metadata fact. Everything else is generated from them, never hand-edited.

1. **DESCRIPTION**: package name, title, description, license, version, date, authors (Authors@R), repository URL, keywords (see below).
2. **data-raw/dictionary.csv**: datasets and variables (`directory, file_name, variable_name, variable_type, description`).
3. **CITATION.cff**: citation string and DOI. Itself generated from DESCRIPTION by `update_citation()`; the DOI is the only fact entered there and only via the `doi` argument.

`update_metadata()` auto-populates every derivable field in the four dataspice files plus the JSON-LD, and reports the fields that remain blank. The hand-typed creator registry goes away: creators derive from Authors@R.

The staging layer keeps dataspice's file format and drops the dataspice package. `update_metadata()` scaffolds and writes the four CSVs itself, and dataspice leaves Imports. Retiring the CSVs entirely and generating the JSON-LD straight from the canonical sources stays open as a v1.2.0 question, to revisit once the consolidated `update_metadata()` has seen use.

## Field mappings

**biblio.csv** (dataspice schema):

| Field | Source |
|---|---|
| title, description, license | DESCRIPTION (current behavior, kept) |
| datePublished | DESCRIPTION Date |
| citation | DOI from CITATION.cff when present |
| keywords | DESCRIPTION `X-schema.org-keywords` (see below) |
| funder | org default, becomes a config value under #81 |
| geographicDescription, bounding coords, wktString, startDate, endDate | manual, reported blank |

**access.csv**: one row per dataset per distribution (csv, xlsx). `fileName`/`name` from dictionary `file_name`. `contentUrl` built from the repository URL in DESCRIPTION; the current code assumes the repo is named after the dataset file, which is wrong for any package whose dataset name differs from the repo name. `encodingFormat` becomes a MIME type (`text/csv`, `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`).

**attributes.csv**: a projection of the dictionary, not a verbatim copy: `fileName <- file_name`, `variableName <- variable_name`, `description <- description`, `unitText` manual, reported blank. `directory` and `variable_type` stay dictionary-only; they have no dataspice home. The current copy of all five dictionary columns does not conform and breaks dataspice tooling.

**creators.csv**: derived from Authors@R, roles aut and cre. `name` from given and family, `email` from person, `id` from the ORCID comment when present, `affiliation` from an affiliation comment when present, else the org default. `add_creator()` is removed.

## Keywords: one canonical home

Keywords live in DESCRIPTION as `X-schema.org-keywords` (comma-separated). From there they flow to CITATION.cff (verified 2026-08-20: cffr 1.4.1 reads the field into the CFF keywords array; satisfies the advisory keywords in openwashdata/pkgreview#35), to biblio.csv, and to the JSON-LD keywords array. No other file accepts hand-entered keywords. Preservation mechanics across regeneration are #73's scope.

## Artifacts and what each is for

- **data/metadata/*.csv**: machine-readable staging, input to the JSON-LD. Repo-only (Rbuildignored), never shipped.
- **CITATION.cff and inst/CITATION**: citation for humans, GitHub, Zenodo, and R's `citation()`.
- **JSON-LD (schema.org/Dataset)**: search-engine discoverability. It has value only when embedded in a crawlable page, so it belongs to the pkgdown site pipeline, not the tarball: generated next to its sources and embedded in the site (implementation in #70 and #87), no longer written to `inst/extdata/`.

dataspice conformance means the four CSVs use dataspice's exact column schemas with one row per unit (file-distribution for access, variable for attributes), so dataspice tooling stays usable for anyone who wants it. It does not mean using dataspice's interactive editors, and it does not keep the dataspice package as a dependency; conformance is to the file format only.

## Consequences

- **#68**: `update_metadata()` becomes the one call: scaffolds missing files without prompting, populates all mappings above, regenerates the JSON-LD, reports blanks (geographic, temporal, unitText). Idempotent. It writes the dataspice-format files itself, without the dataspice package.
- **#69**: `update_gsheet_metadata()` is removed; the Google Sheet is not a canonical source.
- **#70**: `generate_jsonld()` is rewritten: `@context` https://schema.org, name/description/license/version/datePublished from DESCRIPTION (no `lubridate::today()`), creator array from Authors@R, contactPoint from the maintainer, distribution rows from access.csv with MIME types.
- **#71**: `update_metadata()` stays exported alongside `update_citation()`; the helpers (`update_biblio()`, `update_access()`, `update_attributes()`, `add_metadata()`, `add_creator()`, `generate_jsonld()`) go internal or are absorbed.
- **#87**: the dataspice CSVs stay as the staging layer under `data/metadata/`; the JSON-LD leaves `inst/extdata/`.
- **#72**: the metadata decisions remove three Imports (dataspice here, googlesheets4 via #69, lubridate via #70), taking Imports from 16 to 13 before the core cuts.
- **#47**: closed by this document; `add_metadata()` is consolidated and auto-populated, not deleted in isolation.

## Out of scope

Zenodo automation (#56, v1.2.0), the org website catalog, any new external service, and the mechanics of org configuration (#81) beyond naming funder and publisher as future config values.

## Amendment 2026-09-02: no staging CSVs, coverage fields in DESCRIPTION

Decided by Lars Schöbitz on 2026-09-02 after the engine plus driver review (#111) and the decision support posted there. Triage record: #113.

1. The staging layer is dropped. `update_metadata()` builds the schema.org Dataset object directly from the three canonical sources and the file listing of `inst/extdata`, embeds it in the pkgdown page head, and reports the fields that remain blank. No `data/metadata/` folder is created, and the dataspice file format is no longer a target. The field mappings above apply unchanged to the JSON-LD; where they name a CSV column, read them as JSON-LD properties.
2. The helpers are deleted, not made internal: `add_metadata()`, `add_creator()`, `update_access()`, `update_attributes()`, `update_biblio()`, `update_gsheet_metadata()`. `generate_jsonld()` becomes the internal builder called by `update_metadata()`. None of them shipped on CRAN, so no deprecation cycle applies.
3. Spatial and temporal coverage live in DESCRIPTION as `X-schema.org-spatialCoverage` and `X-schema.org-temporalCoverage`, as text and under the same prefix as the keywords (e.g., "Kampala, Uganda" and the ISO 8601 interval "2022-03-01/2022-09-30"). A per dataset override in data-dict.yaml can follow once #105 exists, with the DESCRIPTION value as the package default. `unitText` stays blank until the dictionary gains a unit column (openwashdata/pkgreview#38).
4. Distributions: one JSON-LD `distribution` entry per file found in `inst/extdata`, matched to a dataset by name prefix, with the MIME type from the extension (`text/csv`, `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`, `application/gzip` for `.csv.gz`). No entry is invented for a file that does not exist (#100).
5. Packages that already carry `data/metadata/` or `data-raw/metadata/` keep their files; washr ignores them. NEWS records the change.

Consequences for the issues: #68 and #70 merge into #68 (derive, embed, report, validate). #71 becomes the deletion issue and closes #100 when it ships. #87 is closed by this amendment. The three Imports that #72 removes are unchanged. In the "Artifacts" section above, the CSV entry no longer applies; CITATION.cff, inst/CITATION and the JSON-LD stand. The "retire the CSVs entirely" question recorded for v1.2.0 is answered now.
