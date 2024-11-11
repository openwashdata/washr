library(tidyverse)

update_attributes <- function(){
  correct_wd <- is_pk
  if(!file.exists("data-raw/dictionary.csv")){
    usethis::ui_stop("Dictionary file not detected. Please run setup_rawdata first and ensure dictionary is up to date")
  }
  else {
    dictionary <- read_csv("data-raw/dictionary.csv", show_col_types = FALSE)
    dictionary |>  write_csv("data/metadata/attributes.csv")
    cat("Attributes metadata updated!")
  }
}

