#' Check whether the data package is ready for publication
#'
#' @description
#' `check_publication_readiness()` walks through the publication workflow and
#' reports, item by item, what is in place and what is missing. For every gap
#' it names the step and the washr function that closes it, so a skipped
#' step shows up here and not as an error in a later function. The function
#' only reads the package. It writes nothing.
#'
#' The items are the mechanically decidable part of the openwashdata review
#' standard for the metadata, the data dictionary, the documentation and the
#' check workflow of a package. Each item has a stable `id`, so a script or
#' a review tool can pick the rows it needs.
#'
#' | Area | `id` | Passes when |
#' |---|---|---|
#' | metadata | `license` | `License` in DESCRIPTION is CC BY 4.0 |
#' | metadata | `description_complete` | `Title`, `Description` and `Authors@R` no longer hold the placeholder text of a new package |
#' | metadata | `citation_cff` | `CITATION.cff` is present |
#' | metadata | `citation_version` | the `version` in `CITATION.cff` equals `Version` in DESCRIPTION |
#' | metadata | `citation_authors` | `CITATION.cff` and `inst/CITATION` carry real authors, not "Firstname Lastname" |
#' | metadata | `zenodo_json` | `.zenodo.json` is present and equals what DESCRIPTION gives now |
#' | metadata | `keywords` | DESCRIPTION carries `X-schema.org-keywords`; the detail says whether `CITATION.cff` agrees |
#' | metadata | `coverage` | DESCRIPTION carries `X-schema.org-spatialCoverage` and `X-schema.org-temporalCoverage` |
#' | metadata | `title_length` | `Title` has at most 65 characters |
#' | data | `data_present` | `data/` holds at least one `.rda` file that loads |
#' | data | `dictionary_present` | `data-raw/dictionary.csv` is present |
#' | data | `dictionary_coverage` | the dictionary covers every variable of every data object |
#' | data | `dictionary_descriptions` | no description is empty or a placeholder |
#' | data | `dictionary_schema` | the five washr columns in order, UTF-8 without a byte order mark, one class name per `variable_type` |
#' | docs | `roxygen_docs` | every data object has a help page in `man/` |
#' | docs | `readme` | `README.Rmd` and the rendered `README.md` are present |
#' | docs | `rd_source` | at least one help page in `man/` carries a source |
#' | docs | `readme_extdata_links` | `README.md` links a `.csv` or `.xlsx` file under `inst/extdata/` |
#' | docs | `vignettes_location` | no `.Rmd` or `.qmd` file sits directly in `vignettes/` |
#' | docs | `pkgdown_config` | `_pkgdown.yml` is present |
#' | docs | `pkgdown_analytics` | `_pkgdown.yml` carries the analytics header |
#' | docs | `pkgdown_url` | `url` in `_pkgdown.yml` is the Pages URL, not the repository URL |
#' | docs | `pkgdown_funding` | `_pkgdown.yml` carries the funding text of the organisation |
#' | docs | `pkgdown_brand` | the brand entry in `_pkgdown.yml` matches the organisation |
#' | docs | `docs_untracked` | git tracks no file under `docs/` while the pkgdown workflow deploys the site |
#' | tests | `check_workflow` | `.github/workflows/R-CMD-check.yaml` is present |
#' | tests | `check_workflow_dev` | every `branches:` list in that workflow includes `dev` |
#' | tests | `check_badge` | `README.Rmd` carries the R CMD check badge |
#'
#' An item that cannot be decided is reported as not applicable, with the
#' reason: for example the version comparison when `CITATION.cff` is missing,
#' or the `docs/` item when the package has no pkgdown workflow. Not
#' applicable items never count against the package.
#'
#' @param path Path to the root of the data package. Defaults to the working
#'   directory.
#' @param profile A named list with what the organisation expects of its
#'   packages. With `NULL`, the default, the package is held to its own
#'   values: the `Config/washr/` fields in its DESCRIPTION that
#'   [update_description()] writes. A review tool passes the profile of the
#'   organisation instead. All entries are optional:
#'   * `analytics`: `"plausible"` (the default) or `"none"`. With `"none"`
#'     the analytics item is not applicable.
#'   * `site_url_pattern`: the Pages URL of a package, with `<package>` in
#'     place of the package name. Without it, any `github.io` URL passes.
#'   * `funding_text`: the funding sentence that `_pkgdown.yml` has to carry
#'     word for word. Without it, the funding item is not applicable.
#'   * `keywords_required`: keywords every package of the organisation has
#'     to carry.
#'   * `brand`: `"none"` when the organisation has no brand, or the name of
#'     its brand. Without it, the brand item is not applicable.
#'
#' @returns A data frame of class `washr_readiness`, invisibly, with one row
#'   per item and the columns `id`, `area`, `check` (the item in words),
#'   `status` (`"pass"`, `"fail"` or `"na"` for not applicable), `detail`
#'   (what was found) and `fix` (the step that closes the gap). The attribute
#'   `ready` is `TRUE` when no item fails, `washr_version` holds the installed
#'   washr version, and `package` the name and version of the package that
#'   was checked. Printing the object shows the report again.
#'
#' @seealso Before: every step of the workflow, up to [update_citation()] and
#'   [setup_website()]. Next: fix the items that fail and run it again, then
#'   release the package.
#'
#' @family publishing functions
#'
#' @export
#'
#' @examples
#' \dontrun{
#' check_publication_readiness()
#'
#' # Keep the result and work with the items that fail
#' readiness <- check_publication_readiness()
#' readiness[readiness$status == "fail", c("id", "detail", "fix")]
#' attr(readiness, "ready")
#' }
check_publication_readiness <- function(path = ".", profile = NULL) {
  if (!file.exists(file.path(path, "DESCRIPTION")) ||
      !file.exists(file.path(path, "NAMESPACE"))) {
    cli::cli_abort(c(
      "{.path {path}} is not the root of a package.",
      "i" = "Point {.arg path} at the directory that holds DESCRIPTION and NAMESPACE."
    ))
  }
  ctx <- readiness_context(path, readiness_profile(profile, path))
  out <- run_readiness_checks(ctx)
  attr(out, "ready") <- !any(out$status == "fail")
  attr(out, "washr_version") <- as.character(utils::packageVersion("washr"))
  package <- c(ctx$field("Package"), ctx$field("Version"))
  attr(out, "package") <- paste(package[!is.na(package)], collapse = " ")
  class(out) <- c("washr_readiness", "data.frame")
  if (!is_quiet()) cli::cli_verbatim(format(out))
  invisible(out)
}

