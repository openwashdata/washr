#' Install or refresh the openwashdata brand in the active package
#'
#' @description
#' `use_brand()` copies the openwashdata brand definition (`_brand.yml`)
#' and the logo files it references from the central
#' [openwashdata/brand](https://github.com/openwashdata/brand) repository
#' into the package root. Re-running the function refreshes an existing
#' copy and reports which files changed, so consuming packages stay in
#' sync with the central definition.
#'
#' Brand values are never edited locally: change them in
#' openwashdata/brand first and cut a release tag there, then refresh
#' consumers with `use_brand()`. After a brand release the order is the
#' Quarto extension, the website, then the data packages.
#'
#' By default the brand is copied at the latest release tag of the brand
#' repository, and the tag is recorded in DESCRIPTION as
#' `Config/washr/brand`, so the package says which brand it carries. A
#' second run with no new tag changes no file. The brand repository is the
#' `Config/washr/brand-source` field that [update_description()] writes
#' (`openwashdata/brand` for openwashdata packages); a group with its own
#' brand names its repository there, and `none` means there is no brand to
#' install.
#'
#' The brand file and the logo directory are added to `.Rbuildignore`, so
#' they stay out of the built package and `R CMD check` does not report them
#' as non-standard top-level files.
#'
#' @details
#' The small logo of the brand becomes the package logo: it is copied to
#' `man/figures/logo.png`, where pkgdown shows it beside the title of the
#' home page, and added to the title line of `README.Rmd`, so GitHub shows
#' it too (pkgdown shows one logo, not two). When the brand names a dark
#' counterpart of that logo, it goes to `pkgdown/assets/logo-dark.png`, and
#' the one rule written to `pkgdown/extra.css` shows it on the dark theme
#' of the site.
#'
#' With `pkgdown = TRUE` (the default), an existing `_pkgdown.yml` is
#' pointed at the brand through bslib (`template.bslib.brand`), so the
#' next [pkgdown::build_site()] renders the site with the brand fonts
#' and colors, `brand.yml` is listed in `Config/Needs/website` so the
#' pkgdown workflow installs it, and the Open Graph image is set to the
#' social preview of the brand repository at the installed release
#' (`assets/social-preview.png`), so a shared link to the site shows the
#' image of the organisation. The wiring adds its lines to `_pkgdown.yml`
#' and leaves the rest of the file, comments included, as it is. Only when the `template`
#' block already carries other bslib settings, or is written on one line,
#' is the file rewritten through the yaml package, which does not preserve
#' comments. When no
#' `_pkgdown.yml` exists, the wiring is skipped with a hint to run
#' [setup_website()] first. Building the wired site requires the
#' brand.yml package (bslib asks for it at build time); it is listed in
#' Suggests and installed on demand.
#'
#' @param ref Character. Git reference (branch or tag) of the brand
#'   repository to copy from. Defaults to the latest release tag. Pass
#'   `"main"` to try brand changes that are not released yet.
#' @param pkgdown Logical. Should `_pkgdown.yml` be wired to use the
#'   brand via bslib? Defaults to `TRUE`.
#' @param source Character. Advanced: an alternative source for the
#'   brand files, either a local directory or a URL prefix. When `NULL`
#'   (the default), the raw GitHub content of the brand repository at
#'   `ref` is used. Mainly useful for tests and offline work.
#'
#' @returns Invisibly, a character vector of the files written or
#'   updated (empty when everything was already current).
#'
#' @seealso Before: [setup_website()], which writes the `_pkgdown.yml` this wires.
#'   For branded PDF and Word reports that read the installed `_brand.yml`,
#'   the openwashdata Quarto extension
#'   [quarto-owd](https://github.com/openwashdata/quarto-owd).
#'
#' @family publishing functions
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Install the brand and wire the pkgdown site
#' use_brand()
#'
#' # Refresh later, without touching _pkgdown.yml
#' use_brand(pkgdown = FALSE)
#' }
use_brand <- function(ref = NULL, pkgdown = TRUE, source = NULL) {
  local_session()
  repo <- NULL
  if (is.null(source)) {
    repo <- if (file.exists("DESCRIPTION")) pkg_config("brand-source") else "openwashdata/brand"
    if (!is_set(repo)) {
      ui_info("No brand repository is configured, so there is nothing to install.")
      ui_todo("Set {.field Config/washr/brand-source} in DESCRIPTION to the GitHub repository of your brand, e.g. {.val openwashdata/brand}.")
      return(invisible(character(0)))
    }
    if (is.null(ref)) ref <- latest_brand_ref(repo)
    source <- brand_base_url(repo, ref)
  }

  changed <- character(0)

  # The brand definition itself.
  brand_tmp <- fetch_brand_file(source, "_brand.yml", repo, ref)
  changed <- c(changed, place_brand_file(brand_tmp, "_brand.yml"))

  # The logo files the brand definition references.
  brand <- yaml::read_yaml("_brand.yml")
  logo_paths <- brand_logo_paths(brand)
  for (path in logo_paths) {
    fetched <- fetch_brand_file(source, path, repo, ref)
    changed <- c(changed, place_brand_file(fetched, path))
  }
  ignore_brand_files(logo_paths)

  # The package logo: the brand's small logo in pkgdown's logo slot and at
  # the title of the README, with its dark counterpart for the light switch
  changed <- c(changed, install_package_logo(brand))

  if (isTRUE(pkgdown)) {
    changed <- c(changed, wire_pkgdown_brand())
    if (!is.null(repo) && !is.null(ref)) {
      changed <- c(changed, wire_pkgdown_opengraph(repo, ref))
    }
    if (file.exists("DESCRIPTION")) changed <- c(changed, need_brand_yml())
  }

  previous <- record_brand_ref(ref)
  if (is.null(ref)) {
    if (length(changed) == 0) ui_done("Brand is up to date; nothing to change.")
  } else if (!is.null(previous) && !identical(previous, ref)) {
    ui_done("Brand moved from {.val {previous}} to {.val {ref}}.")
  } else if (length(changed) == 0) {
    ui_done("Brand is up to date at {.val {ref}}; nothing to change.")
  } else {
    ui_done("Brand installed at {.val {ref}}.")
  }
  invisible(changed)
}

