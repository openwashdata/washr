#' Write the Zenodo metadata file of the data package
#'
#' @description
#' `update_zenodo_json()` writes `.zenodo.json` at the package root. Zenodo
#' reads this file when a GitHub release is archived and takes the metadata
#' of the record from it: the resource type (Dataset), the community, the
#' title, the description, the creators with their ORCID iDs, the license,
#' the keywords and the version. Without the file, Zenodo files a data
#' package as Software in no community, because its GitHub integration reads
#' only a few fields of `CITATION.cff`.
#'
#' Nothing in the file is hand edited: to change a value, change its source
#' and run the function again. Running it twice produces no change.
#' [update_citation()] calls it, so the citation files and `.zenodo.json` are
#' written in one step and stay in line with each other.
#'
#' The sources are:
#'
#' | Key | Source |
#' |---|---|
#' | title, description, version | `Title`, `Description`, `Version` in DESCRIPTION |
#' | upload_type | always `dataset` |
#' | creators | `Authors@R` roles `aut` and `cre`; ORCID and affiliation from the `comment` field |
#' | license | `License` in DESCRIPTION, as the identifier Zenodo uses (e.g., `cc-by-4.0`) |
#' | keywords | `X-schema.org-keywords` in DESCRIPTION, comma separated |
#' | communities | `Config/washr/zenodo-community` in DESCRIPTION: `openwashdata` for an openwashdata package, none for another organisation until it sets one |
#' | related_identifiers | the source article DOIs in `X-schema.org-isBasedOn` in DESCRIPTION |
#'
#' @details
#' Zenodo uses `.zenodo.json` in place of `CITATION.cff` for the record, and
#' it reads the file from the release tag. Commit the file before you create
#' the release, and run the function again whenever DESCRIPTION changes.
#'
#' Set `Config/washr/zenodo-community` in DESCRIPTION to file the record in
#' another community, to several (comma separated), or to `none` for no
#' community.
#'
#' A source article is written as a related identifier with the relation
#' `isDerivedFrom`. Zenodo then drops its own link to the release tag on
#' GitHub, so the repository from the `URL` field is added as a second
#' related identifier.
#'
#' When washr does not know the license, the file carries none. Zenodo then
#' takes the license GitHub detects for the repository, and CC0 1.0 for a
#' dataset when GitHub detects none.
#'
#' @returns The path of `.zenodo.json`, invisibly.
#'
#' @seealso Before: [update_description()], which writes the DESCRIPTION fields this reads. [update_citation()] calls this function. Next: the GitHub release that Zenodo archives.
#'
#' @family metadata functions
#'
#' @export
#'
#' @examples
#' \dontrun{
#' update_zenodo_json()
#' }
update_zenodo_json <- function() {
  if (!file.exists("DESCRIPTION")) {
    cli::cli_abort(c(
      "No DESCRIPTION file found.",
      "i" = "Run this from the root of the data package."
    ))
  }
  local_session()
  write_zenodo_json()
}

# Write .zenodo.json and report. update_citation() passes the source DOIs it
# has already read, so a note about a skipped entry is printed once.
write_zenodo_json <- function(sources = NULL) {
  target <- ".zenodo.json"
  metadata <- build_zenodo_json(".", sources = sources)
  # Compared and written as bytes: UTF-8 with LF line endings on every
  # platform, so a second run is byte identical.
  new <- charToRaw(enc2utf8(paste0(zenodo_json_text(metadata), "\n")))
  current <- if (file.exists(target)) readBin(target, "raw", file.size(target)) else NULL
  changed <- !identical(current, new)
  if (changed) writeBin(new, target)
  usethis::use_build_ignore(target)

  if (changed) {
    ui_done("Wrote {.path {target}}")
  } else {
    ui_done("{.path {target}} is up to date")
  }
  notes <- attr(metadata, "notes")
  for (nm in names(notes)) {
    ui_info("{.path {target}} has no {nm}: {notes[[nm]]}")
  }
  invisible(target)
}

