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
#' openwashdata/brand first, then refresh consumers with `use_brand()`.
#'
#' @details
#' With `pkgdown = TRUE` (the default), an existing `_pkgdown.yml` is
#' pointed at the brand through bslib (`template.bslib.brand`), so the
#' next [pkgdown::build_site()] renders the site with the brand fonts
#' and colors. The wiring rewrites `_pkgdown.yml` through the yaml
#' package, which does not preserve comments in that file. When no
#' `_pkgdown.yml` exists, the wiring is skipped with a hint to run
#' [setup_website()] first. Building the wired site requires the
#' brand.yml package (bslib asks for it at build time); it is listed in
#' Suggests and installed on demand.
#'
#' @param ref Character. Git reference (branch or tag) of
#'   openwashdata/brand to copy from. Defaults to `"main"`.
#' @param pkgdown Logical. Should `_pkgdown.yml` be wired to use the
#'   brand via bslib? Defaults to `TRUE`.
#' @param source Character. Advanced: an alternative source for the
#'   brand files, either a local directory or a URL prefix. When `NULL`
#'   (the default), the raw GitHub content of openwashdata/brand at
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
use_brand <- function(ref = "main", pkgdown = TRUE, source = NULL) {
  if (is.null(source)) {
    source <- paste0(
      "https://raw.githubusercontent.com/openwashdata/brand/", ref
    )
  }

  changed <- character(0)

  # The brand definition itself.
  brand_tmp <- fetch_brand_file(source, "_brand.yml")
  changed <- c(changed, place_brand_file(brand_tmp, "_brand.yml"))

  # The logo files the brand definition references.
  brand <- yaml::read_yaml("_brand.yml")
  for (path in brand_logo_paths(brand)) {
    fetched <- fetch_brand_file(source, path)
    changed <- c(changed, place_brand_file(fetched, path))
  }

  if (isTRUE(pkgdown)) {
    changed <- c(changed, wire_pkgdown_brand())
  }

  if (length(changed) == 0) {
    usethis::ui_done("Brand is up to date; nothing to change.")
  }
  invisible(changed)
}

# Download or copy one brand file into a tempfile.
fetch_brand_file <- function(base, path) {
  tmp <- tempfile()
  if (dir.exists(base)) {
    src <- file.path(base, path)
    if (!file.exists(src)) {
      usethis::ui_stop("Brand source file not found: {src}")
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
      usethis::ui_stop(
        "Could not download {url}. Check the network connection and that openwashdata/brand carries the file on this ref."
      )
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
  usethis::ui_done("{usethis::ui_path(dest)} {status}.")
  dest
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

# Point an existing _pkgdown.yml at the brand through bslib. Returns the
# config path when it changed, or an empty vector.
wire_pkgdown_brand <- function() {
  configpath <- "_pkgdown.yml"
  if (!file.exists(configpath)) {
    usethis::ui_info(
      "No _pkgdown.yml found; skipping the pkgdown wiring. Run washr::setup_website() first, then use_brand() again."
    )
    return(character(0))
  }
  config <- yaml::read_yaml(configpath)
  if (identical(config$template$bslib$brand, "_brand.yml")) {
    return(character(0))
  }
  config$template$bslib$brand <- "_brand.yml"
  if (is.null(config$template$bootstrap)) {
    config$template$bootstrap <- 5
  }
  yaml::write_yaml(config, configpath)
  usethis::ui_done("{usethis::ui_path(configpath)} wired to the brand via bslib.")
  usethis::ui_info("Rebuild the site with pkgdown::build_site() to apply the brand.")
  configpath
}
