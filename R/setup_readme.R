#' Generate the README RMarkdown file
#'
#' @description
#' `setup_readme()` uses the openwashdata README template to generate README files based on datasets
#' retrieved from the `data/` directory. It helps in creating consistent and informative README documentation
#' for your data packages. The repository links, the install line and the
#' license come from DESCRIPTION, so run [update_description()] first.
#'
#' The Citation section names the publisher with its website, states in
#' plain text which version to cite with which DOI, links the authors page
#' of the site and `CITATION.cff`, and names the source article of
#' republished data from `X-schema.org-isBasedOn`. When the package names its
#' site (the `url` of `_pkgdown.yml` or a site entry in the DESCRIPTION
#' `URL` field), the section also links `metadata.jsonld` on the site, the
#' schema.org metadata that [update_metadata()] writes, so the link reaches
#' the `llms.txt` of the site. When [use_brand()] has
#' installed the logo (`man/figures/logo.png`), the title line shows it,
#' linked to the website of the organisation. The download links point at the release tag of
#' the version in DESCRIPTION, and at the main branch for a development
#' version. pkgdown builds the `llms.txt` of the site from the README, so
#' this is also what AI tools read about the package.
#'
#' The Data section has one section per data object: a preview of the first
#' rows and the table of its variables from `data-raw/dictionary.csv`. Without
#' `datasets`, every data object in `data/` gets a section, in alphabetical
#' order. With several objects the introduction of the Data section names
#' their number. The Example section, with `has_example = TRUE`, starts from
#' the first object. An object without rows in the dictionary gets a warning,
#' because its table of variables would be empty. The function stops when
#' `data/` holds no data object, because every data section needs one.
#'
#' @param force Logical. If FALSE (the default), the function stops when a
#' README.Rmd already exists. Set to TRUE to overwrite the existing file.
#' @param has_example Logical. Should the README include an Example section
#'   with a commented ggplot2 scaffold for a first plot of the data? Defaults
#'   to FALSE. Pairs with the `has_example` argument of [setup_website()],
#'   which adds the matching article to the site.
#' @param datasets Character vector. The data objects in `data/` that get a
#'   section, in this order, such as `c("trips", "trucks")`. The default
#'   `NULL` takes every data object in `data/`, alphabetically. A name that is
#'   not a data object in `data/` stops the run.
#'
#' @returns The path of README.Rmd, invisibly.
#'
#' @seealso Before: [update_description()]. Next: [setup_website()], which builds the site from README.md.
#'
#' @family publishing functions
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Generate the README file after setting up the dictionary
#' setup_dictionary()
#' # Complete and save the dictionary CSV file with variable descriptions
#' setup_readme()
#' # With an Example section to fill with a first plot
#' setup_readme(has_example = TRUE)
#' # Sections for two of the data objects only
#' setup_readme(datasets = c("trips", "trucks"))
#' }
setup_readme <- function(force = FALSE, has_example = FALSE, datasets = NULL){
  local_session()
  # Get metadata
  readmermd_path <- file.path("README.Rmd")
  if (file.exists(readmermd_path) && !force) {
    cli::cli_abort(c(
      "{.path README.Rmd} already exists.",
      "i" = "Call {.code setup_readme(force = TRUE)} to overwrite it."
    ))
  }
  pkgname <- desc::desc_get("Package")[[1]]
  available <- sort(dataset_names())
  if (length(available) == 0) {
    cli::cli_abort(c(
      "No data object found in {.path data/}.",
      "i" = "Export the tidy data with {.fun usethis::use_data} first. The README documents it."
    ))
  }
  if (is.null(datasets)) {
    datasets <- available
  } else {
    unknown <- setdiff(datasets, available)
    if (!is.character(datasets) || length(datasets) == 0 || length(unknown)) {
      cli::cli_abort(c(
        "{.arg datasets} names {cli::qty(length(unknown))}{?an object/objects} that {.path data/} does not hold: {.val {unknown}}.",
        "i" = "{.path data/} holds {.val {available}}."
      ))
    }
    datasets <- unique(datasets)
  }
  # Only now, with everything in place for the new file, the old one goes
  if (file.exists(readmermd_path)) file.remove(readmermd_path)
  warn_undocumented_datasets(datasets)
  # Create README RMarkdown with a template
  usethis::use_readme_rmd(open = FALSE)
  file.remove(readmermd_path)
  usethis::use_template(template = "README.Rmd",
                        save_as = readmermd_path,
                        data = c(list(packagename = pkgname,
                                      dataname = datasets[[1]],
                                      datasets = lapply(datasets, function(x) list(dataname = x)),
                                      multiple = length(datasets) > 1,
                                      n_datasets = length(datasets),
                                      has_example = has_example),
                                 readme_template_data()),
                        open = rlang::is_interactive(),
                        package = "washr")
  ui_todo("Finish writing {.path {readmermd_path}}, then run {.code devtools::build_readme()}.")
  invisible(readmermd_path)
}