#' @export
format.washr_readiness <- function(x, ...) {
  mark <- c(pass = cli::col_green(cli::symbol$tick),
            fail = cli::col_red(cli::symbol$cross),
            na = cli::col_grey("-"))
  lines <- sprintf("Publication readiness: %s (washr %s)",
                   attr(x, "package"), attr(x, "washr_version"))
  for (area in unique(x$area)) {
    lines <- c(lines, "", cli::style_bold(area))
    rows <- x[x$area == area, , drop = FALSE]
    for (i in seq_len(nrow(rows))) {
      r <- rows[i, ]
      detail <- if (r$status == "na") {
        paste0(": not applicable", if (nzchar(r$detail)) paste0(", ", r$detail))
      } else if (nzchar(r$detail)) {
        paste0(": ", r$detail)
      } else {
        ""
      }
      lines <- c(lines, paste0(mark[[r$status]], " ", r$check, detail))
      if (r$status == "fail" && !is.na(r$fix)) {
        lines <- c(lines, paste0("  ", cli::symbol$arrow_right, " ", r$fix))
      }
    }
  }
  n <- table(factor(x$status, levels = c("pass", "fail", "na")))
  summary <- sprintf("%d pass, %d fail, %d not applicable", n[["pass"]], n[["fail"]], n[["na"]])
  verdict <- if (n[["fail"]] == 0) {
    cli::col_green("Ready for publication: no item fails.")
  } else {
    cli::col_red(sprintf("Not ready for publication: %d item%s to fix.",
                         n[["fail"]], if (n[["fail"]] == 1) "" else "s"))
  }
  c(lines, "", summary, verdict)
}

#' @export
print.washr_readiness <- function(x, ...) {
  cat(format(x, ...), sep = "\n")
  invisible(x)
}

# The organisation profile with its defaults filled in.
readiness_profile <- function(profile, path = ".") {
  if (is.null(profile)) profile <- package_profile(path)
  if (!is.list(profile)) {
    cli::cli_abort("{.arg profile} must be a named list or {.code NULL}.")
  }
  analytics <- if (length(profile$analytics)) tolower(profile$analytics[[1]]) else "plausible"
  if (!analytics %in% c("plausible", "none")) {
    cli::cli_abort("The {.field analytics} entry of {.arg profile} must be {.val plausible} or {.val none}, not {.val {analytics}}.")
  }
  profile$analytics <- analytics
  profile
}

