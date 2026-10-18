
#' Update the DESCRIPTION file to conform with openwashdata standards
#'
#' @description
#' This function updates the DESCRIPTION file of an R package to comply with openwashdata standards.
#' It ensures that fields such as `License`, `Language`, `Date`, `URL`, and others are correctly specified.
#' Existing `URL` and `Config/Needs/website` entries are preserved and merged
#' with the openwashdata defaults. A CC BY 4.0 license is only set when the
#' package does not have a license yet; an existing license is left untouched.
#'
#' @details
#' DESCRIPTION is where the other functions read the facts of the package:
#' the GitHub organisation and the repository from `URL`, the license from
#' `License`, the people from `Authors@R`. The values that DESCRIPTION has no
#' standard field for are written as `Config/washr/` fields, and every other
#' function reads them from there:
#'
#' | Field | Used for | openwashdata default |
#' |---|---|---|
#' | `Config/washr/funding` | the funding sentence in the sidebar of the site | the ETH Board Open Research Data Program |
#' | `Config/washr/analytics-domain` | the Plausible analytics header of the site | `openwashdata.github.io` |
#' | `Config/washr/doi-provider` | the DOI badge of the README | `zenodo` |
#' | `Config/washr/zenodo-community` | the community in `.zenodo.json` | `openwashdata` |
#' | `Config/washr/brand-source` | the GitHub repository [use_brand()] copies from | `openwashdata/brand` |
#' | `Config/washr/version` | the washr version that last ran this function | |
#'
#' A field that you edited is never overwritten, so a group other than
#' openwashdata publishes with its own values by editing them. When
#' `github_user` names another organisation than the one in `URL`, the
#' repository in `URL` is replaced and the fields that still hold the
#' defaults of the old organisation follow. Set a field
#' to `none` to switch its feature off. For a package under another GitHub
#' organisation the funding, analytics, community and brand fields are
#' written as `none`, because the openwashdata values would be wrong there.
#' One more field is only ever written by hand: `Config/washr/pages-domain`,
#' for a site that is not served from `<organisation>.github.io`.
#'
#' @param file Character. The file path to the DESCRIPTION file of the R package. Defaults to the current working directory.
#' @param github_user Character. The URL of the GitHub user or organization
#'   that hosts the package, e.g., `"https://github.com/yourorg"`. Defaults
#'   to the organisation of the repository already listed in `URL`, and to
#'   `"https://github.com/openwashdata"` when `URL` lists none.
#'
#' @seealso Before: [setup_roxygen()]. Next: [update_metadata()] for the schema.org metadata, then [setup_readme()].
#'
#' @family metadata functions
#'
#' @export
#'
#' @returns The path of the DESCRIPTION file, invisibly. The fields are
#'   updated in the file.
#' @examples
#' \dontrun{
#'  # Update DESCRIPTION file in the current package
#' update_description()
#'
#'  # Update DESCRIPTION file in a specific package
#' update_description(file = "path/to/your/package/DESCRIPTION")
#'
#'  # Update DESCRIPTION file with a specific GitHub user
#' update_description(github_user = "https://github.com/yourusername")
#' }
#'
#'
update_description <- function(file = ".", github_user = NULL){
  desc_path <- if (dir.exists(file)) file.path(file, "DESCRIPTION") else file
  if(!file.exists(desc_path)){
    cli::cli_abort("No DESCRIPTION file found at {.path {desc_path}}.")
  }
  local_session()
  pkgname <- desc::desc_get("Package", file = file)[[1]]
  # author

  # license: set CC BY 4.0 only when no license is present yet; the usethis
  # call acts on the active project, so it only runs for the package in the
  # working directory
  license <- desc::desc_get_field("License", default = "", file = file)
  in_wd <- identical(normalizePath(dirname(desc_path)), normalizePath(getwd()))
  if (in_wd && (identical(license, "") || grepl("use_mit_license", license, fixed = TRUE))) {
    usethis::use_ccby_license()
  }

  # language
  desc::desc_set("Language", "en-GB", file = file)
  # depends

  # Other Fields
  desc::desc_set("LazyData", "true", file = file)
  # Config/Needs/website: merge with existing entries instead of replacing
  website <- desc::desc_get_field("Config/Needs/website", default = "", file = file)
  website <- setdiff(trimws(strsplit(website, ",")[[1]]), "")
  desc::desc_set("Config/Needs/website",
                 paste(union("rmarkdown", website), collapse = ", "),
                 file = file)

  # Date
  desc::desc_set("Date",
                 Sys.Date(),
                 file = file)
  # The repository: the one under the GitHub user given, else the one URL
  # already lists, else the conventional one under openwashdata. URL entries
  # are merged, never replaced.
  urls <- desc::desc_get_urls(file = file)
  listed <- normalise_github_url(urls)
  previous <- if (any(!is.na(listed))) listed[!is.na(listed)][[1]] else NULL
  if (is.null(github_user)) {
    repo <- if (is.null(previous)) paste0("https://github.com/openwashdata/", pkgname) else previous
  } else {
    repo <- normalise_github_url(paste0(sub("/+$", "", github_user), "/", pkgname))
    if (is.na(repo)) {
      cli::cli_abort("{.arg github_user} must be the URL of a GitHub user or organisation, e.g. {.val https://github.com/yourorg}, not {.val {github_user}}.")
    }
    # The repository of this package under another account gives way to the
    # one named, so the organisation changes everywhere it is read
    urls <- urls[is.na(listed) | basename(listed) != pkgname | listed == repo]
    listed <- normalise_github_url(urls)
  }
  if (!repo %in% listed) urls <- c(urls, repo)
  desc::desc_set_urls(urls = urls,
                      file = file)
  # Bug Reports
  desc::desc_set("BugReports",
                 paste0(repo, "/issues"),
                 file = file)

  # The Config/washr fields (#81): written once with the defaults of the
  # organisation, then left to the group that owns the package. Config/
  # entries washr does not own are never touched.
  # When the organisation changes, a field that still holds the default of
  # the old organisation follows; a field someone edited stays.
  org <- basename(dirname(repo))
  old_org <- if (is.null(previous)) "openwashdata" else basename(dirname(previous))
  org_changed <- !identical(tolower(org), tolower(old_org))
  defaults <- washr_defaults(org)
  old_defaults <- washr_defaults(old_org)
  for (key in names(defaults)) {
    current <- washr_config(key, file = file)
    if (is.null(current) || (org_changed && identical(current, old_defaults[[key]]))) {
      desc::desc_set(paste0("Config/washr/", key), defaults[[key]], file = file)
    }
  }
  desc::desc_set("Config/washr/version",
                 as.character(utils::packageVersion("washr")),
                 file = file)

  ui_done("Updated {.path {desc_path}}")
  off <- names(defaults)[vapply(names(defaults), function(key) {
    !is_set(washr_config(key, file = file))
  }, logical(1))]
  if (length(off) > 0) {
    fields <- paste0("Config/washr/", off)
    ui_todo("Set {.field {fields}} in {.path {desc_path}} for your organisation, or leave {cli::qty(length(fields))}{?it/them} at {.val none}.")
  }
  invisible(desc_path)
}
