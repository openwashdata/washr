#' Update the citation file for the dataset.
#'
#' @description
#' Create a citation *.cff file for the dataset from a given DOI (Digital
#' Object Identifier). When a DOI is supplied, it adds the DOI badge to the
#' README RMarkdown file (the Zenodo badge, or a generic DOI badge when
#' `Config/washr/doi-provider` in DESCRIPTION names another provider) and re-builds the README.md and pkgdown website if
#' they exist. Before a release exists, call it without arguments to generate
#' the citation files without a DOI or badge.
#'
#' The same run writes `.zenodo.json` through [update_zenodo_json()], so the
#' metadata Zenodo reads at release time comes from the same DESCRIPTION as
#' the citation files.
#'
#' @details
#' When the data comes from a published article, list the article DOI in
#' DESCRIPTION as `X-schema.org-isBasedOn`, e.g.,
#' `X-schema.org-isBasedOn: https://doi.org/10.2166/wh.2026.173`. Separate
#' several DOIs with commas. `update_citation()` looks up each DOI at doi.org
#' and writes it as a `references` entry in CITATION.cff, with a message that
#' asks users to cite both the data package and the article. `inst/CITATION`
#' then holds both entries, so `citation()` prints both. The package itself
#' stays the work cited by GitHub's "Cite this repository". A DOI that cannot
#' be looked up keeps its entry from the existing CITATION.cff. Other
#' references in CITATION.cff or `inst/CITATION` are dropped, because
#' DESCRIPTION is their canonical source (#134).
#'
#' @param doi DOI (Digital Object Identifier), e.g., 10.5281/zenodo.11185699.
#'   Defaults to `NULL` for the call before the release, in which case no
#'   DOI is recorded and no badge is added.
#' @param build Logical. Rebuild README.md and the pkgdown site after the
#'   citation files change? Defaults to `TRUE`. Set to `FALSE` to regenerate
#'   the citation files alone, e.g., in scripts and tests.
#' @param type The CFF `type` of the work: `"dataset"` (the default, a data
#'   package) or `"software"`. Before 1.1.1 the file always said software,
#'   the cffr default. Zenodo's GitHub integration ignores this field; the
#'   resource type of a deposit comes from `.zenodo.json`, which always says
#'   dataset.
#'
#' @returns The paths of the three files written, `CITATION.cff`,
#'   `inst/CITATION` and `.zenodo.json`, invisibly.
#' @seealso Before: [setup_website()]. Run again with the DOI after the Zenodo release; [update_metadata()] then picks the DOI up. [update_zenodo_json()] for the Zenodo metadata file alone.
#'
#' @family metadata functions
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   update_citation(doi = "10.5281/zenodo.11185699")
#'   # Regenerate the citation files without rebuilding README.md and the site
#'   update_citation(build = FALSE)
#' }
#'
update_citation <- function(doi = NULL, build = TRUE,
                            type = c("dataset", "software")){
  type <- match.arg(type)
  local_session()
  cff_path <- "CITATION.cff"
  existing <- if (file.exists(cff_path)) cffr::cff_read(cff_path) else NULL

  # Read-merge-write: a re-run without a doi keeps the DOI already on file
  if (is.null(doi) && !is.null(existing$doi)) {
    doi <- existing$doi
    ui_info("Keeping the DOI {.val {doi}} from the existing CITATION.cff")
  }
  # Keywords live in DESCRIPTION (X-schema.org-keywords), where cffr reads
  # them; keywords typed into CITATION.cff by hand move there once
  migrate_cff_keywords(existing)

  # Creates CFF with all author roles
  keys <- list("date-released" = desc::desc_get("Date"), type = type)
  if (!is.null(doi)) {
    keys$doi <- doi
  }
  mod_cff <- quietly(cffr::cff_create("DESCRIPTION",
                                      dependencies = FALSE,
                                      keys = keys))

  # Remove the preferred-citation key
  mod_cff$`preferred-citation` <- NULL

  # References come from X-schema.org-isBasedOn only (#134). cffr also turns
  # extra inst/CITATION entries into references; those are either this
  # function's own output from the last run or hand-written entries, and
  # DESCRIPTION is the canonical source for both.
  derived <- vapply(mod_cff$references,
                    function(r) if_null(r$doi, if_null(r$title, "")), character(1))
  mod_cff$references <- NULL
  sources <- source_dois()
  dropped <- derived[!tolower(derived) %in% tolower(sources)]
  if (length(dropped) > 0) {
    ui_info("Dropping {.val {dropped}} from the references: list source DOIs in X-schema.org-isBasedOn in DESCRIPTION")
  }
  refs <- if (length(sources) > 0) source_references(sources, existing) else list()
  if (length(refs) > 0) {
    mod_cff$references <- refs
    mod_cff$message <- source_message(refs, type)
  }

  # Writes the CFF file
  quietly(cffr::cff_write(mod_cff, verbose = !is_quiet()))

  # cffr adds CITATION.cff to .Rbuildignore only when cff_write() is given a
  # path; for a cff object it returns early, so do it here (idempotent).
  usethis::use_build_ignore("CITATION.cff")

  # Now write a CITATION file from the CITATION.cff file
  # Use inst/CITATION instead (the default if not provided)
  path_cit <- file.path("inst/CITATION")

  a_cff <- cffr::cff_read(path = "CITATION.cff")

  if (length(refs) > 0) {
    # Both entries, under a header that asks for both citations
    dir.create("inst", showWarnings = FALSE)
    writeLines(sprintf("citHeader(%s)", encodeString(a_cff$message, quote = '"')),
               path_cit, useBytes = TRUE)
    quietly(cffr::cff_write_citation(a_cff, file = path_cit, append = TRUE,
                                     what = "all", verbose = !is_quiet()))
  } else {
    quietly(cffr::cff_write_citation(a_cff, file = path_cit, verbose = !is_quiet()))
  }

  # cffr backs up an existing file as *.bk1 before overwriting; drop the
  # backups so they cannot slip into release commits
  backups <- c(Sys.glob("CITATION.cff.bk*"), Sys.glob(file.path("inst", "CITATION.bk*")))
  if (length(backups) > 0) {
    unlink(backups)
  }
  ui_done("Wrote {.path {cff_path}} and {.path {path_cit}}")

  # The Zenodo metadata from the same DESCRIPTION (#56)
  zenodo_path <- write_zenodo_json(sources = sources)

  # Modify README and pkgdown
  badge_missing <- !is.null(doi) && file.exists("README.Rmd") &&
    !any(grepl(doi_badge(doi), readLines("README.Rmd", warn = FALSE), fixed = TRUE))
  if(badge_missing){
    add_citation_badge(doi)
    if (build) {
      # the README loads the data package, so the rebuild runs in a separate
      # process with the package loaded; devtools is a Suggests for this call
      rlang::check_installed("devtools", reason = "to rebuild README.md after the badge changes.")
      devtools::build_readme()
    }
  }

  if(build && dir.exists(file.path("docs"))){
    pkgdown::build_site()
  }

  # By last, read the citation
  ui_todo("Proofread your citation file at {.path {path_cit}}.")
  invisible(c(cff_path, path_cit, zenodo_path))
}