# What the package says about its own organisation in the Config/washr
# fields of DESCRIPTION (#81), in the keys of a review profile. A package
# checked without a profile is held to its own values.
package_profile <- function(path = ".") {
  analytics <- pkg_config("analytics-domain", path)
  funding <- pkg_config("funding", path)
  brand <- pkg_config("brand-source", path)
  profile <- list(
    analytics = if (is_set(analytics)) "plausible" else "none",
    site_url_pattern = paste0("https://", pkg_pages_domain(path), "/<package>/"),
    brand = if (is_set(brand)) brand else "none"
  )
  if (is_set(funding)) profile$funding_text <- funding
  profile
}

# Everything the checks read, loaded once: the DESCRIPTION fields, the data
# objects in data/, the dictionary and the organisation profile.
readiness_context <- function(path, profile) {
  dcf <- read.dcf(file.path(path, "DESCRIPTION"))
  file <- function(...) file.path(path, ...)
  has <- function(...) file.exists(file(...))
  lines <- function(...) if (has(...)) readLines(file(...), warn = FALSE) else character()
  field <- function(name) {
    if (name %in% colnames(dcf)) unname(dcf[1, name]) else NA_character_
  }

  rda_files <- if (dir.exists(file("data"))) list.files(file("data"), "\\.rda$") else character()
  datasets <- list()
  for (f in rda_files) {
    env <- new.env()
    loaded <- tryCatch({
      suppressWarnings(load(file("data", f), envir = env))
      TRUE
    }, error = function(e) FALSE)
    if (loaded) for (nm in ls(env)) datasets[[nm]] <- get(nm, envir = env)
  }

  dict_path <- file("data-raw", "dictionary.csv")
  dictionary <- if (file.exists(dict_path)) {
    tryCatch(suppressWarnings(utils::read.csv(dict_path, stringsAsFactors = FALSE)),
             error = function(e) NULL)
  }
  # Bytes that are not valid UTF-8 are reported by the schema item; here they
  # are made printable so the other dictionary items can still be decided.
  if (is.data.frame(dictionary)) {
    text <- vapply(dictionary, is.character, logical(1))
    dictionary[text] <- lapply(dictionary[text], iconv, from = "UTF-8", to = "UTF-8", sub = "byte")
  }

  git <- function(...) {
    tryCatch(
      system2("git", c("-C", shQuote(path), ...), stdout = TRUE, stderr = FALSE),
      warning = function(w) character(), error = function(e) character()
    )
  }

  list(path = path, profile = profile, file = file, has = has, lines = lines,
       field = field, rda_files = rda_files, datasets = datasets,
       dict_path = dict_path, dictionary = dictionary, git = git)
}

# Run the checks (all of them, or the ones named in `ids`) and return one
# row per check. A check that stops with an error is reported as a failure
# of that item, so one broken file never hides the other items.
run_readiness_checks <- function(ctx, ids = NULL) {
  checks <- readiness_checks()
  if (!is.null(ids)) checks <- checks[vapply(checks, function(chk) chk$id %in% ids, logical(1))]
  rows <- lapply(checks, function(chk) {
    res <- tryCatch(chk$run(ctx), error = function(e) {
      list(status = "fail", detail = paste("the check stopped with an error:", conditionMessage(e)))
    })
    data.frame(id = chk$id, area = chk$area, check = chk$check,
               status = res$status, detail = res$detail, fix = chk$fix,
               stringsAsFactors = FALSE)
  })
  do.call(rbind, rows)
}

readiness_result <- function(ok, detail = "") {
  list(status = if (isTRUE(ok)) "pass" else "fail", detail = detail)
}

readiness_na <- function(detail) {
  list(status = "na", detail = detail)
}

