#' Draft the citation and data availability text for an article
#'
#' @description
#' `data_availability_statement()` drafts the text that the authors of an
#' article need once the data package has a DOI: the reference list entry in
#' APA style, the data availability statement and the in-text citation. All
#' three come from metadata the package already holds, so they are ready the
#' moment the DOI is on file.
#'
#' The sources are:
#'
#' | Part | Source |
#' |---|---|
#' | authors | `Authors@R` in DESCRIPTION, roles `aut` and `cre`, in their order (the same persons as `CITATION.cff` and `.zenodo.json`) |
#' | year | `date-released` in `CITATION.cff`, else `Date` in DESCRIPTION |
#' | title, version, licence | `Package`, `Title`, `Version`, `License` in DESCRIPTION |
#' | DOI | `doi` in `CITATION.cff`, which [update_citation()] writes |
#' | repository | the GitHub repository in the `URL` field of DESCRIPTION |
#' | website | the `url` in `_pkgdown.yml`, else the `github.io` entry of the `URL` field |
#' | download formats | the CSV and Excel files in `inst/extdata` |
#' | withheld data | `Config/washr/withheld` in DESCRIPTION |
#'
#' @details
#' The reference entry follows APA 7: authors as "Family, I. I.", with "&"
#' before the last one, and with 21 or more authors the first 19, an
#' ellipsis and the last author. An author without a family name is an
#' organisation and keeps its full name. The entry ends with the repository
#' URL ("Available at ..."). The in-text citation names one author, two
#' authors joined by "&", or the first author followed by "et al." for three
#' or more.
#'
#' The statement names the licence, the package and its version, the DOI and
#' the in-text citation. When the package has a website, a second sentence
#' points to it for the CSV and Excel downloads found in `inst/extdata`.
#' When some data was left out of the package, write one sentence that says
#' what and why into DESCRIPTION, for example
#' `Config/washr/withheld: Household coordinates are not included, to protect the privacy of the respondents.`
#' The sentence closes the statement word for word.
#'
#' The function stops when `CITATION.cff` carries no DOI yet: run
#' [update_citation()] with the DOI of the Zenodo record first. Run it on the
#' released version; a development version (such as `1.0.0.9000`) gives a
#' warning, because the text would name a version that is not archived.
#'
#' @param subject The opening words of the statement, which name the data
#'   the article uses. Defaults to `"The data"`, which gives "The data
#'   supporting this study are openly available ...". Write it for the
#'   article, e.g., `"The household survey data"`.
#' @param clipboard Logical. Copy the reference entry and the statement to
#'   the clipboard as well? Defaults to `FALSE`. Needs the clipr package.
#'
#' @returns A named character vector of class `washr_data_availability` with
#'   the elements `reference`, `statement` and `in_text`. Printing it shows
#'   the three parts.
#'
#' @seealso Before: [update_citation()] with the DOI of the Zenodo record.
#'
#' @family publishing functions
#'
#' @export
#'
#' @examples
#' \dontrun{
#' data_availability_statement()
#'
#' # Name the data the article uses, and copy the text to the clipboard
#' data_availability_statement(subject = "The household survey data",
#'                             clipboard = TRUE)
#' }
data_availability_statement <- function(subject = "The data", clipboard = FALSE) {
  check_pkg_root()
  if (!is.character(subject) || length(subject) != 1 || is.na(subject) ||
      !nzchar(trimws(subject))) {
    cli::cli_abort("{.arg subject} must be a single non-empty string.")
  }
  path <- "."
  doi <- pkg_doi(path)
  if (is.null(doi)) {
    cli::cli_abort(c(
      "{.path CITATION.cff} carries no DOI yet.",
      "i" = "Run {.code update_citation(doi = ...)} with the DOI of the Zenodo record first."
    ))
  }
  out <- build_data_availability(path, doi = doi, subject = trimws(subject))

  version <- desc::desc_get_field("Version", file = path)
  if (length(unclass(package_version(version))[[1]]) > 3) {
    cli::cli_warn(c(
      "Version {version} is a development version, which Zenodo has not archived.",
      "i" = "Run this on the released version, on the {.val main} branch."
    ))
  }

  if (isTRUE(clipboard)) {
    rlang::check_installed("clipr", reason = "to copy the text to the clipboard.")
    clipr::write_clip(paste(out[["reference"]], out[["statement"]], sep = "\n\n"))
    ui_done("Copied the reference entry and the statement to the clipboard")
  }
  out
}

