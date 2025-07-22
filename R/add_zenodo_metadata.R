#' Add a JSON file to contain metadata for Zenodo upload
#'
#' @return
#' @export
#'
#' @examples
add_zenodo_metadata <- function(){
  metadata_json <- create_zenodo_metadata()
  # write json to pkg root directory
  writeLines(metadata_json, "./.zenodo.json")
}

#' Create a JSON object about package metadata for Zenodo upload
#'
#' @return
#' @export
#'
#' @examples
#'
create_zenodo_metadata <- function(){
  pkgname <- get_pkgname()
  # Author info
  authors <- desc::desc_get_authors()
  author_list <- data.frame()
  for (i in 1:length(authors)) {
    name = paste0(authors[i]$family, ", ", authors[i]$given)
    if (is.null(authors[i]$comment)) {orcid <- NA } else {orcid <- authors[i]$comment}
    author_list <- rbind(author_list, c(name, orcid))
  }
  author_list <- `colnames<-`(author_list, c("name", "orcid"))

  # license
  license = "cc-by-4.0"

  # Related Identifier
  related_identifier_list <- data.frame(
    identifier = sprintf("https://openwashdata.github.io/%s/", pkgname),
    relation = "isCompiledBy",
    resource_type = "dataset"
  )

  # Make metadata json
  metadata <- list(
    creators = author_list,
    license = license,
    upload_type = "dataset",
    notes = sprintf("Visit the website of this dataset for instructions how to use it:
    https://openwashdata.github.io/%s/", pkgname),
    related_identifiers = related_identifier_list,
    communities = data.frame(identifier = "openwashdata")
  )

  metadata_json <- jsonlite::toJSON(metadata, pretty=TRUE,auto_unbox = TRUE)
  return(metadata_json)
}

get_pkgname <- function(){
  return(desc::desc_get("Package"))
}