# The registry: id, area, the item in words, the step that closes the gap and
# the function that decides it. The wording of `check` and of the details
# follows the mechanical items of the pkgreview check script, which maps
# them one to one (openwashdata/pkgreview#66).
readiness_checks <- function() {
  check <- function(id, area, check, fix, run) {
    list(id = id, area = area, check = check, fix = fix, run = run)
  }
  list(
    check("license", "metadata", "License: CC BY 4.0",
          "Run update_description(), or usethis::use_ccby_license() when another license is set.",
          readiness_license),
    check("description_complete", "metadata",
          "DESCRIPTION carries a title, a description and authors, not the placeholder text",
          "Write Title, Description and Authors@R in DESCRIPTION.",
          readiness_description_complete),
    check("citation_cff", "metadata", "CITATION.cff present",
          "Run update_citation().",
          readiness_citation_cff),
    check("citation_version", "metadata", "CITATION.cff version matches DESCRIPTION",
          "Run update_citation() again, so CITATION.cff follows Version in DESCRIPTION.",
          readiness_citation_version),
    check("citation_authors", "metadata",
          "Citation files carry real authors, not template placeholders",
          "Write the authors in Authors@R in DESCRIPTION, then run update_citation().",
          readiness_citation_authors),
    check("zenodo_json", "metadata", ".zenodo.json present and in line with DESCRIPTION",
          "Run update_citation(), which writes .zenodo.json from DESCRIPTION.",
          readiness_zenodo_json),
    check("keywords", "metadata", "DESCRIPTION carries X-schema.org-keywords",
          "Set X-schema.org-keywords in DESCRIPTION (comma separated), then run update_citation().",
          readiness_keywords),
    check("coverage", "metadata",
          "DESCRIPTION carries X-schema.org spatial and temporal coverage",
          "Set X-schema.org-spatialCoverage and X-schema.org-temporalCoverage in DESCRIPTION, then run update_metadata().",
          readiness_coverage),
    check("title_length", "metadata", "Title is at most 65 characters",
          "Shorten Title in DESCRIPTION.",
          readiness_title_length),
    check("data_present", "data", "Primary data present in data/ as .rda and loads",
          "Export the tidy data with usethis::use_data() in data-raw/data_processing.R, the script that setup_rawdata() writes.",
          readiness_data_present),
    check("dictionary_present", "data", "data-raw/dictionary.csv present",
          "Run setup_dictionary().",
          readiness_dictionary_present),
    check("dictionary_coverage", "data",
          "Dictionary covers every variable in every dataset",
          "Run update_dictionary(), which adds a row for each missing variable, then write the descriptions.",
          readiness_dictionary_coverage),
    check("dictionary_descriptions", "data",
          "Dictionary descriptions present (no empty or placeholder)",
          "Write the descriptions in data-raw/dictionary.csv, then run setup_roxygen().",
          readiness_dictionary_descriptions),
    check("dictionary_schema", "data",
          "Dictionary schema: five washr columns, UTF-8 without BOM, single-class variable_type",
          "Keep the five columns that setup_dictionary() writes and save the file as UTF-8 without a byte order mark.",
          readiness_dictionary_schema),
    check("roxygen_docs", "docs", "Every dataset has a help page in man/",
          "Run setup_roxygen(), then devtools::document().",
          readiness_roxygen_docs),
    check("readme", "docs", "README.Rmd and rendered README.md present",
          "Run setup_readme(), then devtools::build_readme().",
          readiness_readme),
    check("rd_source", "docs", "Roxygen @source present for the datasets",
          "Add a @source line to the roxygen file of each dataset in R/, then run devtools::document().",
          readiness_rd_source),
    check("readme_extdata_links", "docs",
          "README links the CSV/XLSX exports in inst/extdata/ for non-R users",
          "Export CSV and XLSX files to inst/extdata/, keep the download table of the setup_readme() template, then run devtools::build_readme().",
          readiness_readme_extdata_links),
    check("vignettes_location", "docs",
          "No vignettes directly in vignettes/ (they belong in vignettes/articles/)",
          "Move the files to vignettes/articles/, where usethis::use_article() puts them.",
          readiness_vignettes_location),
    check("pkgdown_config", "docs", "_pkgdown.yml present",
          "Run setup_website().",
          readiness_pkgdown_config),
    check("pkgdown_analytics", "docs", "_pkgdown.yml carries the Plausible analytics header",
          "Add the analytics header under template, includes, in_header in _pkgdown.yml. The setup_website() template carries it.",
          readiness_pkgdown_analytics),
    check("pkgdown_url", "docs", "_pkgdown.yml url is the Pages URL, not the repo URL",
          "Set url in _pkgdown.yml to the Pages URL of the site.",
          readiness_pkgdown_url),
    check("pkgdown_funding", "docs",
          "_pkgdown.yml carries the funding sidebar text from the org profile",
          "Add the funding text to the sidebar in _pkgdown.yml.",
          readiness_pkgdown_funding),
    check("pkgdown_brand", "docs", "_pkgdown.yml brand wiring matches the org profile",
          "Remove the brand entry from _pkgdown.yml, or run use_brand() when the organisation has a brand.",
          readiness_pkgdown_brand),
    check("docs_untracked", "docs",
          "docs/ untracked while the pkgdown workflow deploys the site",
          "Run git rm -r --cached docs and add docs to .gitignore.",
          readiness_docs_untracked),
    check("check_workflow", "tests", "GitHub Actions R-CMD-check workflow present",
          "Run setup_ci().",
          readiness_check_workflow),
    check("check_workflow_dev", "tests",
          "R-CMD-check workflow triggers include dev (push and pull_request)",
          "Add dev to every branches list in .github/workflows/R-CMD-check.yaml, or delete the file and run setup_ci().",
          readiness_check_workflow_dev),
    check("check_badge", "tests", "R-CMD-check badge in README.Rmd",
          "Run setup_ci(), which adds the badge between the badge markers of README.Rmd.",
          readiness_check_badge)
  )
}

