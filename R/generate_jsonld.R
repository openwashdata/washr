# Internal builder behind update_metadata(): derives a schema.org Dataset
# description from the canonical sources of a data package. Nothing here is
# hand edited; every value has a source file, and the fields without a value
# are returned in the "blank" attribute together with where to fill them.
#
# Sources (decision document dev/metadata-2026-08/decision-canonical-sources.md,
# amendment of 2026-09-02):
#   DESCRIPTION            name, description, version, date, license, URLs,
#                          keywords and coverage (X-schema.org-* fields),
#                          creators, maintainer, funder and publisher (Authors@R)
#   data-raw/dictionary.csv  datasets and variables
#   CITATION.cff           DOI
#   inst/extdata           one distribution per file that belongs to a dataset
#
# @noRd
build_dataset_jsonld <- function(path = ".") {
  desc_file <- file.path(path, "DESCRIPTION")
  blank <- character()
  note_blank <- function(field, where) blank[[field]] <<- where

  field <- function(key) {
    desc::desc_get_field(key, default = "", file = desc_file)
  }

  pkg <- field("Package")
  title <- field("Title")
  description <- field("Description")
  version <- field("Version")
  date <- field("Date")
  license <- field("License")
  keywords <- split_field(field("X-schema.org-keywords"))
  spatial <- field("X-schema.org-spatialCoverage")
  temporal <- field("X-schema.org-temporalCoverage")
  urls <- desc::desc_get_urls(file = desc_file)
  authors <- tryCatch(desc::desc_get_authors(file = desc_file),
                      error = function(e) NULL)

  if (identical(date, "")) {
    note_blank("datePublished", "set Date in DESCRIPTION (update_description() does this)")
  }
  if (length(keywords) == 0) {
    note_blank("keywords", "set X-schema.org-keywords in DESCRIPTION (comma separated)")
  }
  if (identical(spatial, "")) {
    note_blank("spatialCoverage", "set X-schema.org-spatialCoverage in DESCRIPTION (e.g., Kampala, Uganda)")
  }
  if (identical(temporal, "")) {
    note_blank("temporalCoverage", "set X-schema.org-temporalCoverage in DESCRIPTION (e.g., 2022-03-01/2022-09-30)")
  }

  # Repository and site from the DESCRIPTION URL field
  repo_url <- github_repo_url(path)
  site_url <- urls[grepl("github\\.io", urls)]
  site_url <- if (length(site_url)) site_url[[1]] else repo_url
  if (is.null(repo_url)) {
    note_blank("url", "add the GitHub repository to URL in DESCRIPTION (update_description() does this)")
  }
  org <- if (!is.null(repo_url)) basename(dirname(repo_url)) else NULL
  repo <- if (!is.null(repo_url)) basename(repo_url) else NULL

  # DOI from CITATION.cff
  cff_file <- file.path(path, "CITATION.cff")
  doi <- NULL
  if (file.exists(cff_file)) {
    cff <- cffr::cff_read(cff_file)
    doi <- cff$doi
  }
  if (is.null(doi) || identical(doi, "")) {
    doi <- NULL
    note_blank("identifier (DOI)", "run update_citation(doi = ...) after the release is deposited")
  }

  # People and organisations from Authors@R
  people <- authors_jsonld(authors)
  if (length(people$creator) == 0) {
    note_blank("creator", "add persons with role aut or cre to Authors@R in DESCRIPTION")
  }
  publisher <- people$publisher
  if (is.null(publisher) && !is.null(org)) {
    publisher <- list("@type" = "Organization", name = org,
                      url = paste0("https://github.com/", org))
  }

  # Datasets and variables from the dictionary
  dictionary <- read_dictionary(path)
  datasets <- unique(tools::file_path_sans_ext(dictionary$file_name))
  if (length(datasets) == 0) {
    note_blank("variableMeasured", "the dictionary in data-raw/dictionary.csv has no rows")
  }
  variables <- variables_jsonld(dictionary, datasets)
  n_blank_desc <- sum(is.na(dictionary$description) | trimws(dictionary$description) == "")
  if (n_blank_desc > 0) {
    note_blank("variable descriptions",
               paste0(n_blank_desc, " description(s) are blank in data-raw/dictionary.csv"))
  }

  # Distributions from the files that exist in inst/extdata
  dist <- distributions_jsonld(path, datasets, org, repo)
  if (length(dist$distribution) == 0) {
    note_blank("distribution", "export the datasets to inst/extdata (csv, xlsx, csv.gz)")
  }
  if (length(dist$ignored) > 0) {
    note_blank("inst/extdata files not matching a dataset",
               paste(dist$ignored, collapse = ", "))
  }

  out <- list(
    "@context" = "https://schema.org",
    "@type" = "Dataset",
    name = title,
    alternateName = pkg,
    description = description,
    version = version,
    url = site_url,
    sameAs = if (!is.null(doi)) paste0("https://doi.org/", doi),
    identifier = doi,
    datePublished = if (!identical(date, "")) date,
    license = if (!identical(license, "")) license_url(license),
    isAccessibleForFree = TRUE,
    keywords = if (length(keywords)) I(keywords),
    creator = if (length(people$creator)) people$creator,
    maintainer = people$maintainer,
    publisher = publisher,
    funder = if (length(people$funder)) people$funder,
    spatialCoverage = if (!identical(spatial, "")) list("@type" = "Place", name = spatial),
    temporalCoverage = if (!identical(temporal, "")) temporal,
    variableMeasured = if (length(variables)) variables,
    distribution = if (length(dist$distribution)) dist$distribution
  )
  out <- out[!vapply(out, is.null, logical(1))]
  attr(out, "blank") <- blank
  out
}