# The latest release tag of the brand repository (#128): the tag of the
# latest GitHub release, else the highest v* tag. A package then carries a
# brand that a release describes, and not whatever sits on the main branch.
latest_brand_ref <- function(repo) {
  release <- latest_release_tag(repo)
  if (!is.null(release)) return(release)
  tags <- github_api(paste0("repos/", repo, "/tags?per_page=100"))
  names <- unlist(lapply(tags, function(tag) tag$name))
  versions <- names[grepl("^v[0-9]+(\\.[0-9]+)*$", names)]
  if (length(versions) > 0) {
    return(versions[order(numeric_version(sub("^v", "", versions)), decreasing = TRUE)][[1]])
  }
  cli::cli_abort(c(
    "Could not find the latest release tag of {.val {repo}}.",
    "i" = "Check the network connection, or name a ref, e.g. {.code use_brand(ref = \"main\")}."
  ))
}

# The tag of the latest GitHub release, read from the redirect of the
# releases/latest page. That page needs no API call, so the rate limit of
# the GitHub API, which a shared network address exhausts quickly, does not
# apply. NULL when the repository has no release or cannot be reached.
latest_release_tag <- function(repo) {
  headers <- tryCatch(
    curlGetHeaders(paste0("https://github.com/", repo, "/releases/latest"),
                   redirect = FALSE),
    error = function(e) character(), warning = function(w) character()
  )
  location <- grep("^location:.*/releases/tag/", headers, ignore.case = TRUE, value = TRUE)
  if (length(location) == 0) return(NULL)
  utils::URLdecode(trimws(sub("^.*/releases/tag/", "", location[[1]])))
}

# One GitHub API response as a list, or NULL when the request fails. A token
# in GITHUB_PAT or GITHUB_TOKEN is sent along, which lifts the rate limit.
github_api <- function(endpoint) {
  token <- Sys.getenv("GITHUB_PAT", Sys.getenv("GITHUB_TOKEN", ""))
  headers <- c(Accept = "application/vnd.github+json")
  if (nzchar(token)) headers <- c(headers, Authorization = paste("Bearer", token))
  tryCatch({
    con <- url(paste0("https://api.github.com/", endpoint), headers = headers)
    on.exit(close(con), add = TRUE)
    jsonlite::fromJSON(paste(readLines(con, warn = FALSE), collapse = "\n"),
                       simplifyVector = FALSE)
  }, error = function(e) NULL, warning = function(w) NULL)
}

# Where the files of a brand repository are read from at a ref.
brand_base_url <- function(repo, ref) {
  paste0("https://raw.githubusercontent.com/", repo, "/", ref)
}

