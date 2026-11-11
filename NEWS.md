# washr (development version)

## New

- `check_publication_readiness()` has a new item, `article_packages`. It reads the R chunks and the inline R code of every `.Rmd` and `.qmd` file under `vignettes/` and fails when an article loads a package (`library()`, `require()`, `requireNamespace()`, `loadNamespace()` or `pkg::`) that DESCRIPTION does not declare in `Config/Needs/website`, `Suggests`, `Imports` or `Depends`. The pkgdown workflow installs only what DESCRIPTION declares, and four of the five site build failures of the move to the workflow came from such a package. Chunks with `eval = FALSE` are left out. The package itself, base R and the dependencies of a declared package that is installed (dplyr under tidyverse) count as declared. The fix names `Config/Needs/website`. The item is not applicable without an article (#143).

## Fixed

- The switch between the light and the dark theme shows on the package sites. The navbar of the `setup_website()` template lists `lightswitch`, but pkgdown shows the switch only when the template says `light-switch: true`, and the line was missing. The dark theme, and with it the dark logo that `use_brand()` installs, was never reached. The template now carries the line, and `update_website()` adds it to an existing Bootstrap 5 `_pkgdown.yml` (reported as `"lightswitch"`); a file that already sets `light-switch`, also to `false`, keeps its value. The washr site gets the line too. An existing site shows the switch after `update_website()` and the next site build.

# washr 1.3.0

## New

- `check_publication_readiness()` has a new item, `version_follows_data`. On a release version with a tag `v<version>`, it fails when `data/`, `inst/extdata/` or `data-raw/dictionary.csv` differ from that tag, uncommitted and untracked files included. An `.rda` file counts as changed only when its objects differ, and an `.xlsx` file in `inst/extdata/` only when the `.csv` file of the same name changed too. The fix names `usethis::use_dev_version()`, then `update_citation(build = FALSE)` and `update_metadata()`. The item is not applicable on a development version, without git, without the tag (also in a shallow clone that lacks it) or when the package is not the root of its git repository. The vignette describes the rule behind it: the version of a data package changes only when the data, or their meaning, change (#163).
- `data_availability_statement()` drafts the text for the authors of an article that uses a data package, once the DOI is on file: the reference list entry in APA style (authors with roles `aut` and `cre` in Authors@R order, "&" before the last author, the first 19, an ellipsis and the last with more than 20, version, `[Data set]`, the DOI link and the repository), the data availability statement (licence, package, version, DOI, the website for the CSV and Excel downloads) and the in-text citation ("Feni et al., 2026"). The opening words of the statement come from the `subject` argument ("The data" by default). An optional last sentence on data left out of the package comes from the new field `Config/washr/withheld` in DESCRIPTION. `clipboard = TRUE` copies the reference and the statement with clipr, a new Suggests. The function stops when `CITATION.cff` carries no DOI yet and warns on a development version (#155).
- ROR identifiers in the schema.org metadata. The new field `Config/washr/parent-organizations` in DESCRIPTION names the organisations above the publisher, nearest first, as `Name <url>` entries separated by semicolons. `update_description()` writes it with the other defaults: for openwashdata the chain Global Health Engineering (<https://ghe.ethz.ch/>), the Institute of Design, Materials and Fabrication (ROR 03zqk4w67) and ETH Zurich (ROR 05a28rw58), and `none` for another organisation. `update_metadata()` nests the chain under the publisher as `parentOrganization`, both for a `cph` entity and for the organisation that stands in without one; a `https://ror.org/` URL becomes the `@id` of its entry, any other URL its `url`. An organisation entity in `Authors@R` (`cph`, `fnd`) can carry its own ROR in the comment field, `comment = c(ROR = "05a28rw58")`, which becomes its `@id`. `check_publication_readiness()` has a new item, `publisher_ror`, which passes when the chain carries at least one ROR and is not applicable when the profile names none. `.zenodo.json` and `CITATION.cff` are unchanged (#153).
- `setup_rawdata()` and `setup_readme()` handle several datasets. `setup_rawdata(datasets = )` takes the names of the tidy data objects, writes one `usethis::use_data()` line per dataset into `data-raw/data_processing.R` and exports each of them to `inst/extdata/` in one loop over the names; without it the one dataset is named after the package, as before, through the same loop. A name that is not a valid R name stops the run. `setup_readme()` writes one data section per object in `data/`, alphabetically, or for the objects named in its new `datasets` argument; with several objects the introduction names their number, the Example section keeps the first object, and an object without rows in the dictionary gets a warning. The README of a single dataset is unchanged. The hand edits the vignette described for a package with several datasets are no longer needed (#103).
- `update_metadata()` also writes the schema.org JSON-LD as a file, `pkgdown/assets/metadata.jsonld`, which pkgdown copies to the root of the site (`<site>/metadata.jsonld`). The file carries the same text as the JSON-LD in the head of the pages and is written only when it changed. The README template links it in one sentence of the Citation section when the package names its site, so the link reaches the `llms.txt` of the site. `check_publication_readiness()` has a new item, `site_jsonld`, which passes when the file is present and equals the JSON-LD in the page head, and is not applicable without `_pkgdown.yml` (#137).

## Changed

- `update_zenodo_json()`, and with it `update_citation()`, links the package website on the Zenodo record. The description gets a second paragraph, "Explore the data on a curated website", with the link, written as HTML, which Zenodo renders. The website is also a related identifier with the relation `isDocumentedBy`. The website is the `url` in `_pkgdown.yml`, or else the `github.io` entry of the DESCRIPTION `URL` field; without one, the description stays as it was. The repository link (`isSupplementTo`) is now written always, not only when the package names source articles. Existing packages get a new `.zenodo.json`: `check_publication_readiness()` reports the `zenodo_json` item as differing until `update_citation()` runs again, which belongs to the next release of each package (#154).
- `update_dictionary()` brings a dictionary in an older layout to the washr layout before it matches the rows to the data: an unnamed index column and unnamed empty columns are dropped, `directory` and `file_name` are derived from the data objects when the file lacks them or holds placeholders (a variable that several data objects carry gets one row per object), the five washr columns come first and every other column keeps its place after them. `update_metadata()` then runs on those packages. A row whose variable no data object carries stops the run with the variable named. `check_publication_readiness()` accepts named columns after the five in `dictionary_schema`, as `update_dictionary()` keeps them (#151).
- `update_description()` writes `Date` once and then keeps it; a release sets the date on purpose with the new `date` argument (`"today"` or a `Date`). The site branding passes had to restore the field on 59 packages whose data had not changed (#150).

## Fixed

- `update_metadata()` pins the download URLs of the JSON-LD (`contentUrl`) to the release tag `v<version>`, so a citation of a release gets the same files later. A development version still points at the main branch. It is the rule the README template uses for its download links (#137).
- `setup_roxygen()` no longer stops on its first call in a package without an `R/` folder; it creates the folder itself (#144).
- `update_description(date = )` with a value that is not `"today"`, a `Date` or a `"YYYY-MM-DD"` string now stops with those accepted forms named, before the file is touched, in place of the error from `as.Date()` (#150).

# washr 1.2.2

The release that puts the openwashdata logo on every package site and moves the publisher line off the top of the README. A GitHub release, like 1.2.1; the next CRAN submission carries both.

## New

- The openwashdata logo on every package site and README. `use_brand()` installs the small logo of the brand as the package logo (`man/figures/logo.png`), which pkgdown shows beside the title of the home page, adds it to the title line of README.Rmd so GitHub shows it too, and, when the brand names a dark counterpart, writes it to `pkgdown/assets/logo-dark.png` with the one rule in `pkgdown/extra.css` that shows it on the dark theme. It also lists `brand.yml` in `Config/Needs/website`, which the site build needs once the site is wired to the brand (#148, #143).
- The README template no longer opens with a line under the badges. The publisher is named as the first line of the Citation section, with the website written out ("Published by openwashdata, <https://openwashdata.org>."), and `setup_readme()` shows the installed logo at the title (#148).

# washr 1.2.1

The release that puts the names of washr and openwashdata on every package site. It carries the site items only; the skill and metadata work follows in 1.3.0.

## New

- Every package site now says what made it and where it belongs (#145). The
  footer names the washr version that last updated the package ("Package
  built with washr 1.2.1.") next to the pkgdown line, and carries the
  publisher sentence with links ("Published by openwashdata, a project of
  Global Health Engineering at ETH Zurich."). The navbar links to the
  website of the organisation, the sidebar gets an openwashdata block with
  the data catalogue and the newsletter under the Funding block, the README
  template opens with "A data package published by openwashdata.", and the
  schema.org metadata names the data catalogue in `includedInDataCatalog`
  and the website as the publisher url. The texts and links are four new
  `Config/washr/` fields in DESCRIPTION (`publisher`, `home`, `catalog`,
  `community`), written by `update_description()` with the openwashdata
  defaults and as `none` for another organisation, whose sites carry the
  washr line and nothing that names openwashdata. A package moved to
  another organisation by editing `URL` gets the same: the fields that
  still hold the openwashdata defaults follow on the next
  `update_description()`.

- `update_website()` brings an existing `_pkgdown.yml` in line with the
  current template: it adds the footer, the navbar link, the sidebar blocks
  and the Open Graph image where they are missing, refreshes the washr
  version in the footer, and keeps the reference index, hand edits, comments
  and the brand wiring. A footer, navbar or sidebar written by hand keeps
  its components, and lists written at the indent of their key, as the
  yaml package leaves them after `use_brand()`, are edited in place like
  the others. A current file is left untouched. `update_description()`
  refreshes the washr version in the footer on its own, so the footer and
  `Config/washr/version` never disagree.

- `use_brand()` sets the Open Graph image of the site to the social preview
  of the brand repository at the installed release, so a shared link to the
  site shows the image of the organisation. A brand repository without
  `assets/social-preview.png` leaves the image as it is.

- `check_publication_readiness()` gets two items in the docs area:
  `pkgdown_washr_version` (the footer names the version that
  `Config/washr/version` records) and `pkgdown_publisher` (the publisher
  sentence of the organisation, verbatim). A review profile passes the
  sentence as `publisher_text`.

# washr 1.2.0

The release that makes washr the engine of a guided workflow. Every
function now reports through cli and returns what it wrote, a readiness
report says what a package still lacks before publication, and the values
that were fixed to openwashdata live in DESCRIPTION, so another group can
publish with its own. Three exports are new: `check_publication_readiness()`,
`update_dictionary()` and `update_zenodo_json()`. This release also brings
the changes of 1.1.1 to CRAN, which was released on GitHub only.

## New

- `check_publication_readiness()` reads the package and reports, item by
  item, whether it is ready for publication: metadata, data dictionary,
  documentation and the check workflow. Each gap names the step and the
  washr function that closes it. The result is a data frame with one row
  per item (`id`, `area`, `check`, `status`, `detail`, `fix`), so review
  tools such as pkgreview can consume it. Nothing is written to the package
  (#82).

- `update_dictionary()` brings `data-raw/dictionary.csv` in line with the
  data after it changed. It adds a row for each new variable, removes the
  row of a variable that no longer exists, refreshes the types, and keeps
  every description and every column you added yourself, such as `unit` or
  `allowed_values`. A file whose content is current is left untouched. The
  "already exists" error of `setup_dictionary()` now points to it (#13).

- `update_zenodo_json()` writes `.zenodo.json` from DESCRIPTION, and
  `update_citation()` calls it. Zenodo reads the file when it archives a
  GitHub release, so a data package is filed as a Dataset in the
  openwashdata community, with its creators, ORCID iDs, license and
  keywords, without edits by hand. Set `Config/washr/zenodo-community` in
  DESCRIPTION for another community (#56).

- `update_citation()` cites the source article of a package that republishes
  data from a publication. List the article DOI in DESCRIPTION as
  `X-schema.org-isBasedOn`, and separate several DOIs with commas. Each DOI
  is looked up at doi.org and written as a `references` entry in
  CITATION.cff, with a message that asks users to cite both the data package
  and the article. `inst/CITATION` holds both entries under the same header,
  so `citation()` prints both. The package stays the work that GitHub's
  "Cite this repository" shows. A DOI that cannot be looked up keeps its
  entry from the existing CITATION.cff, so a run without a network
  connection changes nothing. References that do not come from the field
  are dropped, because DESCRIPTION is their canonical source. Before, the
  function had no way to keep such a reference, and a hand-written second
  entry in `inst/CITATION` was lost on the second run (#134).

- `update_metadata()` writes the same DOIs as schema.org `isBasedOn` in the
  JSON-LD (#134).

- `options(washr.quiet = TRUE)` silences the messages of washr and of the
  usethis helpers it calls, for use in scripts. Warnings and errors are
  never silenced (#84).

- The README of `setup_readme()` says in plain text which version to cite
  with which DOI, links the authors page of the site and `CITATION.cff`,
  and names the source article of republished data. Its download links
  point at the release tag of the version in DESCRIPTION, so a citation of
  a version leads to the same files later; a development version links the
  main branch. pkgdown 2.2.0 builds the `llms.txt` of a site from the
  README, so AI tools now read the same. `check_publication_readiness()`
  gains two items: `readme_citation` (README.md names the DOI of
  CITATION.cff) and `pkgdown_llm_docs` (`_pkgdown.yml` keeps the
  `llms.txt` of the site) (#137).

## Changed

- washr reads the facts of a package from DESCRIPTION, so a group other
  than openwashdata publishes with its own values by editing that file.
  The organisation and the repository come from `URL`, the license from
  `License`. The values with no standard field are `Config/washr/` fields
  that `update_description()` writes once and never overwrites: `funding`,
  `analytics-domain`, `doi-provider`, `zenodo-community` and
  `brand-source`, plus `pages-domain` for a site that is not served from
  `<organisation>.github.io`. A field set to `none` switches its feature
  off. The README template, the `_pkgdown.yml` template, the DOI badge,
  `.zenodo.json`, `use_brand()` and `check_publication_readiness()` read
  them. For an openwashdata package the output is unchanged (#81).

- `update_description()` takes the GitHub organisation from the repository
  already listed in `URL` when `github_user` is not given, and no longer
  adds a second repository under openwashdata. It records the washr
  version that ran in `Config/washr/version`. For a package under another
  organisation it writes the funding, analytics, community and brand
  fields as `none` and lists them (#81).

- `use_brand()` installs the brand at the latest release tag of the brand
  repository and records the tag in DESCRIPTION as `Config/washr/brand`.
  Before, it copied from the main branch, which can carry changes no
  release describes. A second run with no new tag changes no file, and a
  run after a brand release reports the old and the new tag. Pass
  `ref = "main"` to try unreleased brand changes (#128).

- Messages now go through cli in every function, with three kinds of lines:
  a success line for a file that was written, an info line for something
  that was kept or skipped, and an arrow line for the next step that is left
  to the user. Errors name the function that was called and carry a hint on
  how to fix the cause. washr no longer calls the `usethis::ui_*()`
  functions, which usethis has superseded (#84).

- Every function returns what it wrote, invisibly, and the documentation
  says so. `setup_rawdata()`, `setup_dictionary()`, `setup_readme()`,
  `setup_website()` and `update_description()` return the path of their
  file, `setup_roxygen()` and `update_citation()` return the paths of
  theirs. Before, most of them returned `NULL` or an internal object (#84).

## Fixed

- Every function acts on the package in the working directory. Before,
  the usethis helpers wrote into the package of an earlier call when only
  the working directory had changed since, so files of one package could
  land in another within the same R session.

- The repository in `URL` is recognised in every common form: with a
  trailing slash, a `.git` suffix, a fragment or a `www.` prefix. Before,
  such a URL gave a wrong bug report link or a second repository entry.

- `setup_readme(force = TRUE)` removes the existing `README.Rmd` only once
  it can write the new one. Before, it deleted the file and then stopped
  when `data/` held no data object.

- `use_brand()` adds `_brand.yml` and the logo directory to `.Rbuildignore`.
  Before, `R CMD check` reported both as non-standard top-level files after
  the brand was installed (#133).

- `use_brand()` wires `_pkgdown.yml` to the brand by adding its lines to
  the file. Comments and long values stay as they were written. Before, the
  file was rewritten through the yaml package, which dropped the comments
  and folded the funding text over two lines, so the review standard no
  longer found it. The rewrite remains as the fallback for a `template`
  block that already carries bslib settings (#129).

## Dependencies

- cli is a new import. washr uses it for every message and no longer calls
  the `usethis::ui_*()` functions, which usethis has superseded (#84).

## Documentation and tests

- The vignette explains packages with more than one dataset, and how a
  group outside openwashdata sets its own values (#81, #103).

- The README and the vignette name the openwashdata R-universe as a third
  way to install washr, next to CRAN and GitHub, and say what each source
  gives you (#131).

- A new workflow, `scaffold-check`, builds a fixture data package with every
  washr step on each push, runs the steps a second time to confirm that no
  file changes, and runs the pkgreview check script on the result. The
  pkgreview version it checks against is recorded in `PKGREVIEW_FLOOR`
  (#129).

# washr 1.1.1

A patch release with three fixes. The first two stopped a scaffolded package
from building or checking.

- `setup_ci()` now writes the workflow file unchanged. It was written through
  `usethis::use_template()`, which renders with whisker, and whisker reads
  `{{ }}` as its own delimiters. Every `${{ ... }}` GitHub Actions expression
  came out as a bare `$`, so `runs-on: $` matched no runner and each matrix
  job queued until the 24 hour limit and then failed. A package scaffolded
  with 1.1.0 therefore shipped a workflow that never ran (#130).

- `use_brand()` reads the `path` of a logo entry written as a list of path
  and alt text, the form openwashdata/brand uses since 1.0.0. Before, the alt
  text was read as a second path and the call failed after it had already
  written `_brand.yml` (#123).

- `update_citation()` declares the work as a dataset in CITATION.cff, the
  form the Citation File Format provides for data, through a new `type`
  argument that defaults to `"dataset"`. The file used to say software, the
  cffr default, so a data package presented itself as software in its own
  citation file. Zenodo's GitHub integration ignores the field; the resource
  type of a deposit still needs a `.zenodo.json` (#56).

# washr 1.1.0

The first minor release under the new maintainer. Every function now reads
what is there, merges its changes, and is safe to run again. The FAIR layer
is one experimental function that derives schema.org metadata from the
package files. Ten exports remain: seven of the nine from 1.0.2
(`fill_dictionary()` and `generate_roxygen_docs()` are internal now) plus
three new ones; eight helpers that never reached CRAN are gone. Imports go
from 16 to 10.

## New

- New `setup_ci()` writes the GitHub Actions workflow that runs `R CMD check`
  on every push and pull request to `main` and `dev`, on macOS, Windows and
  three versions of R on Linux, and adds the matching badge to `README.Rmd`.
  The README template carries the badge as well. The openwashdata review
  standard requires the workflow with the `dev` trigger, so a package
  scaffolded with washr meets that part of the review floor by construction
  (#86). The workflow this release wrote was corrupt and never ran; fixed in
  1.1.1 (#130).

- `update_metadata()` is rewritten as the one FAIR step (lifecycle:
  experimental). It derives a schema.org Dataset description from
  DESCRIPTION, `data-raw/dictionary.csv`, `CITATION.cff` and the files in
  `inst/extdata`, writes it as JSON-LD into `pkgdown/templates/in-header.html`
  so every page of the site carries it, and ends by listing the fields it
  could not fill. Spatial and temporal coverage and keywords live in
  DESCRIPTION as `X-schema.org-spatialCoverage`,
  `X-schema.org-temporalCoverage` and `X-schema.org-keywords`. It no longer
  calls the dataspice helpers, creates no `data/metadata` folder, and writes
  no `inst/extdata/metadata.json`; existing copies of both are ignored.
  `generate_jsonld()` is no longer exported (it is the internal builder), and
  lubridate leaves Imports (#68, #70, #67).

- New `use_brand()` installs the openwashdata brand (`_brand.yml` and the
  logo files it references) from the central openwashdata/brand repository
  into the active package, refreshes an existing copy idempotently, and
  wires an existing `_pkgdown.yml` to the brand through bslib so the
  package site renders with the brand fonts and colors (#109).

- `setup_readme()` gains `has_example`, the argument the guide documents.
  With `has_example = TRUE` the README carries an Example section with a
  commented ggplot2 scaffold for a first plot, pairing with the argument of
  the same name on `setup_website()`. The function now stops with a clear
  message when `data/` holds no data object instead of writing a README with
  `NA` in it, and says which data object the template documents when there
  are several (#74, supersedes #24).

- `update_citation()` gains `build`. With `build = FALSE` it regenerates the
  citation files and adds the badge without rebuilding README.md and the
  site, for scripts and tests (#75).

## Changed

- Idempotency and ergonomics sweep of the core (#73). Every function that
  rewrites a file follows read-merge-write and is safe to re-run:
  - `setup_website()` keeps an existing `_pkgdown.yml` as it is and only
    rebuilds the site, so the guide's "answer No when prompted" step goes
    away; it no longer crashes without a `.gitignore`; and it leaves `docs`
    ignored when a pkgdown workflow deploys the site, or when the new
    `track_docs = FALSE` argument says so (#104). The example article is
    created once.
  - The `_pkgdown.yml` template carries the Pages URL as the site URL, the
    explanatory comments, and a reference index with one entry per data
    object, matching the openwashdata review standard's template.
  - `update_citation()` re-run without a `doi` keeps the DOI already on
    file instead of dropping it, moves keywords typed into `CITATION.cff` by
    hand to `X-schema.org-keywords` in DESCRIPTION (their canonical home,
    from where cffr carries them forward), and rebuilds the README only when
    the badge changes.
  - `setup_roxygen()` re-run regenerates only the `@format` block and keeps
    everything below it (`@source`, `@examples`, and other text), writes
    nothing when the result is unchanged, and errors clearly when a file has
    no `@format` line instead of crashing.
  - `setup_dictionary()` records the first class of multi-class columns
    (`POSIXct`, `ordered`, `Date`) instead of a deparsed vector.
  - Loading a `.rda` file with several objects, or a file that is not an
    `.rda`, now errors with the file name and the reason instead of
    documenting the first object or crashing.

## Fixed

- `setup_readme()` no longer writes a dead license link. The README template
  carried the package name placeholder in URL encoded form, so whisker never
  substituted it and every generated README linked to
  `.../%7B%7B%7Bpackagename%7D%7D%7D/blob/main/LICENSE.md` (#101).

- `update_citation()` adds `CITATION.cff` to `.Rbuildignore`, so `R CMD check`
  no longer reports a non-standard file at the top level of the data package.
  cffr only adds the entry itself when handed a file path, and washr hands it
  a cff object (#102).

## Removed

- `update_gsheet_metadata()` is removed. It appended a row to a private
  openwashdata Google Sheet, needed interactive Google authentication, and
  never shipped on CRAN. googlesheets4 leaves Imports with it. The catalogue
  update becomes org-internal tooling outside the package (#69).

- The dataspice helpers are removed: `add_metadata()`, `add_creator()`,
  `update_access()`, `update_attributes()` and `update_biblio()`. None of
  them shipped on CRAN. `update_metadata()` replaced their output, and a
  package that still carries `data/metadata/` keeps it; washr ignores the
  folder. `fill_dictionary()` and `generate_roxygen_docs()` are no longer
  exported; `setup_dictionary()` and `setup_roxygen()` call them. The export
  surface is now nine functions. dataspice, dplyr, readr, stringr and tibble
  leave Imports with the removed code (#71, #100, #72).

## Dependencies

- devtools moves from Imports to Suggests. `update_citation()` still rebuilds
  README.md through `devtools::build_readme()`, because the README loads the
  data package, and asks to install devtools when it is missing; the site
  rebuild calls `pkgdown::build_site()` directly. `setup_website()` no longer
  renders the example article on its own, since the site build renders it.
  The version constraint on utils is dropped; utils is a base package and the
  constraint silently required R 4.3.3. With the seven packages removed by
  the FAIR layer work, Imports go from 16 to 10 (#72).

## Documentation and tests

- Test bar (#75). Every export has a behavioral test that asserts on file
  content or output; every `expect_error()` names its message; the
  `setup_rawdata()` tests check the rendered template. A test coverage
  workflow measures coverage on every push and pull request and writes it
  to the job summary.

- Documentation (#76). The Get started vignette walks through the workflow
  in the order of the publishing guide, one function per step; the README
  gives the toolkit overview with the stable core and the experimental FAIR
  layer, and carries the CRAN status badge; every export names its
  neighbours in the workflow under See also; the reference index is grouped
  by workflow stage; and the pkgdown site URL points at the openwashdata
  organisation (it pointed at the dev fork, which broke canonical links).

# washr 1.0.2

Patch release: bug fixes only, no new API. New maintainer: Lars Schöbitz.

- `update_citation()` no longer requires a `doi` argument; calling it without
  one generates the citation files without a DOI, for use before a release
  exists (#57).
- `update_citation(doi = NULL)` no longer injects a broken empty DOI badge
  into README.Rmd. Re-running with a DOI replaces an existing badge instead
  of duplicating it, heals a broken empty badge left by earlier versions,
  and a missing `<!-- badges: end -->` marker now gives a clear error (#58).
- `update_description()` preserves existing `URL` and `Config/Needs/website`
  entries and merges them with the openwashdata defaults instead of
  replacing them (#59, #63).
- `update_description()` no longer overwrites an existing license; CC BY 4.0
  is only set when the package has no license yet (#63).
- `update_description()` honors its `file` argument when checking for the
  DESCRIPTION file (#63).
- `update_citation()` cleans up the `*.bk1` backup files that cffr leaves
  behind when overwriting `CITATION.cff` and `inst/CITATION` (#60).
- `setup_readme()` no longer deletes an existing README.Rmd; it stops with
  an error unless the new `force = TRUE` argument is passed (#64).

# washr 1.0.1

- Implementing reviewer's comments, resubmission to CRAN

# washr 1.0.0

-   Initial CRAN submission.
