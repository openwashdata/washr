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

# GitHub repository URLs in their canonical form,
# https://github.com/org/repo, and NA for a URL that is not one. A trailing
# slash, a .git suffix, a fragment or query and a www. prefix are dropped,
# so every way of writing the repository gives the same organisation.
normalise_github_url <- function(urls) {
  urls <- sub("[#?].*$", "", trimws(urls))
  urls <- sub("\\.git$", "", sub("/+$", "", urls))
  parts <- regmatches(urls, regexec("^https?://(www\\.)?github\\.com/([^/]+)/([^/]+)$", urls))
  vapply(parts, function(x) {
    if (length(x)) paste0("https://github.com/", x[[3]], "/", x[[4]]) else NA_character_
  }, character(1))
}

# The GitHub repository URL from the URL field of DESCRIPTION, or NULL.
github_repo_url <- function(file = ".") {
  repos <- normalise_github_url(desc::desc_get_urls(file = file))
  repos <- repos[!is.na(repos)]
  if (length(repos)) repos[[1]] else NULL
}
