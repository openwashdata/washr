#' Set up the R CMD check workflow for the data package
#'
#' @description
#' `setup_ci()` writes the GitHub Actions workflow that runs `R CMD check` on
#' every push and pull request to `main` and `dev`, on macOS, Windows and
#' three versions of R on Linux. The openwashdata review standard requires
#' this workflow with the `dev` trigger, so a package scaffolded with washr
#' passes that part of the review floor by construction.
#'
#' The workflow lands in `.github/workflows/R-CMD-check.yaml` and `.github`
#' is added to `.Rbuildignore`. When `README.Rmd` exists with badge markers,
#' the matching R CMD check badge is added between them (the README template
#' from [setup_readme()] carries it already). An existing workflow file is
#' kept as it is, so the function is safe to run again.
#'
#' @returns The path of the workflow file, invisibly.
#'
#' @seealso Next: [setup_rawdata()]. The badge appears in the README written by [setup_readme()].
#'
#' @family setup functions
#'
#' @export
#'
#' @examples
#' \dontrun{
#' setup_ci()
#' }
setup_ci <- function() {
  if (!is_pkg()) {
    usethis::ui_stop("You are not in the correct working directory for developing the data package.
                          Please check your working directory.")
  }
  target <- file.path(".github", "workflows", "R-CMD-check.yaml")
  if (file.exists(target)) {
    usethis::ui_info("{usethis::ui_path(target)} exists and is kept as it is.")
  } else {
    dir.create(dirname(target), recursive = TRUE, showWarnings = FALSE)
    usethis::use_template(template = "R-CMD-check.yaml",
                          save_as = target,
                          data = list(),
                          ignore = FALSE,
                          open = FALSE,
                          package = "washr")
  }
  usethis::use_build_ignore(".github")
  if (add_check_badge()) {
    usethis::ui_done("Added the R CMD check badge to README.Rmd; rebuild it with devtools::build_readme()")
  }
  invisible(target)
}

# Insert the R CMD check badge between the badge markers of README.Rmd when
# the file exists and the badge is missing. Returns TRUE when it wrote.
add_check_badge <- function(path = "README.Rmd") {
  if (!file.exists(path)) return(invisible(FALSE))
  lines <- readLines(path, warn = FALSE)
  if (any(grepl("workflows/R-CMD-check.yaml/badge.svg", lines, fixed = TRUE))) return(invisible(FALSE))
  end <- which(trimws(lines) == "<!-- badges: end -->")
  if (length(end) == 0) return(invisible(FALSE))
  repo <- github_repo_url()
  if (is.null(repo)) repo <- paste0("https://github.com/openwashdata/", desc::desc_get("Package")[[1]])
  badge <- sprintf("[![R-CMD-check](%s/actions/workflows/R-CMD-check.yaml/badge.svg)](%s/actions/workflows/R-CMD-check.yaml)", repo, repo)
  lines <- append(lines, badge, after = end[1] - 1)
  writeLines(lines, path)
  invisible(TRUE)
}
