#' @importFrom utils head
load_object <- function(file) {
  if (!grepl("\\.(rda|RData)$", file, ignore.case = TRUE)) {
    cli::cli_abort(c(
      "{.path {file}} is not an .rda file.",
      "i" = "data/ holds one .rda file per data object, as {.fun usethis::use_data} writes them."
    ))
  }
  tmp_env <- new.env()
  loaded <- load(file = file, envir = tmp_env)
  if (length(loaded) != 1) {
    cli::cli_abort(c(
      "{.path {file}} holds {length(loaded)} objects ({.val {loaded}}).",
      "i" = "washr expects one data object per .rda file, as {.fun usethis::use_data} writes them."
    ))
  }
  tmp_env[[loaded]]
}

is_pkg <- function(){
  return(file.exists(file.path(getwd(), "DESCRIPTION")) &&
           file.exists(file.path(getwd(), "NAMESPACE"))
  )
}

# The GitHub repository URL from the URL field of DESCRIPTION, or NULL.
github_repo_url <- function(file = ".") {
  urls <- desc::desc_get_urls(file = file)
  repo <- urls[grepl("^https?://github\\.com/[^/]+/[^/]+/?$", urls)]
  if (length(repo)) sub("/$", "", repo[[1]]) else NULL
}