# Split a comma separated DESCRIPTION field into a trimmed character vector.
split_field <- function(x) {
  if (is.null(x) || identical(x, "")) return(character())
  parts <- trimws(strsplit(x, ",")[[1]])
  parts[parts != ""]
}

read_dictionary <- function(path = ".") {
  dictionary <- utils::read.csv(file.path(path, "data-raw", "dictionary.csv"),
                                stringsAsFactors = FALSE, encoding = "UTF-8",
                                na.strings = c("", "NA"))
  needed <- c("file_name", "variable_name", "description")
  missing <- setdiff(needed, names(dictionary))
  if (length(missing)) {
    usethis::ui_stop("data-raw/dictionary.csv lacks the column(s) {usethis::ui_value(missing)}.")
  }
  dictionary
}

# Creators (aut, cre), maintainer (cre), funder (fnd) and publisher (cph) from
# a person vector. A person without a family name is treated as an organisation.
authors_jsonld <- function(authors) {
  creator <- list()
  funder <- list()
  maintainer <- NULL
  publisher <- NULL
  for (i in seq_along(authors)) {
    p <- authors[i]
    roles <- p$role
    entity <- person_jsonld(p)
    if (any(c("aut", "cre") %in% roles)) creator[[length(creator) + 1]] <- entity
    if ("cre" %in% roles && is.null(maintainer)) {
      maintainer <- entity
      if (!is.null(p$email)) maintainer$email <- p$email
    }
    if ("fnd" %in% roles) funder[[length(funder) + 1]] <- entity
    if ("cph" %in% roles && is.null(publisher)) publisher <- entity
  }
  list(creator = creator, maintainer = maintainer, funder = funder,
       publisher = publisher)
}

person_jsonld <- function(p) {
  given <- p$given
  family <- p$family
  comment <- p$comment
  if (is.null(family)) {
    return(list("@type" = "Organization", name = paste(given, collapse = " ")))
  }
  out <- list("@type" = "Person",
              givenName = paste(given, collapse = " "),
              familyName = family,
              name = paste(c(given, family), collapse = " "))
  if (!is.null(comment) && "ORCID" %in% names(comment)) {
    out$sameAs <- paste0("https://orcid.org/", comment[["ORCID"]])
  }
  if (!is.null(comment) && "affiliation" %in% names(comment)) {
    out$affiliation <- list("@type" = "Organization", name = comment[["affiliation"]])
  }
  out
}

