#' Set up roxygen documentation for all tidy data sets using the dictionary
#'
#' @description
#' Creates or updates Roxygen documentation for all tidy data sets found
#' in the dictionary file.
#'
#' When first run, this function creates the Roxygen documentation with placeholders
#' for the title and description field. The dictionary should include columns for
#' directory, file name, variable name, variable type, and description. This
#' function generates Roxygen comments with this information, facilitating
#' consistent and thorough documentation for your data sets.
#'
#' When re-run this function, this function updates only the variable description entries
#' in the Roxygen documentation files within R/ directory. The title and description fields remain
#' unchanged.
#'
#' @returns NULL. This function creates documentation files inside "R/". Error if
#' tidy data cannot be found.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' setup_dictionary()
#' # Once the dictionary is created, go to data-raw/dictionary.csv and complete the column description.
#' setup_roxygen()
#' }
#'
setup_roxygen <- function() {
  # Check dictionary existence
  input_file_path <- file.path(getwd(), "data-raw", "dictionary.csv")
  if (!file.exists(input_file_path)) {
    usethis::ui_stop("Data dictionary does not exist in the data-raw/ directory. Please set up the raw data or create a dictionary first.")
  }
  # Check R/ existence
  output_file_dir <- file.path(getwd(), "R")
  if (!dir.exists(output_file_dir)) {
    usethis::use_r(open = FALSE)
  }
  # Check data/ existence
  tidy_datasets <- list.files(path = file.path(getwd(), "data"))
  num_tidy_datasets <- length(tidy_datasets)
  # Write roxygen doc for each tidy dataset
  if (num_tidy_datasets == 0){
    usethis::ui_stop("No tidy data sets are available in the data/ directory.
                     Please complete data processing and export tidy data first.")
  } else {
    for (d in tidy_datasets){
      # Update output_file_path to have the same name as df_name with .R extension
      df_name <- strsplit(basename(file.path(d)), ".rda", fixed = TRUE)[[1]]
      output_file_path <- file.path(output_file_dir, paste0(df_name, ".R"))
      generate_roxygen_docs(input_file_path = input_file_path,
                            output_file_path = output_file_path,
                            df_name = df_name)
      usethis::ui_todo("Please write the title and description for \n {usethis::ui_value(output_file_path)}")
    }
  }
}

#' Generate roxygen2 documentation from a CSV file
#'
#' This function takes a CSV table with columns `variable_name` and `description` as input,
#' optionally filters it by `variable_name`, and outputs roxygen2 documentation for `\describe` and `\item`.
#'
#' @param input_file_path Path to the input CSV file.
#' @param output_file_path Path to the output file that will contain the roxygen2 documentation.
#' @param df_name Optional name of the variable to filter the input dataframe by. Default is NULL.
#'
#' @returns Character string of a generated roxygen documentation.
#'
#' @keywords internal
#'
#' @examples \dontrun{
#' # Generate roxygen2 documentation from example.csv
#' generate_roxygen_docs("example.csv", "output.R")
#' # Generate roxygen2 documentation from example.csv for a specific variable name
#' generate_roxygen_docs("example.csv", "output.R", df_name = "specific_variable")
#' }
#'
generate_roxygen_docs <- function(input_file_path, output_file_path, df_name=NULL){
  dict <- utils::read.csv(input_file_path)
  dict <- subset(dict, dict$file_name == paste0(df_name, ".rda"))
  if (nrow(dict) == 0) {
    usethis::ui_stop("The dictionary has no rows for {usethis::ui_value(paste0(df_name, '.rda'))}. Update data-raw/dictionary.csv first.")
  }
  body <- create_roxygen_body(dict)
  label <- paste0('"', df_name, '"')
  if (file.exists(output_file_path)) {
    # Re-run: regenerate only the @format block; the title and description
    # above it and anything below it (e.g., @source, @examples) are kept
    parts <- split_roxygen_file(output_file_path, df_name)
    output <- c(parts$head, body, parts$tail, label)
    current <- readLines(output_file_path, warn = FALSE)
  } else {
    output <- c(create_roxygen_head(df_name), body, label)
    current <- NULL
  }
  if (!identical(current, output)) writeLines(output, output_file_path)
  return(output)
}

create_roxygen_head <- function(df_name) {
  # Create title and description
  roxygen_head <- c(paste0("#' ", df_name, ": Title goes here"),
              "#' ",
              "#' Description of the data goes here...",
              "#' ")
  return(roxygen_head)
}

# Split an existing roxygen file into the lines before the @format block
# (title, description, other tags) and the lines after the block's closing
# "#' }" up to the dataset label. Errors when no @format line exists.
split_roxygen_file <- function(roxygen_file_path, df_name){
  lines <- readLines(roxygen_file_path, warn = FALSE)
  fmt <- which(startsWith(lines, "#' @format"))
  if (length(fmt) == 0) {
    usethis::ui_stop("{usethis::ui_path(roxygen_file_path)} has no {usethis::ui_code(\"#' @format\")} line, so the generated block cannot be told from your text. Add the line back, or delete the file and run setup_roxygen() again.")
  }
  fmt <- fmt[1]
  closing <- which(trimws(lines) == "#' }")
  closing <- closing[closing > fmt]
  end <- if (length(closing)) closing[1] else fmt
  tail <- if (end < length(lines)) lines[(end + 1):length(lines)] else character()
  tail <- tail[trimws(tail) != paste0('"', df_name, '"')]
  list(head = lines[seq_len(fmt - 1)], tail = tail)
}

create_roxygen_body <- function(dict){
  # Create format line
  dataobj <- file.path("data", dict$file_name[1])
  n_rows <- nrow(load_object(dataobj)) #TODO: Load the data object
  n_vars <- nrow(dict)
  format_line <- paste0("#' @format A tibble with ", n_rows," rows and ", n_vars," variables")

  # Create \describe block
  block <- create_describe_block(dict)
  output <- c(format_line, block)
  return(output)
}

create_describe_block <- function(dict){
  block <- character()
  block <- c(block, paste0("#' ", "\\describe{"))

  # Iterate over input rows and create \item blocks
  for (i in seq_len(nrow(dict))) {
    variable_name <- dict[i, "variable_name"]
    description <- dict[i, "description"]

    # Create \item block
    item <- paste0("#'   ", "\\item{", variable_name, "}{", description, "}")

    # Append to output
    block <- c(block, item)
  }

  # Close \describe block
  block <- c(block, "#' }")
  return(block)
}