# Internal builder behind update_zenodo_json(): derives the deposit metadata
# from DESCRIPTION, the canonical source it shares with CITATION.cff and the
# JSON-LD (see build_dataset_jsonld()). The keys are those of Zenodo's
# deposit metadata, which its GitHub integration loads from .zenodo.json.
# Keys without a value are left out and named in the "notes" attribute.
#
# @noRd
build_zenodo_json <- function(path = ".", sources = NULL) {
  desc_file <- file.path(path, "DESCRIPTION")
  notes <- character()
  field <- function(key) {
    desc::desc_get_field(key, default = "", file = desc_file)
  }
  or_null <- function(x) if (identical(x, "")) NULL else x

  authors <- tryCatch(desc::desc_get_authors(file = desc_file),
                      error = function(e) NULL)
  creators <- zenodo_creators(authors)
  if (length(creators) == 0) {
    notes[["creators"]] <- "add persons with role aut or cre to Authors@R in DESCRIPTION. Zenodo names the owner of the repository instead."
  }

  license <- field("License")
  license_id <- license_zenodo(license)
  if (is.null(license_id)) {
    notes[["license"]] <- paste0(
      "washr has no Zenodo identifier for ", encodeString(license, quote = '"'),
      ". Zenodo takes the license GitHub detects for the repository, and CC0 1.0 for a dataset when GitHub detects none."
    )
  }

  keywords <- split_field(field("X-schema.org-keywords"))
  communities <- split_field(pkg_config("zenodo-community", desc_file))
  if (identical(tolower(communities), "none")) communities <- character()

  # A related_identifiers key replaces the link to the release tag that
  # Zenodo adds by default, so the repository goes in with the sources.
  if (is.null(sources)) sources <- source_dois(desc_file)
  related <- lapply(sources, function(doi) {
    list(identifier = doi, relation = "isDerivedFrom")
  })
  repo_url <- github_repo_url(path)
  if (length(related) > 0 && !is.null(repo_url)) {
    related <- c(list(list(identifier = repo_url, relation = "isSupplementTo")),
                 related)
  }

  out <- list(
    title = or_null(field("Title")),
    description = or_null(field("Description")),
    upload_type = "dataset",
    creators = if (length(creators)) creators,
    license = license_id,
    keywords = if (length(keywords)) I(keywords),
    version = or_null(field("Version")),
    communities = if (length(communities)) {
      lapply(communities, function(id) list(identifier = id))
    },
    related_identifiers = if (length(related)) related
  )
  out <- out[!vapply(out, is.null, logical(1))]
  attr(out, "notes") <- notes
  out
}

# Creators (roles aut and cre) from a person vector, in the form Zenodo
# reads: the name as "Family, Given", the bare ORCID iD and the affiliation.
# A person without a family name is an organisation and keeps its name.
zenodo_creators <- function(authors) {
  creators <- list()
  for (i in seq_along(authors)) {
    p <- authors[i]
    if (!any(c("aut", "cre") %in% p$role)) next
    given <- paste(p$given, collapse = " ")
    creator <- list(
      name = if (is.null(p$family)) given else paste0(p$family, ", ", given)
    )
    comment <- p$comment
    if (!is.null(comment) && "affiliation" %in% names(comment)) {
      creator$affiliation <- comment[["affiliation"]]
    }
    if (!is.null(comment) && "ORCID" %in% names(comment)) {
      creator$orcid <- sub("^https?://orcid\\.org/", "", comment[["ORCID"]])
    }
    creators[[length(creators) + 1]] <- creator
  }
  creators
}

# The JSON text of the file: pretty printed, keys in the order of the list.
zenodo_json_text <- function(metadata) {
  attr(metadata, "notes") <- NULL
  as.character(jsonlite::toJSON(metadata, pretty = TRUE, auto_unbox = TRUE))
}