# metadata -------------------------------------------------------------------

readiness_license <- function(ctx) {
  lic <- ctx$field("License")
  readiness_result(!is.na(lic) && grepl("CC BY 4.0", lic, fixed = TRUE),
                   paste("License field:", if (is.na(lic)) "missing" else lic))
}

# The placeholder text usethis::create_package() writes into a new package.
readiness_description_complete <- function(ctx) {
  title <- ctx$field("Title")
  description <- ctx$field("Description")
  authors <- ctx$field("Authors@R")
  if (is.na(authors)) authors <- ctx$field("Author")
  open <- c(
    if (is.na(title) || grepl("What the Package Does", title, fixed = TRUE)) "Title",
    if (is.na(description) || grepl("What the package does", description, fixed = TRUE)) "Description",
    if (is.na(authors) || grepl("\"First\",\\s*\"Last\"|first\\.last@example\\.com", authors)) "Authors@R"
  )
  readiness_result(length(open) == 0,
                   if (length(open)) paste("missing or placeholder:", paste(open, collapse = ", ")) else "")
}

readiness_citation_cff <- function(ctx) {
  present <- ctx$has("CITATION.cff") && length(ctx$lines("CITATION.cff")) > 0
  readiness_result(present, if (present) "" else "file missing")
}

readiness_citation_version <- function(ctx) {
  cff <- ctx$lines("CITATION.cff")
  if (length(cff) == 0) return(readiness_na("CITATION.cff missing"))
  v_desc <- ctx$field("Version")
  v_cff <- sub("^version:\\s*['\"]?([^'\"]*)['\"]?\\s*$", "\\1",
               grep("^version:", cff, value = TRUE)[1])
  readiness_result(!is.na(v_desc) && length(v_cff) == 1 && identical(v_desc, v_cff),
                   sprintf("DESCRIPTION %s vs CITATION.cff %s", v_desc, v_cff))
}

readiness_citation_authors <- function(ctx) {
  cff <- ctx$lines("CITATION.cff")
  if (length(cff) == 0) return(readiness_na("CITATION.cff missing"))
  placeholder <- any(grepl("Firstname|Lastname", cff)) ||
    any(grepl("Firstname|Lastname", ctx$lines("inst", "CITATION")))
  readiness_result(!placeholder,
                   if (placeholder) "\"Firstname Lastname\" found in citation files" else "")
}

# Zenodo takes the record of a release from .zenodo.json, version included,
# so a file that lags behind DESCRIPTION files the release under old values.
readiness_zenodo_json <- function(ctx) {
  if (!ctx$has(".zenodo.json")) return(readiness_result(FALSE, "file missing"))
  current <- paste(ctx$lines(".zenodo.json"), collapse = "\n")
  expected <- suppressMessages(zenodo_json_text(build_zenodo_json(ctx$path)))
  same <- identical(current, expected)
  readiness_result(same, if (same) "" else "differs from what DESCRIPTION gives now")
}