# Record the installed ref in Config/washr/brand, so the package says which
# brand it carries. Returns the ref recorded before, or NULL.
record_brand_ref <- function(ref) {
  if (is.null(ref) || !file.exists("DESCRIPTION")) return(NULL)
  previous <- washr_config("brand")
  if (!identical(previous, ref)) desc::desc_set("Config/washr/brand", ref)
  previous
}

# Keep the brand files out of the built package (#133). R CMD check lists
# them as non-standard top-level files otherwise. The directory names come
# from the logo paths, in case the brand repository moves the files.
ignore_brand_files <- function(logo_paths) {
  if (!file.exists("DESCRIPTION")) return(invisible(FALSE))
  top <- vapply(strsplit(logo_paths, "/", fixed = TRUE), `[[`, character(1), 1L)
  usethis::use_build_ignore(unique(c("_brand.yml", top)))
  invisible(TRUE)
}

# Download or copy one brand file into a tempfile.
fetch_brand_file <- function(base, path, repo = NULL, ref = NULL) {
  tmp <- tempfile()
  if (dir.exists(base)) {
    src <- file.path(base, path)
    if (!file.exists(src)) {
      cli::cli_abort("Brand source file not found: {.path {src}}")
    }
    file.copy(src, tmp)
  } else {
    url <- paste(base, path, sep = "/")
    ok <- tryCatch(
      {
        utils::download.file(url, tmp, quiet = TRUE, mode = "wb")
        TRUE
      },
      error = function(e) FALSE,
      warning = function(w) FALSE
    )
    if (!ok) {
      where <- if (is.null(repo)) "the source" else repo
      at <- if (is.null(ref)) "" else paste0(" at the ref ", encodeString(ref, quote = '"'))
      cli::cli_abort(c(
        "Could not download {.url {url}}.",
        "i" = "Check the network connection and that {where} carries the file{at}."
      ))
    }
  }
  tmp
}

# Write a fetched file to its destination when new or changed; report and
# return the destination path, or an empty vector when unchanged.
place_brand_file <- function(tmp, dest) {
  destdir <- dirname(dest)
  if (destdir != "." && !dir.exists(destdir)) {
    dir.create(destdir, recursive = TRUE)
  }
  status <- if (!file.exists(dest)) {
    "written"
  } else if (identical(
    unname(tools::md5sum(tmp)), unname(tools::md5sum(dest))
  )) {
    "unchanged"
  } else {
    "updated"
  }
  if (status == "unchanged") {
    return(character(0))
  }
  file.copy(tmp, dest, overwrite = TRUE)
  ui_done("{.path {dest}} {status}.")
  dest
}

# The package logo from the brand: the image the brand names as its small
# logo goes to man/figures/logo.png, where pkgdown shows it beside the
# title of the home page and GitHub renders it from the README; the
# counterpart the brand names as "<image>-dark" goes to
# pkgdown/assets/logo-dark.png, shown on the dark theme of the site by the
# one rule in pkgdown/extra.css. Nothing is written when the brand names
# no small logo. Returns the files written or updated.
install_package_logo <- function(brand) {
  entry <- brand_logo_entry(brand, "small")
  if (is.null(entry) || !file.exists(entry$path)) return(character(0))
  changed <- place_brand_file(entry$path, file.path("man", "figures", "logo.png"))
  dark <- brand_logo_entry(brand, "small", dark = TRUE)
  if (!is.null(dark) && file.exists(dark$path)) {
    changed <- c(changed, place_brand_file(dark$path, file.path("pkgdown", "assets", "logo-dark.png")))
    changed <- c(changed, write_logo_css())
    if (file.exists("DESCRIPTION")) usethis::use_build_ignore("pkgdown")
  }
  c(changed, add_readme_logo())
}

# The image a brand names for a size ("small", "medium" or "large"): a list
# with the path and the alt text, or NULL. With dark = TRUE, the image the
# brand names as the dark counterpart ("<image>-dark"), or NULL.
brand_logo_entry <- function(brand, size, dark = FALSE) {
  logo <- brand$logo
  if (is.null(logo) || is.null(logo[[size]])) return(NULL)
  key <- logo[[size]]
  name <- if (is.character(key) && length(key) == 1 && !is.null(logo$images[[key]])) key else NULL
  entry <- if (dark) {
    if (is.null(name)) NULL else logo$images[[paste0(name, "-dark")]]
  } else if (is.null(name)) {
    key
  } else {
    logo$images[[name]]
  }
  if (is.null(entry)) return(NULL)
  if (is.list(entry)) {
    list(path = entry$path, alt = if (is.null(entry$alt)) "" else entry$alt)
  } else {
    list(path = entry, alt = "")
  }
}

