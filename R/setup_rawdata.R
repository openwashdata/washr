#' Create the data-raw directory with a data-processing.R template
#'
#' @description
#' `setup_rawdata()` creates a directory for raw data and an example script
#' named `data_processing.R` for importing, processing and exporting the tidy data.
#' The template assumes that the dataset name is the same as the data package name.
#'
#' @seealso Before: [setup_ci()]. Next: [setup_dictionary()] once the processing script has exported the tidy data with `usethis::use_data()`.
#'
#' @family setup functions
#'
#' @export
#'
#' @returns The path of the processing script, invisibly. The function creates
#'   the directory "data-raw" under the package directory.
#'
#' @examples
#' \dontrun{
#'   setup_rawdata()
#' }
#'
setup_rawdata <- function(){
  check_pkg_root()
  local_quiet()
  usethis::use_directory("data-raw", ignore = TRUE)
  r_path <- file.path("data-raw", "data_processing.R")
  name <- basename(getwd())
  usethis::use_template(
    "data_processing.R",
    save_as = r_path,
    data = list(name = name),
    ignore = FALSE,
    open = rlang::is_interactive(),
    package = "washr"
  )
  invisible(r_path)
}
