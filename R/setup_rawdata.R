#' Create the data-raw directory with a data-processing.R template
#'
#' @description
#' `setup_rawdata()` creates a directory for raw data and an example script
#' named `data_processing.R` for importing, processing and exporting the tidy data.
#' The export block of the script writes one `usethis::use_data()` line per
#' dataset and then exports each dataset to `inst/extdata` as CSV and XLSX in
#' one loop over the names, for a single dataset as well. Without `datasets`,
#' the one dataset is named after the package.
#'
#' @param datasets Character vector of the names of the tidy data objects the
#'   script exports, such as `c("trips", "trucks")`. The default `NULL` names
#'   one dataset after the package. Each name has to be a syntactically valid
#'   R name (`make.names(x) == x`), because it becomes an object in the
#'   script; the function stops otherwise. `data/` is not read: the names are
#'   the objects the script is about to create.
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
#'   # A package with two datasets
#'   setup_rawdata(datasets = c("trips", "trucks"))
#' }
#'
setup_rawdata <- function(datasets = NULL){
  check_pkg_root()
  if (is.null(datasets)) datasets <- basename(getwd())
  check_dataset_names(datasets)
  local_session()
  usethis::use_directory("data-raw", ignore = TRUE)
  r_path <- file.path("data-raw", "data_processing.R")
  usethis::use_template(
    "data_processing.R",
    save_as = r_path,
    data = list(datasets = lapply(datasets, function(x) list(name = x)),
                dataset_vector = paste0('"', datasets, '"', collapse = ", ")),
    ignore = FALSE,
    open = rlang::is_interactive(),
    package = "washr"
  )
  invisible(r_path)
}

# Stop unless `datasets` is a character vector of syntactically valid R
# names, without duplicates, as the processing script needs them (#103).
check_dataset_names <- function(datasets, call = rlang::caller_env()) {
  if (!is.character(datasets) || length(datasets) == 0 || anyNA(datasets)) {
    cli::cli_abort("{.arg datasets} must be a character vector of data object names.",
                   call = call)
  }
  invalid <- datasets[make.names(datasets) != datasets]
  if (length(invalid)) {
    cli::cli_abort(c(
      "{.arg datasets} holds {length(invalid)} name{?s} that {?is/are} not a valid R name: {.val {invalid}}.",
      "i" = "Use letters, digits, dots and underscores, starting with a letter, such as {.val {make.names(invalid)}}."
    ), call = call)
  }
  dup <- unique(datasets[duplicated(datasets)])
  if (length(dup)) {
    cli::cli_abort("{.arg datasets} names {.val {dup}} more than once.", call = call)
  }
  invisible(datasets)
}