# The rule that shows the dark counterpart of the logo on the dark theme of
# the site. pkgdown includes pkgdown/extra.css on every page and copies
# pkgdown/assets to the root of the site; its light switch sets
# data-bs-theme on the page. Written once, kept as it is after.
write_logo_css <- function() {
  path <- file.path("pkgdown", "extra.css")
  marker <- "/* washr: the brand logo on the dark theme */"
  lines <- if (file.exists(path)) readLines(path, warn = FALSE) else character(0)
  if (any(lines == marker)) return(character(0))
  dir.create("pkgdown", showWarnings = FALSE)
  rule <- c(marker, '[data-bs-theme="dark"] img.logo { content: url("logo-dark.png"); }')
  writeLines(c(lines, if (length(lines)) "", rule), path)
  ui_done("{.path {path}} shows the dark logo on the dark theme of the site.")
  path
}

# The logo at the title of README.Rmd, so GitHub shows it; pkgdown shows
# its own slot logo once and drops the duplicate from the title. The title
# is the first level one heading outside a code fence. A title that already
# carries an image is left alone. Returns the file when it changed.
add_readme_logo <- function() {
  path <- "README.Rmd"
  if (!file.exists(path)) return(character(0))
  lines <- readLines(path, warn = FALSE)
  title <- readme_title_line(lines)
  if (is.na(title) || grepl("<img", lines[title], fixed = TRUE)) return(character(0))
  lines[title] <- paste(lines[title], readme_logo_html())
  writeLines(lines, path)
  ui_done("{.path {path}} shows the logo at the title; rebuild the README with {.code devtools::build_readme()}.")
  path
}

# The index of the first level one heading outside a code fence, or NA.
readme_title_line <- function(lines) {
  fence <- FALSE
  for (i in seq_along(lines)) {
    if (grepl("^\\s*```", lines[i])) fence <- !fence
    if (!fence && grepl("^# ", lines[i])) return(i)
  }
  NA_integer_
}

# The image tag of the logo for the title of the README, linked to the
# website of the organisation when DESCRIPTION names one. The alt text is
# the name the brand gives itself, else the organisation.
readme_logo_html <- function(file = ".") {
  brand_file <- file.path(file, "_brand.yml")
  brand <- if (file.exists(brand_file)) tryCatch(yaml::read_yaml(brand_file), error = function(e) NULL) else NULL
  alt <- brand$meta$name
  if (is.null(alt) || !nzchar(alt)) alt <- pkg_org(file)
  img <- sprintf('<img src="man/figures/logo.png" align="right" width="120" alt="%s" />', alt)
  home <- if (file.exists(file.path(file, "DESCRIPTION"))) pkg_config("home", file) else "none"
  if (is_set(home)) sprintf('<a href="%s">%s</a>', home, img) else img
}

# The site build needs the brand.yml package once _pkgdown.yml is wired to
# the brand; listed in Config/Needs/website so the pkgdown workflow installs
# it (#143). Returns DESCRIPTION when the field changed.
need_brand_yml <- function() {
  needs <- desc::desc_get_field("Config/Needs/website", default = "")
  needs <- setdiff(trimws(strsplit(needs, ",")[[1]]), "")
  if ("brand.yml" %in% needs) return(character(0))
  desc::desc_set("Config/Needs/website", paste(c(needs, "brand.yml"), collapse = ", "))
  ui_done("{.field Config/Needs/website} lists brand.yml, which the branded site build needs.")
  "DESCRIPTION"
}

# The logo paths a brand definition references: the named images plus any
# size entries that are direct paths rather than image names. An entry is
# either a path or, since openwashdata/brand 1.0.0, a list with a path and
# an alt text.
brand_logo_paths <- function(brand) {
  logo <- brand$logo
  if (is.null(logo)) {
    return(character(0))
  }
  as_path <- function(entry) {
    if (is.list(entry)) entry$path else entry
  }
  images <- vapply(logo$images, as_path, character(1), USE.NAMES = FALSE)
  sizes <- vapply(
    logo[setdiff(names(logo), "images")], as_path, character(1),
    USE.NAMES = FALSE
  )
  direct <- setdiff(sizes, names(logo$images))
  unique(c(images, direct))
}