# Warn about the data objects without a row in data-raw/dictionary.csv: their
# table of variables in the README would be empty (#103).
warn_undocumented_datasets <- function(datasets, path = ".") {
  dict_path <- file.path(path, "data-raw", "dictionary.csv")
  documented <- character()
  if (file.exists(dict_path)) {
    dictionary <- tryCatch(utils::read.csv(dict_path, stringsAsFactors = FALSE),
                           error = function(e) NULL)
    if (is.data.frame(dictionary) && "file_name" %in% names(dictionary)) {
      documented <- tools::file_path_sans_ext(dictionary$file_name)
    }
  }
  missing <- setdiff(datasets, documented)
  if (length(missing)) {
    ui_warn("{.val {missing}} ha{?s/ve} no rows in {.path data-raw/dictionary.csv}; the table of variables in the README stays empty. Run {.fun setup_dictionary} or {.fun update_dictionary} first.")
  }
  invisible(missing)
}

# The repository, site, license and publisher values of the README template,
# read from DESCRIPTION (#81). The site URL links the authors page in the
# Citation section (#137), where the website of the organisation names the
# publisher (#145); the logo that use_brand() installed is shown at the
# title. CC BY 4.0, the license update_description() sets, keeps
# the badge and the label the template has always carried.
readme_template_data <- function(file = ".") {
  repo <- pkg_repo_url(file)
  license <- license_key(desc::desc_get_field("License", default = "", file = file))
  if (identical(license, "") || grepl("use_mit_license", license, fixed = TRUE)) {
    license <- "CC BY 4.0"
  }
  if (identical(license, "CC BY 4.0")) {
    badge <- paste0("[![License: CC BY\n4.0](https://img.shields.io/badge/License-CC_BY_4.0-lightgrey.svg)]",
                    "(https://creativecommons.org/licenses/by/4.0/)")
    label <- "CC-BY"
  } else {
    shield <- gsub(" ", "_", gsub("_", "__", gsub("-", "--", license, fixed = TRUE), fixed = TRUE), fixed = TRUE)
    target <- license_url(license)
    if (identical(target, license)) target <- paste0(repo, "/blob/main/LICENSE.md")
    badge <- sprintf("[![License: %s](https://img.shields.io/badge/License-%s-lightgrey.svg)](%s)",
                     license, utils::URLencode(shield, reserved = TRUE), target)
    label <- license
  }
  home <- pkg_config("home", file)
  has_logo <- file.exists(file.path(file, "man", "figures", "logo.png"))
  list(
    repo_url = repo,
    pages_url = pkg_pages_url(file),
    has_pages = !is.null(pkg_site_url(file)),
    repo_slug = sub("^https?://github\\.com/", "", repo),
    license_badge = badge,
    license_label = label,
    org = pkg_org(file),
    has_home = is_set(home),
    home = if (is_set(home)) home,
    has_logo = has_logo,
    logo_html = if (has_logo) readme_logo_html(file)
  )
}