# One PropertyValue per dictionary row. With several datasets the variable
# name is prefixed by its dataset so names stay unique.
variables_jsonld <- function(dictionary, datasets) {
  if (nrow(dictionary) == 0) return(list())
  dataset <- tools::file_path_sans_ext(dictionary$file_name)
  lapply(seq_len(nrow(dictionary)), function(i) {
    name <- dictionary$variable_name[i]
    if (length(datasets) > 1) name <- paste0(dataset[i], ".", name)
    out <- list("@type" = "PropertyValue", name = name)
    d <- dictionary$description[i]
    if (!is.na(d) && trimws(d) != "") out$description <- d
    out
  })
}

# One DataDownload per file in inst/extdata whose name starts with a dataset
# name. Files that belong to no dataset are returned as `ignored`. The
# contentUrl points at the raw file on the main branch of the repository.
distributions_jsonld <- function(path, datasets, org, repo) {
  dir <- file.path(path, "inst", "extdata")
  files <- sort(list.files(dir))
  belongs <- vapply(files, function(f) {
    any(startsWith(f, paste0(datasets, ".")))
  }, logical(1))
  distribution <- lapply(files[belongs], function(f) {
    out <- list("@type" = "DataDownload", name = f, encodingFormat = mime_type(f))
    if (!is.null(org) && !is.null(repo)) {
      out$contentUrl <- sprintf("https://raw.githubusercontent.com/%s/%s/main/inst/extdata/%s",
                                org, repo, f)
    }
    out
  })
  list(distribution = unname(distribution), ignored = files[!belongs])
}

mime_type <- function(file) {
  lower <- tolower(file)
  if (grepl("\\.gz$", lower)) return("application/gzip")
  switch(tools::file_ext(lower),
    csv = "text/csv",
    tsv = "text/tab-separated-values",
    txt = "text/plain",
    xlsx = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    xls = "application/vnd.ms-excel",
    json = "application/json",
    parquet = "application/vnd.apache.parquet",
    zip = "application/zip",
    "application/octet-stream"
  )
}

# Map the DESCRIPTION License field to a URL; unknown licenses pass through.
license_url <- function(license) {
  key <- trimws(sub("\\+\\s*file\\s+LICEN[CS]E", "", license))
  map <- c(
    "CC BY 4.0" = "https://creativecommons.org/licenses/by/4.0/",
    "CC BY-SA 4.0" = "https://creativecommons.org/licenses/by-sa/4.0/",
    "CC BY-NC 4.0" = "https://creativecommons.org/licenses/by-nc/4.0/",
    "CC BY-NC-SA 4.0" = "https://creativecommons.org/licenses/by-nc-sa/4.0/",
    "CC0" = "https://creativecommons.org/publicdomain/zero/1.0/",
    "MIT" = "https://opensource.org/license/mit",
    "Apache License (>= 2)" = "https://www.apache.org/licenses/LICENSE-2.0",
    "GPL-2" = "https://www.gnu.org/licenses/old-licenses/gpl-2.0.html",
    "GPL-3" = "https://www.gnu.org/licenses/gpl-3.0.html",
    "GPL (>= 2)" = "https://www.gnu.org/licenses/old-licenses/gpl-2.0.html",
    "GPL (>= 3)" = "https://www.gnu.org/licenses/gpl-3.0.html"
  )
  if (key %in% names(map)) unname(map[[key]]) else license
}

# The pkgdown template that carries the JSON-LD. The first line keeps the
# in_header includes from _pkgdown.yml working (it is pkgdown's own template).
jsonld_template <- function(dataset) {
  attr(dataset, "blank") <- NULL
  json <- jsonlite::toJSON(dataset, pretty = TRUE, auto_unbox = TRUE)
  paste(c(
    "{{#includes}}{{{in_header}}}{{/includes}}",
    "<!-- schema.org Dataset metadata generated by washr::update_metadata() from DESCRIPTION, data-raw/dictionary.csv, CITATION.cff and inst/extdata. Do not edit: change the source and run it again. -->",
    "<script type=\"application/ld+json\">",
    as.character(json),
    "</script>"
  ), collapse = "\n")
}
