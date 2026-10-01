#' Bring the dictionary in line with the tidy data
#'
#' @description
#' `update_dictionary()` reads the data objects in `data/` again and updates
#' `data-raw/dictionary.csv` to match them. Run it after the data changed:
#' a variable was added, removed or renamed, its type changed, or a data
#' object was added or removed.
#'
#' What you wrote in the dictionary is kept. Rows are matched on `file_name`
#' and `variable_name`, and a matched row keeps its description and the value
#' of every other column, including columns you added yourself, such as
#' `unit` or `allowed_values`. Only `variable_type` is refreshed from the
#' data. A new variable gets a row with empty cells to fill in. The row of a
#' variable that no longer exists is removed, and the function names it.
#' A renamed variable or data object cannot be told from one removed and one
#' added, so what you wrote in the removed rows is printed for you to copy
#' into the new rows.
#'
#' The columns keep the order they have in the file. The rows follow the
#' data: data objects in alphabetical order, variables in the order of the
#' data object. When nothing differs, the file is left untouched, so the
#' function is safe to run again.
#'
#' @returns The path of the dictionary file, invisibly. Error if there is no
#'   dictionary yet, no tidy data, or the dictionary lacks the `file_name` or
#'   `variable_name` column.
#'
#' @seealso Before: [setup_dictionary()], which writes the dictionary the
#'   first time. Next: [setup_roxygen()], which regenerates the variable
#'   table of the documentation from the dictionary.
#'
#' @family setup functions
#'
#' @export
#'
#' @examples
#' \dontrun{
#' setup_dictionary()
#' # Later, after data_processing.R exported changed data
#' update_dictionary()
#' setup_roxygen()
#' }
#'
update_dictionary <- function() {
  check_pkg_root()
  dict_path <- file.path("data-raw", "dictionary.csv")
  data_dir <- "data/"
  if (no_dict(dict_path)) {
    cli::cli_abort(c(
      "No dictionary found at {.path {dict_path}}.",
      "i" = "Run {.fun setup_dictionary} first. It writes the dictionary from the data."
    ))
  }
  if (length(dataset_names("data")) == 0) {
    cli::cli_abort(c(
      "There is no tidy data available.",
      "i" = "Store the tidy data as an R data object with {.fun usethis::use_data} first."
    ))
  }

  old <- read_dictionary_cells(dict_path)
  info <- collect_tidydata_info(data_dir)
  merged <- merge_dictionary(old, info, data_dir)
  new <- merged$dictionary

  changed <- !identical(names(old), names(new)) ||
    !identical(unname(as.list(old)), unname(as.list(new)))
  if (changed) {
    write_dictionary_cells(new, dict_path)
    ui_done("Updated {.path {dict_path}}")
  } else {
    ui_done("{.path {dict_path}} is up to date")
  }
  report_dictionary_changes(merged)

  described <- !trimws(new$description) %in% c("", "NA")
  if (all(described)) {
    ui_done("Every variable has a description")
  } else {
    blank <- variable_label(new$file_name[!described], new$variable_name[!described])
    ui_todo("Write the description of {length(blank)} variable{?s} in {.path {dict_path}}: {.val {blank}}")
  }
  invisible(dict_path)
}

# The dictionary as written, every cell a string. Nothing is converted, so
# codes such as "001" and the text "NA" come back as typed. The file is read
# as UTF-8, and a byte order mark from a spreadsheet export is dropped.
read_dictionary_cells <- function(dict_path) {
  bom <- identical(readBin(dict_path, "raw", 3L), as.raw(c(0xef, 0xbb, 0xbf)))
  dictionary <- utils::read.csv(dict_path, colClasses = "character",
                                na.strings = character(), check.names = FALSE,
                                encoding = "UTF-8",
                                fileEncoding = if (bom) "UTF-8-BOM" else "")
  missing <- setdiff(c("file_name", "variable_name"), names(dictionary))
  if (length(missing) > 0) {
    cli::cli_abort(c(
      "{.path {dict_path}} lacks {length(missing)} column{?s}: {.val {missing}}.",
      "i" = "{.fun update_dictionary} matches the rows on {.val file_name} and {.val variable_name}. Restore both column names, or delete the file and run {.fun setup_dictionary}."
    ))
  }
  keys <- dictionary_key(dictionary$file_name, dictionary$variable_name)
  twice <- unique(keys[duplicated(keys) & keys != dictionary_key("", "")])
  if (length(twice) > 0) {
    labels <- variable_label(dictionary$file_name[match(twice, keys)],
                             dictionary$variable_name[match(twice, keys)])
    cli::cli_abort(c(
      "{.path {dict_path}} has more than one row for {length(labels)} variable{?s}: {.val {labels}}.",
      "i" = "Keep one row per variable, then run {.fun update_dictionary} again."
    ))
  }
  dictionary
}

