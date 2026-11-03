# Description ------------------------------------------------------------------
# R script to process uploaded raw data into a tidy, analysis-ready data frame
# Load packages ----------------------------------------------------------------
## Run the following code in console if you don't have the packages
## install.packages(c("usethis", "fs", "here", "readr", "readxl", "openxlsx"))
library(usethis)
library(fs)
library(here)
library(readr)
library(readxl)
library(openxlsx)

# Read data --------------------------------------------------------------------
# data_in <- readr::read_csv("data-raw/dataset.csv")
# codebook <- readxl::read_excel("data-raw/codebook.xlsx") |>
#  clean_names()

# Tidy data --------------------------------------------------------------------
## Clean the raw data into a tidy format here


# Export Data ------------------------------------------------------------------
{{#datasets}}
usethis::use_data({{{name}}}, overwrite = TRUE)
{{/datasets}}
fs::dir_create(here::here("inst", "extdata"))
for (name in c({{{dataset_vector}}})) {
  obj <- get(name)
  readr::write_csv(obj, here::here("inst", "extdata", paste0(name, ".csv")))
  openxlsx::write.xlsx(obj, here::here("inst", "extdata", paste0(name, ".xlsx")))
}
