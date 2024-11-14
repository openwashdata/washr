library(tidyverse)

#' Adds metadata files and creates the metadata folder
#'
#' @description
#' Creates the data/metadata directory with the acess, attributes, biblio and
#' creators metadata files. If the directory already exists, the user is prompted
#' to overwrite the existing files.
#'
#'
#' @returns NULL. Error message if the metadata folder already exists and user declines to
#' create new metadata files.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' add_metadata()
#' }
add_metadata <- function(){


  # If metadata folder doesn't exist
  if(!dir.exists("data/metadata")){
    cat("No metadata folder detected")
    dataspice::create_spice()
    cat("/n Metadata files created in data/metadata")
  }
  else {
    cat("Metadata folder already exsits. Overwrite?")
    response <- readline(prompt = "Enter y/n: ")
    if (response == "y"){
      dataspice::create_spice()
      cat("Metadata files created in data/metadata")
    }
    else {
      cat("Failed! Folder already exists.")
  }
  }
}
