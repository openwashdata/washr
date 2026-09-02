#' Update the citation file for the dataset.
#'
#' @description
#' Create a citation *.cff file for the dataset from a given DOI (Digital
#' Object Identifier). When a DOI is supplied, it adds the DOI badge to the
#' README RMarkdown file and re-builds the README.md and pkgdown website if
#' they exist. Before a release exists, call it without arguments to generate
#' the citation files without a DOI or badge.
#'
#' @param doi DOI (Digital Object Identifier), e.g., 10.5281/zenodo.11185699.
#'   Defaults to NULL for the pre-release call, in which case no DOI is
#'   recorded and no badge is added.
#'
#' @returns NULL. A citation .cff file is written under the root directory.
#' @export
#'
#' @examples
#' \dontrun{
#'   update_citation(doi = "10.5281/zenodo.11185699")
#' }
#'
update_citation <- function(doi = NULL){
  # Creates CFF with all author roles
  keys <- list("date-released" = desc::desc_get("Date"))
  if (!is.null(doi)) {
    keys$doi <- doi
  }
  mod_cff <- cffr::cff_create("DESCRIPTION",
                        dependencies = FALSE,
                        keys = keys)

  # Remove the preferred-citation key
  mod_cff$`preferred-citation` <- NULL

  # Writes the CFF file
  cffr::cff_write(mod_cff)

  # cffr adds CITATION.cff to .Rbuildignore only when cff_write() is given a
  # path; for a cff object it returns early, so do it here (idempotent).
  usethis::use_build_ignore("CITATION.cff")

  # Now write a CITATION file from the CITATION.cff file
  # Use inst/CITATION instead (the default if not provided)
  path_cit <- file.path("inst/CITATION")

  a_cff <- cffr::cff_read(path = "CITATION.cff")

  cffr::cff_write_citation(a_cff, file = path_cit)

  # cffr backs up an existing file as *.bk1 before overwriting; drop the
  # backups so they cannot slip into release commits
  backups <- c(Sys.glob("CITATION.cff.bk*"), Sys.glob(file.path("inst", "CITATION.bk*")))
  if (length(backups) > 0) {
    unlink(backups)
  }

  # Modify README and pkgdown
  if(!is.null(doi) && file.exists(file.path("README.Rmd"))){
    add_citation_badge(doi)
    devtools::build_readme()
  }

  if(dir.exists(file.path("docs"))){
    devtools::build_site()
  }

  # By last, read the citation
  usethis::ui_todo("Proofread your citation file at {usethis::ui_value(path_cit)}")
}

add_citation_badge<- function(doi){
  badge_icon <- paste0("https://zenodo.org/badge/DOI/", doi, ".svg")
  zenodo_link <- paste0("https://zenodo.org/doi/", doi)
  badge_str <- sprintf("[![DOI](%s)](%s)", badge_icon, zenodo_link)
  readme_rmd_path <- file.path("README.Rmd")
  readme_rmd <- readLines(readme_rmd_path)

  end_marker <- which(startsWith(readme_rmd, "<!-- badges: end -->"))
  if (length(end_marker) == 0) {
    usethis::ui_stop("No '<!-- badges: end -->' marker found in README.Rmd.
                      Please add the badge markers before updating the citation.")
  }

  existing <- which(grepl("[![DOI](https://zenodo.org/badge/DOI/", readme_rmd, fixed = TRUE))
  if (length(existing) > 0) {
    # Replace the existing badge in place so re-runs stay idempotent
    readme_rmd[existing[1]] <- badge_str
    if (length(existing) > 1) {
      readme_rmd <- readme_rmd[-existing[-1]]
    }
    new_readme_rmd <- readme_rmd
  } else {
    i <- end_marker[1]
    new_readme_rmd <- c(readme_rmd[seq_len(i - 1)], badge_str, readme_rmd[i:length(readme_rmd)])
  }
  writeLines(new_readme_rmd, readme_rmd_path)
}
