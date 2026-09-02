
#' Update the DESCRIPTION file to conform with openwashdata standards
#'
#' @description
#' This function updates the DESCRIPTION file of an R package to comply with openwashdata standards.
#' It ensures that fields such as `License`, `Language`, `Date`, `URL`, and others are correctly specified.
#' Existing `URL` and `Config/Needs/website` entries are preserved and merged
#' with the openwashdata defaults. A CC BY 4.0 license is only set when the
#' package does not have a license yet; an existing license is left untouched.
#'
#' @param file Character. The file path to the DESCRIPTION file of the R package. Defaults to the current working directory.
#' @param github_user Character. The URL path to the GitHub user or organization that hosts the current package. Defaults to "https://github.com/openwashdata".
#'
#' @seealso Before: [setup_roxygen()]. Next: [update_metadata()] for the schema.org metadata, then [setup_readme()].
#'
#' @family metadata functions
#'
#' @export
#'
#' @returns NULL. Update fields directly in DESCRIPTION file.
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
update_description <- function(file = ".", github_user = "https://github.com/openwashdata/"){
  desc_path <- if (dir.exists(file)) file.path(file, "DESCRIPTION") else file
  if(!file.exists(desc_path)){
    usethis::ui_stop("No DESCRIPTION file found!")
  }
  pkgname <- desc::desc_get("Package", file = file)[[1]]
  # author

  # license: set CC BY 4.0 only when no license is present yet; the usethis
  # call acts on the active project, so it only runs for the default file
  license <- desc::desc_get_field("License", default = "", file = file)
  if (file == "." && (identical(license, "") || grepl("use_mit_license", license, fixed = TRUE))) {
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
  # URL: merge with existing entries instead of replacing
  urls <- union(desc::desc_get_urls(file = file), paste0(github_user, pkgname))
  desc::desc_set_urls(urls = urls,
                      file = file)
  # Bug Reports
  desc::desc_set("BugReports",
                 paste0(github_user, pkgname, "/issues"),
                 file = file)
}
