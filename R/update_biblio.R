#' Function to update the biblio metadata file
#'
#' @description This function updates the biblio metadata file with the values from the DESCRIPTION file.
#' along with some standard templated values for funder, license, etc.
#'
#' @returns NULL. Error if DESCRIPTION does not exist.
#'
#' @export
#'
#' @examples
#' \dontrun {
#' update_biblio()
#' }
update_biblio <- function() {

  # Check if the DESCRIPTION file exists
  if (!file.exists("DESCRIPTION")) {
    stop("DESCRIPTION file not found. Please create and complete a DESCRIPTION first.")
  }

  # Check if the biblio.csv file exists
  biblio_path <- "data/metadata/biblio.csv"
  if (!file.exists(biblio_path)) {
    stop("biblio.csv file not found at 'data/metadata/'. Please run add_metadata first.")
  }

  # Read the DESCRIPTION file
  description <- read.dcf("DESCRIPTION")

  # Extract values for the selected fields
  title <- description[,"Title"]
  pkg_description <- description[,"Description"]
  license <- description[,"License"]
  funder <- "https://ethrat.ch/en/eth-domain/open-research-data/"

  bibilo_data <- data.frame(
    title = character(),
    description = character(),
    license = character(),
    funder = character(),
    stringsAsFactors = FALSE
  )

  # Update the selected fields
  biblio_data$title <- title
  biblio_data$description <- pkg_description
  biblio_data$license <- license
  biblio_data$funder <- funder

  # Write back to biblio.csv
  write.csv(biblio_data, biblio_path, row.names = FALSE)
  print("Biblio metadata updated! Please complete remaining fields")
}
