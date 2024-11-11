update_biblio <- function() {
  # Check if the DESCRIPTION file exists
  if (!file.exists("DESCRIPTION")) {
    stop("DESCRIPTION file not found. Please run the description function first.")
  }

  # Check if the biblio.csv file exists
  biblio_path <- "data/metadata/biblio.csv"
  if (!file.exists(biblio_path)) {
    stop("biblio.csv file not found at 'data/metadata/'. Please ensure the file exists.")
  }

  # Read the DESCRIPTION file
  description <- read.dcf("DESCRIPTION")

  # Extract values for the selected fields
  title <- description[,"Title"]
  pkg_description <- description[,"Description"]
  license <- description[,"License"]
  funder <- "https://ethrat.ch/en/eth-domain/open-research-data/"

  # Read the existing biblio.csv file
  biblio_data <- read.csv(biblio_path, stringsAsFactors = FALSE)

  # Update the selected fields
  biblio_data$title <- title
  biblio_data$description <- pkg_description
  biblio_data$license <- license
  biblio_data$funder <- funder

  # Write back to biblio.csv
  write.csv(biblio_data, biblio_path, row.names = FALSE)
  print("Biblio metadata updated!")
}
