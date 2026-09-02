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
#'   fields. Defaults to `FALSE`.
#'
#' @returns The Dataset description as a list, invisibly. The `"blank"`
#'   attribute names the fields that could not be filled and says where to
#'   fill them.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' update_metadata()
#' }
update_metadata <- function(quiet = FALSE) {
  if (!file.exists("DESCRIPTION")) {
    usethis::ui_stop("No DESCRIPTION file found. Run this from the root of the data package.")
  }
  if (!file.exists(file.path("data-raw", "dictionary.csv"))) {
    usethis::ui_stop("Dictionary file not found. Run {usethis::ui_code('setup_dictionary()')} first.")
  }

  dataset <- build_dataset_jsonld(".")
  html <- jsonld_template(dataset)

  target <- file.path("pkgdown", "templates", "in-header.html")
  dir.create(dirname(target), recursive = TRUE, showWarnings = FALSE)
  current <- if (file.exists(target)) paste(readLines(target, warn = FALSE), collapse = "\n") else NULL
  changed <- !identical(current, html)
  if (changed) writeLines(html, target)
  usethis::use_build_ignore("pkgdown")

  if (!quiet) {
    if (changed) {
      usethis::ui_done("Wrote {usethis::ui_path(target)}")
    } else {
      usethis::ui_done("{usethis::ui_path(target)} is up to date")
    }
    if (file.exists("_pkgdown.yml")) {
      usethis::ui_todo("Rebuild the site with {usethis::ui_code('pkgdown::build_site()')} to embed the metadata")
    } else {
      usethis::ui_todo("Run {usethis::ui_code('setup_website()')} so the site embeds the metadata")
    }
    report_blank(attr(dataset, "blank"))
  }
  invisible(dataset)
}

report_blank <- function(blank) {
  if (length(blank) == 0) {
    usethis::ui_done("Every metadata field is filled")
    return(invisible(NULL))
  }
  usethis::ui_info("{length(blank)} metadata field(s) still blank:")
  for (nm in names(blank)) {
    usethis::ui_todo("{nm}: {blank[[nm]]}")
  }
  invisible(NULL)
}
