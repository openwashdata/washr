#' Generate the README RMarkdown file
#'
#' @description
#' `setup_readme()` uses the openwashdata README template to generate README files based on datasets
#' retrieved from the `data/` directory. It helps in creating consistent and informative README documentation
#' for your data packages. The repository links, the install line and the
#' license come from DESCRIPTION, so run [update_description()] first.
#'
#' The template documents the first data object in `data/` (alphabetically);
#' add a section per further object by hand. It stops when `data/` holds no
#' data object, because every data section needs one.
#'
#' @param force Logical. If FALSE (the default), the function stops when a
#' README.Rmd already exists. Set to TRUE to overwrite the existing file.
#' @param has_example Logical. Should the README include an Example section
#'   with a commented ggplot2 scaffold for a first plot of the data? Defaults
#'   to FALSE. Pairs with the `has_example` argument of [setup_website()],
#'   which adds the matching article to the site.
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
#' }
setup_readme <- function(force = FALSE, has_example = FALSE){
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
  datasets <- dataset_names()
  if (length(datasets) == 0) {
    cli::cli_abort(c(
      "No data object found in {.path data/}.",
      "i" = "Export the tidy data with {.fun usethis::use_data} first. The README documents it."
    ))
  }
  # Only now, with everything in place for the new file, the old one goes
  if (file.exists(readmermd_path)) file.remove(readmermd_path)
  dataname <- datasets[[1]]
  if (length(datasets) > 1) {
    ui_info("data/ holds {length(datasets)} data objects; the template documents {.val {dataname}}. Add a section for each of the others.")
  }
  # Create README RMarkdown with a template
  usethis::use_readme_rmd(open = FALSE)
  file.remove(readmermd_path)
  usethis::use_template(template = "README.Rmd",
                        save_as = readmermd_path,
                        data = c(list(packagename = pkgname,
                                      dataname = dataname,
                                      has_example = has_example),
                                 readme_template_data()),
                        open = rlang::is_interactive(),
                        package = "washr")
  ui_todo("Finish writing {.path {readmermd_path}}, then run {.code devtools::build_readme()}.")
  invisible(readmermd_path)
}

# The repository and license values of the README template, read from
# DESCRIPTION (#81). CC BY 4.0, the license update_description() sets, keeps
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
  list(
    repo_url = repo,
    repo_slug = sub("^https?://github\\.com/", "", repo),
    license_badge = badge,
    license_label = label
  )
}