# Keywords live in DESCRIPTION; agreement with CITATION.cff is reported in
# the detail and never as a second finding.
readiness_keywords <- function(ctx) {
  kw_field <- ctx$field("X-schema.org-keywords")
  kw <- if (!is.na(kw_field)) trimws(strsplit(kw_field, ",")[[1]]) else character()
  kw <- kw[nzchar(kw)]
  cff <- ctx$lines("CITATION.cff")
  cff_kw <- character()
  kw_start <- grep("^keywords:", cff)
  if (length(kw_start)) {
    i <- kw_start[1] + 1L
    while (i <= length(cff) && grepl("^\\s*-\\s", cff[i])) {
      cff_kw <- c(cff_kw, trimws(sub("^\\s*-\\s*", "", cff[i])))
      i <- i + 1L
    }
  }
  cff_kw <- gsub("^['\"]|['\"]$", "", cff_kw)
  agree <- if (length(cff) == 0) {
    "CITATION.cff missing"
  } else if (length(cff_kw) == 0) {
    "CITATION.cff carries no keywords yet (washr::update_citation() writes them)"
  } else if (setequal(tolower(kw), tolower(cff_kw))) {
    "CITATION.cff agrees"
  } else {
    sprintf("CITATION.cff differs (drift, rerun washr::update_citation()): %s",
            paste(cff_kw, collapse = ", "))
  }
  required <- ctx$profile$keywords_required
  missing <- if (length(kw) && length(required)) {
    required[!tolower(required) %in% tolower(kw)]
  } else {
    character()
  }
  detail <- if (!length(kw)) {
    paste("field missing or empty;", agree)
  } else {
    sprintf("%d keyword(s): %s; %s%s", length(kw), paste(kw, collapse = ", "), agree,
            if (length(missing)) {
              paste0("; required by the org profile but missing: ", paste(missing, collapse = ", "))
            } else {
              ""
            })
  }
  readiness_result(length(kw) > 0 && length(missing) == 0, detail)
}

readiness_coverage <- function(ctx) {
  spatial <- ctx$field("X-schema.org-spatialCoverage")
  temporal <- ctx$field("X-schema.org-temporalCoverage")
  missing <- c(
    if (is.na(spatial) || !nzchar(trimws(spatial))) "X-schema.org-spatialCoverage",
    if (is.na(temporal) || !nzchar(trimws(temporal))) "X-schema.org-temporalCoverage"
  )
  readiness_result(length(missing) == 0,
                   if (length(missing)) {
                     paste("missing:", paste(missing, collapse = ", "))
                   } else {
                     sprintf("spatial: %s; temporal: %s", spatial, temporal)
                   })
}

readiness_title_length <- function(ctx) {
  title <- ctx$field("Title")
  readiness_result(!is.na(title) && nchar(title) <= 65,
                   sprintf("%d characters", if (is.na(title)) 0L else nchar(title)))
}

# data -----------------------------------------------------------------------

readiness_data_present <- function(ctx) {
  readiness_result(length(ctx$rda_files) > 0 && length(ctx$datasets) > 0,
                   sprintf("%d file(s), %d dataset(s)", length(ctx$rda_files), length(ctx$datasets)))
}

readiness_dictionary_present <- function(ctx) {
  present <- file.exists(ctx$dict_path)
  readiness_result(present, if (present) "" else "file missing")
}

# The dictionary as a data frame, or the not applicable result that explains
# why the item cannot be decided.
readiness_dictionary <- function(ctx) {
  if (!file.exists(ctx$dict_path)) return(readiness_na("data-raw/dictionary.csv missing"))
  if (is.null(ctx$dictionary)) {
    return(readiness_result(FALSE, "data-raw/dictionary.csv could not be read as a CSV file"))
  }
  ctx$dictionary
}

readiness_dictionary_coverage <- function(ctx) {
  dict <- readiness_dictionary(ctx)
  if (!is.data.frame(dict)) return(dict)
  all_vars <- unique(unlist(lapply(ctx$datasets, names)))
  missing <- setdiff(all_vars, dict$variable_name)
  readiness_result(length(missing) == 0,
                   if (length(missing)) paste("missing:", paste(missing, collapse = ", ")) else "")
}

readiness_dictionary_descriptions <- function(ctx) {
  dict <- readiness_dictionary(ctx)
  if (!is.data.frame(dict)) return(dict)
  placeholders <- c("", "TODO", "TBD", "todo", "tbd", "...", "description")
  description <- if ("description" %in% names(dict)) dict$description else rep("", nrow(dict))
  bad <- is.na(description) | trimws(description) %in% placeholders
  readiness_result(!any(bad),
                   if (any(bad)) {
                     paste("defective:", paste(dict$variable_name[bad], collapse = ", "))
                   } else {
                     ""
                   })
}

