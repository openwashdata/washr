#' Generate the README RMarkdown file
#'
#' @description
#' `setup_readme()` uses the openwashdata README template to generate README files based on datasets
#' retrieved from the `data/` directory. It helps in creating consistent and informative README documentation
#' for your data packages.
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
#' @returns NULL. This function creates a README.Rmd under the package directory.
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
  # Get metadata
  readmermd_path <- file.path("README.Rmd")
  if (file.exists(readmermd_path)) {
    if (!force) {
      usethis::ui_stop("README.Rmd already exists.
                        Call setup_readme(force = TRUE) to overwrite it.")
    }
    file.remove(readmermd_path)
  }
  pkgname <- desc::desc_get("Package")[[1]]
  datasets <- dataset_names()
  if (length(datasets) == 0) {
    usethis::ui_stop("No data object found in data/. Export the tidy data with usethis::use_data() first; the README documents it.")
  }
  dataname <- datasets[[1]]
  if (length(datasets) > 1) {
    usethis::ui_info("data/ holds {length(datasets)} data objects; the template documents {usethis::ui_value(dataname)}. Add a section for each of the others.")
  }
  # Create README RMarkdown with a template
  usethis::use_readme_rmd(open = FALSE)
  file.remove(readmermd_path)
  usethis::use_template(template = "README.Rmd",
                        save_as = readmermd_path,
                        data = list(packagename = pkgname,
                                    dataname = dataname,
                                    has_example = has_example),
                        open = rlang::is_interactive(),
                        package = "washr")
  usethis::ui_todo("Finish the writing of README and run devtools::build_readme() in console.")
}
