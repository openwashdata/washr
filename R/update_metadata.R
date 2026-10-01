#' Generate and embed the schema.org metadata of the data package
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `update_metadata()` derives a schema.org Dataset description from the
#' canonical sources of the package and writes it as a JSON-LD block into the
#' head of every pkgdown page, where dataset search engines read it. Nothing
#' is hand edited: to change a value, change its source and run the function
#' again. Running it twice produces no change. It ends by listing the fields
#' it could not fill and where to fill them.
#'
#' The sources are:
#'
#' | Field | Source |
#' |---|---|
#' | name, description, version, datePublished, license | `Title`, `Description`, `Version`, `Date`, `License` in DESCRIPTION |
#' | url | the pkgdown site (a `github.io` entry in `URL`), else the repository |
#' | keywords | `X-schema.org-keywords` in DESCRIPTION, comma separated |
#' | spatialCoverage, temporalCoverage | `X-schema.org-spatialCoverage` and `X-schema.org-temporalCoverage` in DESCRIPTION |
#' | isBasedOn | the source article DOIs in `X-schema.org-isBasedOn` in DESCRIPTION, comma separated |
#' | creator, maintainer, funder, publisher | `Authors@R` roles `aut`/`cre`, `cre`, `fnd`, `cph`; ORCID from the `comment` field |
#' | identifier, sameAs | the DOI in `CITATION.cff`, written by [update_citation()] |
#' | variableMeasured | `data-raw/dictionary.csv` |
#' | distribution | every file in `inst/extdata` that belongs to a dataset, one entry per file |
#'
#' The JSON-LD lands in `pkgdown/templates/in-header.html`, which pkgdown
#' picks up on the next site build. The file also keeps the `in_header`
#' includes from `_pkgdown.yml` working. It is not shipped in the package
#' tarball.
#'
#' @param quiet Logical. Suppress the messages and the report of blank
#'   fields. Defaults to `FALSE`, or to `TRUE` when `options(washr.quiet = TRUE)`
#'   is set.
#'
#' @returns The Dataset description as a list, invisibly. The `"blank"`
#'   attribute names the fields that could not be filled and says where to
#'   fill them.
#'
#' @seealso Before: [update_description()], which writes the DESCRIPTION fields this reads. Next: [setup_readme()]. The DOI comes from [update_citation()].
#'
#' @family metadata functions
#'
#' @export
#'
#' @examples
#' \dontrun{
#' update_metadata()
#' }
update_metadata <- function(quiet = FALSE) {
  if (!file.exists("DESCRIPTION")) {
    cli::cli_abort(c(
      "No DESCRIPTION file found.",
      "i" = "Run this from the root of the data package."
    ))
  }
  if (!file.exists(file.path("data-raw", "dictionary.csv"))) {
    cli::cli_abort(c(
      "Dictionary file not found.",
      "i" = "Run {.fun setup_dictionary} first."
    ))
  }
  if (isTRUE(quiet)) rlang::local_options(washr.quiet = TRUE)
  local_quiet()

  dataset <- build_dataset_jsonld(".")
  html <- jsonld_template(dataset)

  target <- file.path("pkgdown", "templates", "in-header.html")
  dir.create(dirname(target), recursive = TRUE, showWarnings = FALSE)
  current <- if (file.exists(target)) paste(readLines(target, warn = FALSE), collapse = "\n") else NULL
  changed <- !identical(current, html)
  if (changed) writeLines(html, target)
  usethis::use_build_ignore("pkgdown")

  if (changed) {
    ui_done("Wrote {.path {target}}")
  } else {
    ui_done("{.path {target}} is up to date")
  }
  if (file.exists("_pkgdown.yml")) {
    ui_todo("Rebuild the site with {.code pkgdown::build_site()} to embed the metadata.")
  } else {
    ui_todo("Run {.fun setup_website} so the site embeds the metadata.")
  }
  report_blank(attr(dataset, "blank"))
  invisible(dataset)
}

report_blank <- function(blank) {
  if (length(blank) == 0) {
    ui_done("Every metadata field is filled")
    return(invisible(NULL))
  }
  ui_info("{length(blank)} metadata field{?s} still blank:")
  for (nm in names(blank)) {
    ui_todo("{nm}: {blank[[nm]]}")
  }
  invisible(NULL)
}