readiness_dictionary_schema <- function(ctx) {
  dict <- readiness_dictionary(ctx)
  if (!is.data.frame(dict)) return(dict)
  expected <- c("directory", "file_name", "variable_name", "variable_type", "description")
  head_bytes <- readBin(ctx$dict_path, "raw", n = 3L)
  has_bom <- length(head_bytes) == 3L &&
    identical(as.integer(head_bytes), c(0xEFL, 0xBBL, 0xBFL))
  dict_lines <- readLines(ctx$dict_path, warn = FALSE)
  bad_utf8 <- !all(validUTF8(dict_lines))
  header <- if (length(dict_lines)) sub("^\ufeff", "", dict_lines[1]) else ""
  cols <- tryCatch(scan(text = header, what = "", sep = ",", quiet = TRUE, strip.white = FALSE),
                   error = function(e) character())
  types <- if ("variable_type" %in% names(dict)) as.character(dict$variable_type) else character()
  type_bad <- !is.na(types) & nzchar(types) & !grepl("^[A-Za-z][A-Za-z0-9_.]*$", types)
  problems <- c(
    if (has_bom) "UTF-8 byte order mark at the start of the file",
    if (bad_utf8) "non-UTF-8 bytes in the file",
    if (!identical(cols, expected)) {
      sprintf("columns are [%s], expected [%s]",
              paste(cols, collapse = ", "), paste(expected, collapse = ", "))
    },
    if (any(type_bad)) {
      sprintf("variable_type is not a single class name for: %s",
              paste(unique(dict$variable_name[type_bad]), collapse = ", "))
    }
  )
  readiness_result(length(problems) == 0, paste(problems, collapse = "; "))
}

# docs -----------------------------------------------------------------------

readiness_roxygen_docs <- function(ctx) {
  datasets <- names(ctx$datasets)
  if (length(datasets) == 0) return(readiness_na("no data object in data/"))
  missing <- datasets[!vapply(datasets, function(d) ctx$has("man", paste0(d, ".Rd")), logical(1))]
  readiness_result(length(missing) == 0,
                   if (length(missing)) {
                     paste("no help page for:", paste(missing, collapse = ", "))
                   } else {
                     ""
                   })
}

readiness_readme <- function(ctx) {
  readiness_result(ctx$has("README.Rmd") && ctx$has("README.md"), "")
}

readiness_rd_source <- function(ctx) {
  rd_files <- if (dir.exists(ctx$file("man"))) list.files(ctx$file("man"), "\\.Rd$") else character()
  has_source <- any(vapply(rd_files, function(f) {
    any(grepl("\\\\source\\{", ctx$lines("man", f)))
  }, logical(1)))
  readiness_result(has_source, "")
}

readiness_readme_extdata_links <- function(ctx) {
  readme <- ctx$lines("README.md")
  links <- grep("inst/extdata/[^)\\s\"']+\\.(csv|xlsx)", readme, ignore.case = TRUE, perl = TRUE)
  readiness_result(length(links) > 0,
                   if (length(links)) {
                     sprintf("%d line(s) link into inst/extdata/", length(links))
                   } else {
                     "no link to a .csv or .xlsx file under inst/extdata/ (the washr README template's download table provides them)"
                   })
}

readiness_vignettes_location <- function(ctx) {
  vignettes <- if (dir.exists(ctx$file("vignettes"))) {
    list.files(ctx$file("vignettes"), "\\.(Rmd|qmd)$")
  } else {
    character()
  }
  readiness_result(length(vignettes) == 0, paste(vignettes, collapse = ", "))
}

readiness_pkgdown_config <- function(ctx) {
  present <- length(ctx$lines("_pkgdown.yml")) > 0
  readiness_result(present, if (present) "" else "file missing")
}

readiness_pkgdown_analytics <- function(ctx) {
  config <- ctx$lines("_pkgdown.yml")
  if (length(config) == 0) return(readiness_na("_pkgdown.yml missing"))
  if (ctx$profile$analytics == "none") {
    return(readiness_na("org profile defines no analytics header"))
  }
  readiness_result(any(grepl("plausible\\.io", config)), "")
}

readiness_pkgdown_url <- function(ctx) {
  config <- ctx$lines("_pkgdown.yml")
  if (length(config) == 0) return(readiness_na("_pkgdown.yml missing"))
  url_line <- grep("^url:", config, value = TRUE)
  url <- if (length(url_line)) trimws(sub("^url:\\s*", "", url_line[1])) else ""
  pattern <- ctx$profile$site_url_pattern
  package <- ctx$field("Package")
  if (length(pattern) && !is.na(package)) {
    expected <- sub("<package>", package, pattern[[1]], fixed = TRUE)
    norm <- function(u) sub("/+$", "", u)
    return(readiness_result(
      nzchar(url) && identical(norm(url), norm(expected)),
      if (nzchar(url)) {
        sprintf("url: %s (expected %s)", url, expected)
      } else {
        sprintf("no url: line (expected %s)", expected)
      }
    ))
  }
  readiness_result(nzchar(url) && grepl("github\\.io", url),
                   if (length(url_line)) url_line[1] else "no url: line")
}

