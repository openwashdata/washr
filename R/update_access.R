library(tidyverse)

extdata_path <- "https://github.com/openwashdata/worldhdi/raw/main/inst/extdata/"

update_access <- function(){

dictionary_path <- "data-raw/dictionary.csv"

dictionary <- read_csv(dictionary_path, show_col_types = FALSE)

dataset <- dictionary |> distinct(file_name)

# Remove file extension
dataset <- dataset |> mutate(file_name = str_remove(file_name, ".rda"))

file_name <- dataset$file_name

data <- data.frame(
  fileName = c(paste0(file_name, ".csv"), paste0(file_name, ".xlsx")),
  name = rep(file_name, 2),
  contentUrl = c(
    "https://raw.githubusercontent.com/openwashdata/worldhdi/main/inst/extdata/worldhdi.csv",
    "https://raw.githubusercontent.com/openwashdata/worldhdi/main/inst/extdata/worldhdi.xlsx"
  ),
  encodingFormat = c("csv", "ooxml"),
  stringsAsFactors = FALSE
)

write.csv(data, "data/metadata/access.csv")
cat ("Access metadata updated!")

}
