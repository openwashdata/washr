#' Set up a pkgdown website for the data package
#'
#' @description
#' `setup_website()` writes the openwashdata pkgdown configuration and builds
#' the site from the package documentation and README.md. The configuration
#' comes from the washr template: the Pages URL as the site URL, the
#' openwashdata analytics header, the funding sidebar, the authors footer,
#' and a reference index with one entry per data object in `data/`.
#'
#' The function is safe to re-run. An existing `_pkgdown.yml` is kept as it
#' is and only the site is rebuilt, so hand edits and the brand wiring from
#' [use_brand()] survive. The example article is created once.
#'
#' By default the built `docs/` folder is tracked in git, which is how
#' openwashdata packages publish their site from `main`. When the package
#' deploys through the pkgdown GitHub Actions workflow instead
#' (`.github/workflows/pkgdown.yaml` exists), `docs/` stays ignored.
#'
#' @param has_example Logical. Should the pkgdown website include a vignette page
#' for writing an example? Defaults to FALSE.
#' @param track_docs Logical. Remove `docs` from `.gitignore` so the built
#'   site is committed? Defaults to `TRUE` unless a pkgdown workflow exists
#'   under `.github/workflows/`.
#'
#' @returns NULL. Error if no README file is found.
#'
#' @seealso Before: [setup_readme()]. Next: [use_brand()] for the brand, and [update_citation()] once the release has a DOI.
#'
#' @family publishing functions
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Set up the pkgdown website including a vignette page
#'  setup_website(has_example = TRUE)
#' }
setup_website <- function(has_example = FALSE, track_docs = NULL){
  if (!is_readme_available()) {
    usethis::ui_stop("No README.md exists. Consider to set up and write README first. You may use washr::setup_readme()")
  }
  name <- desc::desc_get("Package")[[1]]
  configpath <- "_pkgdown.yml"
  if (file.exists(configpath)) {
    usethis::ui_info("{usethis::ui_path(configpath)} exists and is kept as it is. This run rebuilds the site.")
  } else {
    usethis::use_pkgdown(config_file = configpath)
    file.remove(configpath)
    datasets <- dataset_names()
    usethis::use_template(template = "_pkgdown.yml",
                          save_as = configpath,
                          data = list(name = name,
                                      datasets = datasets,
                                      has_datasets = length(datasets) > 0),
                          ignore = FALSE,
                          open = FALSE,
                          package = "washr")
  }

  # Create the example article once; pkgdown::build_site() renders it
  if (has_example && !file.exists(file.path("vignettes", "articles", "examples.Rmd"))) {
    usethis::use_article("examples")
  }
  pkgdown::build_site()

  if (is.null(track_docs)) track_docs <- !has_pkgdown_workflow()
  if (track_docs) {
    untrack_docs_in_gitignore()
  } else {
    usethis::ui_info("docs/ stays in .gitignore; the site deploys through the pkgdown workflow.")
  }
  invisible(NULL)
}

is_readme_available <- function(){
  is_available <- file.exists(file.path(getwd(), "README.md"))
  return(is_available)
}

# Names of the data objects in data/, for the reference index of the site.
dataset_names <- function(data_dir = "data") {
  if (!dir.exists(data_dir)) return(character())
  tools::file_path_sans_ext(list.files(data_dir, pattern = "\\.[Rr][Dd]a(ta)?$"))
}

has_pkgdown_workflow <- function() {
  dir <- file.path(".github", "workflows")
  dir.exists(dir) && length(list.files(dir, pattern = "^pkgdown\\.ya?ml$")) > 0
}

# Remove the docs entry usethis::use_pkgdown() adds to .gitignore, so the
# built site is committed. A missing .gitignore is left alone.
untrack_docs_in_gitignore <- function() {
  path <- ".gitignore"
  if (!file.exists(path)) return(invisible(FALSE))
  lines <- readLines(path, warn = FALSE)
  keep <- lines[!trimws(lines) %in% c("docs", "docs/", "/docs", "/docs/")]
  if (length(keep) != length(lines)) writeLines(keep, path)
  invisible(length(keep) != length(lines))
}
