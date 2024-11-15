add_creator <- function (name= "", email="", affiliation = "Openwashdata") {

  creators <- readr::read_csv("data/metadata/creators.csv", show_col_types = FALSE)

  if (name == ""){
    usethis::ui_stop("Name cannot be blank!")
  }

  if (email == ""){
    # Ask if user wants to proceed without email
    email_confirm <- readline("Email is blank. Do you want to proceed without email? (y/n): ")
    if (tolower(email_confirm) != "y") {
      usethis::ui_stop("Please pass an email address.")
    }
  }

  if (affiliation == "Openwashdata") {
    cat("Proceeding with default affiliation: Openwashdata\n")
  }

  id <- nrow(creators) + 1

  # Append new creator to the end of the data frame
  new_row <- tibble::tibble(
    id = id,
    name = name,
    affiliation = affiliation,
    email = email
  )

  creators <- dplyr::bind_rows(creators, new_row)

  # Write back to creators.csv
  readr::write_csv(creators, "data/metadata/creators.csv")

  print("Creator added successfully!")

}