# The DOI badge of the README. Zenodo serves its own badge; any other DOI
# provider (Config/washr/doi-provider) gets a generic badge that links to
# doi.org.
doi_badge <- function(doi, provider = pkg_config("doi-provider")) {
  if (identical(tolower(provider), "zenodo")) {
    icon <- paste0("https://zenodo.org/badge/DOI/", doi, ".svg")
    link <- paste0("https://zenodo.org/doi/", doi)
  } else {
    label <- gsub("_", "__", gsub("-", "--", doi, fixed = TRUE), fixed = TRUE)
    icon <- paste0("https://img.shields.io/badge/DOI-",
                   utils::URLencode(label, reserved = TRUE), "-blue.svg")
    link <- paste0("https://doi.org/", doi)
  }
  sprintf("[![DOI](%s)](%s)", icon, link)
}

add_citation_badge<- function(doi){
  badge_str <- doi_badge(doi)
  readme_rmd_path <- file.path("README.Rmd")
  readme_rmd <- readLines(readme_rmd_path)

  end_marker <- which(startsWith(readme_rmd, "<!-- badges: end -->"))
  if (length(end_marker) == 0) {
    cli::cli_abort(c(
      "No {.code <!-- badges: end -->} marker found in {.path README.Rmd}.",
      "i" = "Add the badge markers before updating the citation."
    ))
  }

  existing <- which(grepl("[![DOI](", readme_rmd, fixed = TRUE))
  if (length(existing) > 0) {
    # Replace the existing badge in place so re-runs stay idempotent
    readme_rmd[existing[1]] <- badge_str
    if (length(existing) > 1) {
      readme_rmd <- readme_rmd[-existing[-1]]
    }
    new_readme_rmd <- readme_rmd
  } else {
    i <- end_marker[1]
    new_readme_rmd <- c(readme_rmd[seq_len(i - 1)], badge_str, readme_rmd[i:length(readme_rmd)])
  }
  writeLines(new_readme_rmd, readme_rmd_path)
}

# Move keywords typed into CITATION.cff by hand to their canonical home in
# DESCRIPTION, unless DESCRIPTION already carries keywords, which then win.
migrate_cff_keywords <- function(existing) {
  if (is.null(existing) || is.null(existing$keywords)) return(invisible(FALSE))
  current <- desc::desc_get_field("X-schema.org-keywords", default = "")
  if (!identical(current, "")) return(invisible(FALSE))
  keywords <- unique(trimws(unlist(existing$keywords)))
  desc::desc_set("X-schema.org-keywords", paste(keywords, collapse = ", "))
  ui_done("Moved {length(keywords)} keyword{?s} from CITATION.cff to X-schema.org-keywords in DESCRIPTION, their canonical home")
  invisible(TRUE)
}
