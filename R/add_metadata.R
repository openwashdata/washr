library(tidyverse)

add_metadata <- function(){
  # If metadata folder doesn't exist
  if(!dir.exists("data/metadata")){
    cat("No metadata folder detected")
    dataspice::create_spice()
    cat("Metadata files created in data/metadata")
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
