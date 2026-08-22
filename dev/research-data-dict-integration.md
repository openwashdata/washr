# Research: How tidyverse `data-dict` could work for washr

Date: 2026-08-22
Status: research / design proposal (no code changes yet)

## 1. What data-dict is

[tidyverse/data-dict](https://github.com/tidyverse/data-dict) is a lightweight
**YAML specification for data dictionaries** plus a Rust CLI. A single
`data-dict.yaml` describes a collection of related tables — columns, types,
constraints, relationships, and domain vocabulary — in a form that humans,
tooling, and AI agents can co-author and keep in sync with the actual data.
The spec (currently `$version: 0.1.0`) lives at
<https://data-dict.tidyverse.org>.

Key capabilities of the CLI:

| Command | Purpose |
|---|---|
| `validate-spec` | dictionary file conforms to the YAML schema |
| `validate-meta` | column names/types in the dictionary match the data |
| `validate-data` | actual values satisfy constraints/assertions |
| `describe` | profile a parquet file and draft a dictionary from it |
| `render` | render the dictionary to an HTML page |
| `export-spec` | fully-resolved JSON export |
| `translate` | translate assertions to R, Python, or SQL |

The format is notably richer than a flat CSV:

- **Semantic types**: `number(id)`, `number(ordinal)`, `number(quantity)` (with
  `units`), `string`, `boolean`, `date`, `datetime` (with `time_zone`),
  `enum` (with `values`), `list(...)`, `struct`
- **Constraints**: `primary_key`, `foreign_key`, `required`, `unique`, plus
  SQL-like assertions (`assert: end_date >= start_date`)
- **Representative values**: `examples`, `range`, enum `values`
- **Relationships** between tables with cardinality
- **Glossary** of domain terms
- Dataset- and table-level `label`, `description`, `details`, `origin`, `todo`

## 2. What washr does today

washr's dictionary workflow is CSV-based and roxygen-oriented:

1. `setup_dictionary()` introspects the `.rda` files in `data/` and writes
   `data-raw/dictionary.csv` with columns
   `directory, file_name, variable_name, variable_type, description`
   (`R/setup_dictionary.R`).
2. The author (or `update_gsheet_metadata()` via Google Sheets) fills in
   `description`.
3. `setup_roxygen()` turns the CSV into `R/<dataset>.R` roxygen
   `@format`/`\describe` blocks (`R/setup_roxygen.R`).
4. `update_attributes()` copies the CSV to `data/metadata/attributes.csv`
   for dataspice; `generate_jsonld()` produces schema.org JSON-LD for the
   pkgdown site.
5. `setup_readme()` embeds the dictionary in the README.

Limitations of the current CSV:

- Only free-text `description`; no units, ranges, allowed values, or missing
  value semantics — all common needs for WASH survey data.
- No constraints, so nothing is machine-checkable: a stale dictionary (renamed
  column, new variable) is only caught by eye.
- No cross-table relationships, although openwashdata packages frequently ship
  multiple related tables.
- `variable_type` is the raw R class, which conflates storage type with
  meaning (an ID stored as numeric looks like a quantity).

## 3. How data-dict could work for washr

### Option A — additive exporter (low risk, recommended first step)

Keep `data-raw/dictionary.csv` as the authoring surface and **generate
`data-dict.yaml` from it**, the same way `setup_roxygen()` and
`generate_jsonld()` are downstream renderings today.

- New function `setup_datadict()` / `update_datadict()` writes a
  `data-dict.yaml` at the package root:
  - dataset-level `name`/`description` from `DESCRIPTION` (via `desc`)
  - one `tables:` entry per `.rda` in `data/`
  - column `name`, `description` from the CSV; `type` mapped from R classes:

    | R class | data-dict type |
    |---|---|
    | character | `string` |
    | numeric/integer | `number` (or `number(id)` / `number(quantity)` if enriched) |
    | factor | `enum` + `values` from levels |
    | logical | `boolean` |
    | Date | `date` |
    | POSIXct | `datetime` |

  - `examples:` auto-drawn from the data (first ~5 distinct values), `range:`
    from min/max for numeric/date columns — cheap to compute since washr
    already loads every dataset in `collect_tidydata_info()`.
- Emit YAML with `yaml::write_yaml()` (one small new dependency) or via
  `jsonlite` + a template.

This alone makes every openwashdata package speak the emerging tidyverse
metadata standard, and the YAML becomes AI-agent-readable documentation
(data-dict ships agent skills for exactly this).

### Option B — validation in CI (the real win)

washr packages already export CSV/XLSX copies of each dataset to
`inst/extdata`. data-dict's `source:` currently only supports **parquet**, so:

- add a parquet export alongside CSV/XLSX (e.g. via `nanoparquet`, zero-dep),
  `source: {parquet: inst/extdata/<name>.parquet}` in the YAML;
- add a GitHub Actions step to the openwashdata workflow templates that
  installs the CLI (one-line curl installer, or `uvx data-dict` from PyPI) and
  runs `validate-meta` + `validate-data`.

Result: a renamed column, a type change, or out-of-range values fail CI
instead of silently drifting from the documentation. This directly fixes the
"dictionary is stale" failure mode that a CSV can never catch.

### Option C — YAML as single source of truth (long term)

Invert the pipeline: authors edit `data-dict.yaml` (with LSP/VS Code support
from the data-dict project), and washr derives everything from it:

- `setup_roxygen()` reads YAML instead of CSV (descriptions, plus richer
  `@format` output: units, allowed values, ranges);
- `generate_jsonld()` maps YAML → schema.org `variableMeasured`;
- `dictionary.csv` / `attributes.csv` become generated compatibility exports;
- the Google Sheets round-trip (`update_gsheet_metadata()`) reads/writes the
  YAML's `description` fields;
- `data-dict render` output (or `export-spec` JSON) is embedded in the
  pkgdown site as a proper dictionary page.

This is a breaking workflow change for existing packages, so it should wait
until Options A/B have proven out and the spec stabilises past 0.1.x.

## 4. Frictions to be aware of

- **CLI is a Rust binary, not on CRAN.** washr (a CRAN package) cannot hard-
  depend on it. Generation (Option A) needs no CLI at all; validation (Option
  B) should live in CI and in an optional `check_datadict()` that looks for
  the binary on `PATH` and politely skips otherwise. Watch for a future
  official R wrapper package.
- **Parquet-only `source`.** `.rda` files aren't directly validatable; the
  parquet export in Option B is the bridge (and is independently valuable —
  parquet is a better interchange format than XLSX).
- **Spec is v0.1.0.** Field names may change; keep the exporter small and
  regenerable rather than hand-maintaining YAML in every package.
- **Enrichment is manual.** Auto-generation can infer types/examples/ranges,
  but `number(id)` vs `number(quantity)`, units, and constraints need a human
  (or an AI-assisted pass) — same as descriptions today.

## 5. Suggested roadmap

1. **Phase 1** (`washr`): `setup_datadict()` exporter (Option A) + docs in the
   vignette; add `data-dict.yaml` to `.Rbuildignore` or ship it in `inst/`.
2. **Phase 2** (templates + one pilot package): parquet export, CI validation
   (Option B) on a pilot openwashdata package; add a glossary of WASH terms
   (JMP ladder levels, etc.) — the `glossary:` key is a natural home for
   vocabulary that today lives nowhere machine-readable.
3. **Phase 3**: evaluate making the YAML canonical (Option C) once the spec
   and tooling mature.
