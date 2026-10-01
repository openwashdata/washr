# Source articles of a data package (#134). A package that republishes data
# from a published article records the article DOI in DESCRIPTION as
# X-schema.org-isBasedOn (comma separated, one or more DOIs), next to the
# other X-schema.org-* fields of the 2026-09-02 amendment. update_citation()
# turns each DOI into a CITATION.cff reference and a second inst/CITATION
# entry; update_metadata() writes them as schema.org isBasedOn.

# DOIs listed in X-schema.org-isBasedOn, normalised to the bare 10.x form.
# Entries that are not DOIs are skipped with a note.
source_dois <- function(file = "DESCRIPTION") {
  raw <- split_field(desc::desc_get_field("X-schema.org-isBasedOn",
                                          default = "", file = file))
  dois <- sub("^(https?://(dx\\.)?doi\\.org/|doi:\\s*)", "", raw, ignore.case = TRUE)
  is_doi <- grepl("^10\\.[0-9]{4,}/\\S+$", dois)
  if (any(!is_doi)) {
    ui_info("Skipping {.val {raw[!is_doi]}} in X-schema.org-isBasedOn: only DOIs are supported")
  }
  unique(dois[is_doi])
}

# Metadata of a DOI as CSL JSON through content negotiation at doi.org, which
# answers for Crossref and DataCite DOIs alike. NULL when the lookup fails.
fetch_doi_csl <- function(doi) {
  tryCatch({
    con <- url(paste0("https://doi.org/", doi),
               headers = c(Accept = "application/vnd.citationstyles.csl+json"))
    on.exit(close(con), add = TRUE)
    txt <- paste(readLines(con, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
    jsonlite::fromJSON(txt, simplifyVector = FALSE)
  }, error = function(e) NULL, warning = function(w) NULL)
}

# One CFF reference from CSL JSON: a journal article becomes type article,
# a dataset type data, anything else type generic.
csl_to_reference <- function(csl) {
  first <- function(x) if (length(x)) as.character(unlist(x))[[1]] else NULL
  squish <- function(x) if (!is.null(x)) trimws(gsub("\\s+", " ", gsub("<[^>]+>", "", x)))

  authors <- lapply(csl$author, function(a) {
    orcid <- if (!is.null(a$ORCID)) sub("^https?://orcid\\.org/", "", a$ORCID)
    comment <- if (!is.null(orcid)) c(ORCID = orcid)
    if (!is.null(a$family)) {
      utils::person(given = a$given, family = a$family, comment = comment)
    } else {
      utils::person(given = first(c(a$literal, a$name)), comment = comment)
    }
  })
  authors <- do.call(c, authors)
  date <- if_null(first(csl$issued$`date-parts`[[1]]), first(csl$published$`date-parts`[[1]]))
  journal <- squish(first(csl$`container-title`))
  article <- identical(csl$type, "journal-article") && !is.null(journal)

  fields <- list(
    bibtype = if (article) "Article" else "Misc",
    title = squish(first(csl$title)),
    author = authors,
    journal = if (article) journal,
    publisher = if (!article) squish(first(csl$publisher)),
    year = date,
    volume = first(csl$volume),
    number = first(csl$issue),
    pages = if (!is.null(csl$page)) gsub("-", "--", first(csl$page), fixed = TRUE),
    doi = first(csl$DOI)
  )
  ref <- cffr::as_cff(do.call(utils::bibentry, fields[!vapply(fields, is.null, logical(1))]))[[1]]
  if (identical(csl$type, "dataset")) ref$type <- "data"
  ref
}

# The references block for the source DOIs. A DOI that cannot be looked up
# keeps its entry from the existing CITATION.cff, so a re-run offline
# changes nothing; without an existing entry it is left out with a warning.
source_references <- function(dois, existing = NULL) {
  on_file <- existing$references
  on_file_dois <- tolower(vapply(on_file, function(r) if_null(r$doi, ""), character(1)))
  refs <- lapply(dois, function(doi) {
    csl <- fetch_doi_csl(doi)
    if (!is.null(csl)) return(csl_to_reference(csl))
    kept <- match(tolower(doi), on_file_dois)
    if (!is.na(kept)) {
      ui_info("Could not look up {.val {doi}}; keeping its reference from the existing CITATION.cff")
      return(on_file[[kept]])
    }
    cli::cli_warn("Could not look up {.val {doi}}; it is left out of CITATION.cff until a run with a network connection")
    NULL
  })
  refs[!vapply(refs, is.null, logical(1))]
}

# The message that asks for both citations, worded for one or more sources.
source_message <- function(refs, type = "dataset") {
  kind <- if (all(vapply(refs, function(r) identical(r$type, "article"), logical(1)))) "article" else "work"
  what <- if (length(refs) == 1) paste("the original", kind) else paste0("the original ", kind, "s")
  package <- if (identical(type, "dataset")) "the data package" else "the package"
  paste0("If you use this ", type, ", please cite both ", package, " and ",
         what, " listed under references.")
}

if_null <- function(x, y) if (is.null(x)) y else x