# The lines of _pkgdown.yml with the brand wiring added as text, so comments
# and long values stay as they were written. A rewrite through the yaml
# package drops the comments and folds long lines, which broke the verbatim
# funding text that the review standard looks for. Returns NULL when the
# layout does not allow a safe line edit (a template block that already
# carries bslib settings, or a result that does not parse to `wired`); the
# caller then falls back to the yaml rewrite.
insert_brand_lines <- function(lines, config, wired) {
  if (!is.null(config$template$bslib)) return(NULL)
  top <- grep("^template:\\s*(#.*)?$", lines)
  if (length(top) > 1) return(NULL)
  if (length(top) == 0) {
    if (!is.null(config$template)) return(NULL)
    out <- c(lines, "template:", "  bootstrap: 5", "  bslib:", "    brand: _brand.yml")
  } else {
    after <- lines[seq_along(lines) > top]
    child <- after[grepl("^\\s+[^#[:space:]]", after)][1]
    indent <- if (is.na(child)) "  " else sub("^(\\s+).*$", "\\1", child)
    add <- c(paste0(indent, "bslib:"), paste0(indent, indent, "brand: _brand.yml"))
    if (is.null(config$template$bootstrap)) {
      add <- c(paste0(indent, "bootstrap: 5"), add)
    }
    out <- append(lines, add, after = top)
  }
  parsed <- tryCatch(yaml::yaml.load(paste(out, collapse = "\n")), error = function(e) NULL)
  if (!identical(sort_keys(parsed), sort_keys(wired))) return(NULL)
  out
}

# A nested list with its named levels in alphabetical order, so two parsed
# YAML documents compare equal whatever the order of their keys.
sort_keys <- function(x) {
  if (!is.list(x)) return(x)
  if (!is.null(names(x))) x <- x[order(names(x))]
  lapply(x, sort_keys)
}

# Set the Open Graph image of the site to the social preview of the brand
# repository at the installed ref, when the repository has one (#145). A
# shared link to the site then shows the image of the organisation. Returns
# the config path when it changed, or an empty vector.
wire_pkgdown_opengraph <- function(repo, ref) {
  configpath <- "_pkgdown.yml"
  if (!file.exists(configpath) || !file.exists("_brand.yml")) return(character(0))
  image <- brand_social_preview(repo, ref)
  if (!url_exists(image$src)) {
    ui_info("{repo} has no {.path assets/social-preview.png} at {.val {ref}}; the Open Graph image stays as it is.")
    return(character(0))
  }
  lines <- readLines(configpath, warn = FALSE)
  result <- pkgdown_update_opengraph(lines, image, yaml_indent_unit(lines))
  if (!isTRUE(result$changed)) return(character(0))
  parsed <- tryCatch(yaml::yaml.load(paste(result$lines, collapse = "\n")), error = function(e) NULL)
  if (is.null(parsed)) {
    ui_info("The Open Graph image could not be added to {.path {configpath}} line by line; add template.opengraph.image by hand.")
    return(character(0))
  }
  writeLines(result$lines, configpath)
  ui_done("{.path {configpath}} shows the social preview of the brand when a link to the site is shared.")
  configpath
}

# Point an existing _pkgdown.yml at the brand through bslib. Returns the
# config path when it changed, or an empty vector.
wire_pkgdown_brand <- function() {
  configpath <- "_pkgdown.yml"
  if (!file.exists(configpath)) {
    ui_info("No _pkgdown.yml found; skipping the pkgdown wiring.")
    ui_todo("Run {.fun setup_website} first, then {.fun use_brand} again.")
    return(character(0))
  }
  config <- yaml::read_yaml(configpath)
  if (identical(config$template$bslib$brand, "_brand.yml")) {
    return(character(0))
  }
  wired <- config
  wired$template$bslib$brand <- "_brand.yml"
  if (is.null(wired$template$bootstrap)) {
    wired$template$bootstrap <- 5L
  }
  lines <- insert_brand_lines(readLines(configpath, warn = FALSE), config, wired)
  if (is.null(lines)) {
    yaml::write_yaml(wired, configpath)
  } else {
    writeLines(lines, configpath)
  }
  ui_done("{.path {configpath}} wired to the brand via bslib.")
  ui_todo("Rebuild the site with {.code pkgdown::build_site()} to apply the brand.")
  configpath
}
