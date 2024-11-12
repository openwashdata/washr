library(tidyverse)

update_attributes <- function(){
  correct_wd <- is_pkg()
  if (correct_wd){

    if(!file.exists("data-raw/dictionary.csv")){
      usethis::ui_stop("Dictionary file not detected. Please run setup_rawdata first and ensure dictionary is up to date")
    }
    else {
      dictionary <- read_csv("data-raw/dictionary.csv", show_col_types = FALSE)
      dictionary |>  write_csv("data/metadata/attributes.csv")
      cat("Attributes metadata updated!")
    }
  }
  else {
    usethis::ui_stop("You are not in the correct working directory for developing the data package.
                          Please check your working directory.")
  }
}