# The three texts from the package metadata. `doi` is the bare DOI.
build_data_availability <- function(path, doi, subject = "The data") {
  desc_file <- file.path(path, "DESCRIPTION")
  field <- function(key) desc::desc_get_field(key, default = "", file = desc_file)

  authors <- tryCatch(desc::desc_get_authors(file = desc_file),
                      error = function(e) NULL)
  persons <- citation_persons(authors)
  if (length(persons) == 0) {
    cli::cli_abort(c(
      "Authors@R in DESCRIPTION has no person with role aut or cre.",
      "i" = "Add the authors of the data to Authors@R."
    ))
  }
  year <- citation_year(path)
  package <- field("Package")
  version <- field("Version")
  doi_url <- paste0("https://doi.org/", doi)
  cite <- in_text_citation(persons, year)

  provider <- pkg_config("doi-provider", desc_file)
  publisher <- if (identical(tolower(provider), "zenodo")) "Zenodo. " else ""
  repo <- github_repo_url(desc_file)
  reference <- paste0(
    apa_author_list(persons), " (", year, "). ",
    package, ": ", field("Title"), " (Version ", version, ") [Data set]. ",
    publisher, doi_url,
    if (!is.null(repo)) paste0(". Available at ", repo)
  )

  license <- license_key(field("License"))
  license <- if (grepl("^(file\\s+LICEN[CS]E)?$", license)) "" else license
  archived <- if (identical(publisher, "")) "archived at " else "archived on Zenodo at "
  sentences <- paste0(
    subject, " supporting this study are openly available",
    if (nzchar(license)) paste0(" under a ", license, " licence"),
    " in the R data package ", package, ", version ", version, ", ",
    archived, doi_url, " (", cite, ")."
  )

  site <- pkg_site_url(path)
  formats <- extdata_formats(path)
  if (!is.null(site) && length(formats)) {
    sentences <- c(sentences, paste0(
      "The data can also be downloaded as ", paste(formats, collapse = " and "),
      " files from ", site, "."
    ))
  }
  withheld <- washr_config("withheld", file = desc_file)
  if (is_set(withheld)) sentences <- c(sentences, withheld)

  structure(
    c(reference = reference, statement = paste(sentences, collapse = " "),
      in_text = cite),
    class = "washr_data_availability"
  )
}

# The DOI on file in CITATION.cff, or NULL.
pkg_doi <- function(path = ".") {
  cff_file <- file.path(path, "CITATION.cff")
  if (!file.exists(cff_file)) return(NULL)
  doi <- tryCatch(cffr::cff_read(cff_file)$doi, error = function(e) NULL)
  if (is.null(doi) || !nzchar(trimws(doi))) NULL else trimws(doi)
}

# The persons cited: roles aut and cre, in the order of Authors@R, as in
# CITATION.cff and .zenodo.json (zenodo_creators()).
citation_persons <- function(authors) {
  keep <- vapply(seq_along(authors), function(i) {
    any(c("aut", "cre") %in% authors[i]$role)
  }, logical(1))
  authors[keep]
}

# The year of the citation: date-released in CITATION.cff, which is the year
# inst/CITATION prints, else the Date in DESCRIPTION, else the current year.
citation_year <- function(path = ".") {
  cff_file <- file.path(path, "CITATION.cff")
  date <- if (file.exists(cff_file)) {
    tryCatch(cffr::cff_read(cff_file)$`date-released`, error = function(e) NULL)
  }
  if (is.null(date) || !nzchar(date)) {
    date <- desc::desc_get_field("Date", default = "",
                                 file = file.path(path, "DESCRIPTION"))
  }
  year <- regmatches(date, regexpr("^[0-9]{4}", date))
  if (length(year)) year else format(Sys.Date(), "%Y")
}

# Initials of the given names in APA style: "Charles B." gives "C. B.",
# "Ana María" gives "A. M." and "Jean-Paul" gives "J.-P.".
apa_initials <- function(given) {
  parts <- unlist(strsplit(trimws(paste(given, collapse = " ")), "\\s+"))
  parts <- parts[nzchar(parts)]
  initials <- vapply(parts, function(part) {
    pieces <- unlist(strsplit(part, "-", fixed = TRUE))
    pieces <- pieces[nzchar(pieces)]
    paste0(toupper(substr(pieces, 1, 1)), ".", collapse = "-")
  }, character(1), USE.NAMES = FALSE)
  paste(initials, collapse = " ")
}

# One person as APA writes it in a reference: "Family, I. I.", or the full
# name of an organisation.
apa_name <- function(p) {
  given <- paste(p$given, collapse = " ")
  if (is.null(p$family)) return(given)
  family <- paste(p$family, collapse = " ")
  if (!nzchar(given)) return(family)
  paste0(family, ", ", apa_initials(given))
}

# The author list of an APA 7 reference: "&" before the last author, and
# with 21 or more authors the first 19, an ellipsis and the last.
apa_author_list <- function(persons) {
  names <- vapply(seq_along(persons), function(i) apa_name(persons[i]), character(1))
  n <- length(names)
  if (n == 1) return(names)
  if (n > 20) return(paste0(paste(names[1:19], collapse = ", "), ", . . . ", names[[n]]))
  paste0(paste(names[-n], collapse = ", "), ", & ", names[[n]])
}

# The family name of a person, or the full name of an organisation.
in_text_name <- function(p) {
  if (is.null(p$family)) paste(p$given, collapse = " ") else paste(p$family, collapse = " ")
}

# The parenthetical in-text citation without its parentheses: one author,
# two joined by "&", or the first author with "et al." for three or more.
in_text_citation <- function(persons, year) {
  n <- length(persons)
  first <- in_text_name(persons[1])
  who <- if (n == 1) {
    first
  } else if (n == 2) {
    paste0(first, " & ", in_text_name(persons[2]))
  } else {
    paste0(first, " et al.")
  }
  paste0(who, ", ", year)
}

# The download formats of inst/extdata, named for the reader.
extdata_formats <- function(path = ".") {
  files <- list.files(file.path(path, "inst", "extdata"))
  ext <- tolower(tools::file_ext(files))
  c(if ("csv" %in% ext) "CSV", if (any(c("xlsx", "xls") %in% ext)) "Excel")
}

#' @export
format.washr_data_availability <- function(x, ...) {
  c(cli::style_bold("Reference"), x[["reference"]], "",
    cli::style_bold("Data availability statement"), x[["statement"]], "",
    cli::style_bold("In-text citation"), x[["in_text"]])
}

#' @export
print.washr_data_availability <- function(x, ...) {
  cat(format(x, ...), sep = "\n")
  invisible(x)
}