readiness_pkgdown_funding <- function(ctx) {
  config <- ctx$lines("_pkgdown.yml")
  if (length(config) == 0) return(readiness_na("_pkgdown.yml missing"))
  funding <- ctx$profile$funding_text
  if (!length(funding)) return(readiness_na("org profile defines no funding text"))
  found <- any(grepl(funding[[1]], config, fixed = TRUE))
  readiness_result(found,
                   if (found) "" else "the profile's funding text was not found verbatim")
}

readiness_pkgdown_brand <- function(ctx) {
  config <- ctx$lines("_pkgdown.yml")
  if (length(config) == 0) return(readiness_na("_pkgdown.yml missing"))
  brand <- ctx$profile$brand
  if (!length(brand)) return(readiness_na("org profile names no brand"))
  wired <- any(grepl("^\\s*brand:\\s*_brand\\.yml", config))
  if (identical(tolower(brand[[1]]), "none")) {
    return(readiness_result(
      !wired,
      if (wired) "bslib.brand is wired although the organization defines no brand; remove it" else ""
    ))
  }
  readiness_result(TRUE,
                   if (wired) {
                     sprintf("wired to _brand.yml (%s)", brand[[1]])
                   } else {
                     sprintf("not wired; optional (%s via washr::use_brand())", brand[[1]])
                   })
}

# With the pkgdown workflow in place, docs/ is ignored and never committed.
readiness_docs_untracked <- function(ctx) {
  workflow <- ctx$has(".github", "workflows", "pkgdown.yaml") ||
    ctx$has(".github", "workflows", "pkgdown.yml")
  if (!workflow) {
    return(readiness_na("no .github/workflows/pkgdown.yaml; the required Website item covers the missing workflow"))
  }
  inside <- ctx$git("rev-parse", "--is-inside-work-tree")
  if (!(length(inside) && identical(trimws(inside[1]), "true"))) {
    return(readiness_na("package directory is not a git repository"))
  }
  tracked <- ctx$git("ls-files", "docs")
  tracked <- tracked[nzchar(tracked)]
  readiness_result(
    length(tracked) == 0,
    if (length(tracked)) {
      sprintf("%d tracked file(s) under docs/; untrack them (git rm -r --cached docs) and ignore the directory",
              length(tracked))
    } else {
      ""
    }
  )
}

# tests ----------------------------------------------------------------------

readiness_check_workflow <- function(ctx) {
  readiness_result(ctx$has(".github", "workflows", "R-CMD-check.yaml"), "")
}

# The value of every `branches:` key of a workflow file, inline
# (`[main, dev]`) or as a nested list.
workflow_branch_blocks <- function(lines) {
  out <- character()
  i <- 1L
  while (i <= length(lines)) {
    m <- regmatches(lines[i], regexec("^(\\s*)branches:\\s*(.*)$", lines[i]))[[1]]
    if (length(m) == 3L) {
      indent <- nchar(m[2])
      val <- gsub("^\\[|\\]$", "", trimws(m[3]))
      if (nzchar(val)) {
        out <- c(out, val)
        i <- i + 1L
        next
      }
      j <- i + 1L
      items <- character()
      while (j <= length(lines) && grepl("^\\s*-\\s", lines[j]) &&
             nchar(sub("^(\\s*).*$", "\\1", lines[j])) > indent) {
        items <- c(items, trimws(sub("^\\s*-\\s*", "", lines[j])))
        j <- j + 1L
      }
      out <- c(out, paste(items, collapse = ", "))
      i <- j
      next
    }
    i <- i + 1L
  }
  out
}

readiness_check_workflow_dev <- function(ctx) {
  workflow <- ctx$lines(".github", "workflows", "R-CMD-check.yaml")
  if (length(workflow) == 0) {
    return(readiness_na("workflow file missing; see the presence line above"))
  }
  blocks <- workflow_branch_blocks(workflow)
  readiness_result(
    length(blocks) >= 1L && all(grepl("\\bdev\\b", blocks, perl = TRUE)),
    if (length(blocks)) {
      sprintf("branches: %s", paste(sprintf("[%s]", blocks), collapse = " "))
    } else {
      "no branches: list found under on:"
    }
  )
}

readiness_check_badge <- function(ctx) {
  readiness_result(any(grepl("R-CMD-check", ctx$lines("README.Rmd"))), "")
}