# Write the dictionary as UTF-8 with every cell quoted, the layout
# utils::write.csv() gives. Written as bytes, so the text does not pass
# through the encoding of the session and the line ends are the same on
# every platform.
write_dictionary_cells <- function(dictionary, dict_path) {
  quoted <- function(x) paste0('"', gsub('"', '""', enc2utf8(x), fixed = TRUE), '"')
  lines <- c(paste(quoted(names(dictionary)), collapse = ","),
             do.call(paste, c(lapply(unname(dictionary), quoted), sep = ",")))
  con <- file(dict_path, open = "wb")
  on.exit(close(con), add = TRUE)
  writeLines(lines, con, sep = "\n", useBytes = TRUE)
  invisible(dict_path)
}

# Merge the dictionary on file with the variables found in the data. Returns
# the new dictionary and what differs from the old one.
merge_dictionary <- function(old, info, data_dir) {
  standard <- c("directory", "file_name", "variable_name", "variable_type", "description")
  new_cols <- setdiff(standard, names(old))
  for (col in new_cols) old[[col]] <- rep("", nrow(old))

  empty <- old$file_name == "" & old$variable_name == ""
  old_keys <- dictionary_key(old$file_name, old$variable_name)
  new_keys <- dictionary_key(info$file_name, info$var_name)
  from <- match(new_keys, old_keys)
  added <- is.na(from)

  # A row per variable in the data, carrying the cells of its old row
  new <- old[from, , drop = FALSE]
  new[added, ] <- ""
  new$directory[added] <- data_dir
  new$file_name <- info$file_name
  new$variable_name <- info$var_name
  retyped <- !added & new$variable_type != info$var_type
  old_types <- new$variable_type[retyped]
  new$variable_type <- info$var_type
  rownames(new) <- NULL

  removed <- !empty & !old_keys %in% new_keys
  list(
    dictionary = new,
    new_cols = new_cols,
    empty_rows = sum(empty),
    added = info[added, c("file_name", "var_name"), drop = FALSE],
    removed = old[removed, , drop = FALSE],
    retyped = data.frame(file_name = info$file_name[retyped],
                         var_name = info$var_name[retyped],
                         from = old_types, to = info$var_type[retyped]),
    reordered = !any(added) && !any(removed) && !any(empty) &&
      !identical(old_keys, new_keys)
  )
}

report_dictionary_changes <- function(merged) {
  if (length(merged$new_cols) > 0) {
    cols <- merged$new_cols
    ui_info("Added {length(cols)} column{?s} the dictionary lacked: {.val {cols}}")
  }
  if (merged$empty_rows > 0) {
    ui_info("Dropped {merged$empty_rows} empty row{?s}")
  }
  if (nrow(merged$added) > 0) {
    added <- variable_label(merged$added$file_name, merged$added$var_name)
    ui_info("Added {length(added)} variable{?s}: {.val {added}}")
  }
  removed <- merged$removed
  if (nrow(removed) > 0) {
    labels <- variable_label(removed$file_name, removed$variable_name)
    ui_info("Removed {length(labels)} variable{?s}: {.val {labels}}")
    # A rename shows up as rows removed and rows added, of a variable or of
    # a whole data object; what the user wrote in a removed row is worth
    # keeping then
    written <- vapply(seq_len(nrow(removed)), function(i) written_cells(removed[i, ]), character(1))
    candidate <- nrow(merged$added) > 0 & written != ""
    if (any(candidate)) {
      ui_todo("If a removed variable or its data object was renamed, copy what you wrote about it to the new row:")
      for (i in which(candidate)) {
        label <- labels[i]
        cells <- written[i]
        ui_info("{.val {label}}: {cells}")
      }
    }
  }
  retyped <- merged$retyped
  if (nrow(retyped) > 0) {
    labels <- paste0(variable_label(retyped$file_name, retyped$var_name),
                     " (", retyped$from, " to ", retyped$to, ")")
    ui_info("Changed the type of {length(labels)} variable{?s}: {.val {labels}}")
  }
  if (merged$reordered) {
    ui_info("Reordered the rows to follow the data")
  }
  invisible(NULL)
}

# The cells of one dictionary row that a user wrote, as "column: value"
# pairs. The four columns washr fills from the data are left out.
written_cells <- function(row) {
  cols <- setdiff(names(row), c("directory", "file_name", "variable_name", "variable_type"))
  cells <- vapply(cols, function(col) row[[col]], character(1))
  cells <- cells[!trimws(cells) %in% c("", "NA")]
  paste0(names(cells), ": ", cells, collapse = "; ")
}

dictionary_key <- function(file_name, variable_name) {
  paste(file_name, variable_name, sep = "\r")
}

# A variable as the user reads it in R, e.g. trips$volume.
variable_label <- function(file_name, variable_name) {
  paste0(tools::file_path_sans_ext(file_name), "$", variable_name)
}
