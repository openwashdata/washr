#' Generate the README RMarkdown file
#'
#' @description
#' `setup_readme()` uses the openwashdata README template to generate README files based on datasets
#' retrieved from the `data/` directory. It helps in creating consistent and informative README documentation
#' for your data packages.
#'
#' @param force Logical. If FALSE (the default), the function stops when a
#' README.Rmd already exists. Set to TRUE to overwrite the existing file.
#'
#' @returns NULL. This function creates a README.Rmd under the package directory.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Generate the README file after setting up the dictionary
#' setup_dictionary()
#' # Complete and save the dictionary CSV file with variable descriptions
#' setup_readme()
#' }
setup_readme <- function(force = FALSE){
  # Get metadata
  readmermd_path <- file.path("README.Rmd")
  if (file.exists(readmermd_path)) {
    if (!force) {
      usethis::ui_stop("README.Rmd already exists.
                        Call setup_readme(force = TRUE) to overwrite it.")
    }
    file.remove(readmermd_path)
  }
  pkgname <- desc::desc_get("Package")
  dataname <- strsplit(basename(list.files("data")[1]), ".rda")[[1]]
  if (is.na(dataname)) {
    warning("No tidy data found. Please revise the section DATA in README!")
  }
  # Create README RMarkdown with a template
  usethis::use_readme_rmd(open = FALSE)
  file.remove(readmermd_path)
  usethis::use_template(template = "README.Rmd",
                        save_as = readmermd_path,
                        data = list(packagename = pkgname,
                                    dataname = dataname),
                        open = rlang::is_interactive(),
                        package = "washr")
  usethis::ui_todo("Finish the writing of README and run devtools::build_readme() in console.")
}
