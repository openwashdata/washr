#' Create a dictionary file for tidy data sets
#'
#' @description
#' `setup_dictionary()` generates a dictionary CSV file in the
#' `data/` directory. The dictionary file
#' contains information on the tidy data sets such as directory, file names, variable names,
#' variable types, and descriptions. If tidy data exists, the dictionary is populated with
#' relevant information; otherwise, it creates an empty dictionary CSV file.
#'
#' @seealso Before: [setup_rawdata()]. Next: [setup_roxygen()] once the descriptions in `data-raw/dictionary.csv` are written.
#'
#' @family setup functions
#'
#' @export
#'
#' @returns The path of the dictionary file, invisibly. Error if raw data is
#'   not found or not in a package directory.
#'
#' @examples
#' \dontrun{
#' setup_rawdata()
#' # Go to data_processing.R, clean the raw data and export tidy data
#' setup_dictionary()
#' }
#'
setup_dictionary <- function() {
  # Check working directory
  check_pkg_root()
  if (!dir.exists(file.path(getwd(), "data-raw"))) {
    cli::cli_abort(c(
      "You have not set up the raw data.",
      "i" = "Run {.fun setup_rawdata} and import the raw data files first."
    ))
  }
  # Check dictionary csvfile existence
  dict_path <- file.path("data-raw", "dictionary.csv")
  if (!no_dict(dict_path)) {
    cli::cli_abort("The dictionary CSV file {.path {dict_path}} already exists!")
  }
  fill_dictionary(dict_path, "data/")
  invisible(dict_path)
}

#' Fill in the dictionary file based on the tidy data information
#'
#' @param dict_path Path to the dictionary csvfile.
#' @param data_dir Path to the directory of the tidy R data objects. Defaults to data/
#'
#' @returns A tibble data frame of dataset dictionary with an empty description column to be written.
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' fill_dictionary(dict_path = "data-raw/dictionary.csv", data_dir = "data/")
#' }
#'
fill_dictionary <- function(dict_path, data_dir){
  # Collect tidy data information
  if(dir.exists(data_dir)){
    tidydata_info <- collect_tidydata_info(data_dir)
  } else {
    # Error because tidy data is not yet available, should complete that first
    cli::cli_abort(c(
      "There is no tidy data available.",
      "i" = "Store the tidy data as an R data object with {.fun usethis::use_data} first."
    ))
  }
  # Fill in dictionary
  dictionary <- data.frame(directory = data_dir,
                               file_name = tidydata_info$file_name,
                               variable_name = tidydata_info$var_name,
                               variable_type = tidydata_info$var_type,
                               description = NA)
  # Export dictionary
  utils::write.csv(x = dictionary, file = dict_path, na = "", row.names = FALSE)
  # Prompt to complete variable description
  ui_done("Wrote {.path {dict_path}}")
  ui_todo("Write the variable descriptions in {.path {dict_path}}.")
  return(dictionary)
  }

no_dict <- function(dict_path) {
  if(file.exists(dict_path)) {
    return(FALSE)
  } else {
    return(TRUE)
  }
}

create_empty_dict <- function(dict_path){
  file.create(dict_path)
  writeLines(text = "directory,file_name,variable_name,variable_type,description",
             con = dict_path)
}

collect_tidydata_info <- function(data_dir){
  tidy_data_names <- list.files(data_dir)
  file_name <- c()
  var_name <- c()
  var_type <- c()
  for (d in tidy_data_names){
    tidydata <- load_object(file.path(data_dir, d)) # Read in tidy dataset(s)
    file_name <- c(file_name, rep(d, ncol(tidydata)))
    var_name <-c(var_name, colnames(tidydata))
    var_type <- c(var_type, vapply(tidydata, function(x) class(x)[1], character(1)))
  }
  var_type <- as.character(var_type)
  return(data.frame(file_name, var_name, var_type))
}
