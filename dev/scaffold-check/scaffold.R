# Scaffold check (#129): build a fixture data package with washr in the order
# the vignette documents, then run every re-runnable step a second time and
# stop if a file changed. The workflow runs pkgreview's check script on the
# result afterwards.
#
# Usage: Rscript dev/scaffold-check/scaffold.R <target-dir>
# The last path component of <target-dir> becomes the package name. The
# installed washr is used, or the one loaded with devtools::load_all().

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1) stop("Usage: Rscript scaffold.R <target-dir>")
target <- args[[1]]
script_dir <- Sys.getenv("SCAFFOLD_CHECK_DIR", "dev/scaffold-check")
raw_csv <- normalizePath(file.path(script_dir, "trips.csv"))
if (dir.exists(target)) stop("Target directory exists: ", target)

# The parts a person writes: title, description, author, keywords, coverage.
usethis::create_package(
  target,
  fields = list(
    Title = "Truck Trips of a Faecal Sludge Emptying Service",
    Description = paste(
      "A fixture data package with one table of truck trips of a faecal",
      "sludge emptying service. The washr scaffold check builds it to test",
      "that a freshly scaffolded package meets the review standard."
    ),
    `Authors@R` = paste0(
      'person("Jane", "Doe", email = "jane.doe@example.org", ',
      'role = c("aut", "cre"), comment = c(ORCID = "0000-0002-1825-0097"))'
    ),
    `X-schema.org-keywords` = "open data, washdata, faecal sludge, sanitation",
    `X-schema.org-spatialCoverage` = "Kampala, Uganda",
    `X-schema.org-temporalCoverage` = "2022-03-01/2022-03-09"
  ),
  open = FALSE, rstudio = FALSE, check_name = FALSE
)
setwd(target)
usethis::proj_set(target)
pkg <- basename(normalizePath(target))

# 1. and 2. Workflow, raw data folder, processing script.
washr::setup_ci()
washr::setup_rawdata()
file.copy(raw_csv, file.path("data-raw", "trips.csv"))
# The commented example lines of the template give way to the real import,
# as they do when a person fills in the script.
script <- readLines(file.path("data-raw", "data_processing.R"))
from <- grep("^# Read data", script)
to <- grep("^# Tidy data", script)
import <- c(
  sprintf("%s <- readr::read_csv(", pkg),
  '  here::here("data-raw", "trips.csv"),',
  '  col_types = readr::cols(',
  '    trip_id = readr::col_integer(),',
  '    date = readr::col_date(),',
  '    truck_plate = readr::col_character(),',
  '    volume_m3 = readr::col_double(),',
  '    settlement_type = readr::col_character()',
  '  )',
  ')',
  ''
)
script <- c(script[seq_len(from)], import, script[to:length(script)])
writeLines(script, file.path("data-raw", "data_processing.R"))
source(file.path("data-raw", "data_processing.R"), local = new.env())

# 3. Dictionary, with the descriptions a person writes.
dict_path <- washr::setup_dictionary()
dict <- utils::read.csv(dict_path)
descriptions <- c(
  trip_id = "Identifier of the trip.",
  date = "Date of the trip.",
  truck_plate = "Number plate of the truck.",
  volume_m3 = "Volume of faecal sludge emptied, in cubic metres.",
  settlement_type = "Type of settlement the sludge was collected in: formal or informal."
)
dict$description <- unname(descriptions[dict$variable_name])
utils::write.csv(dict, dict_path, row.names = FALSE, na = "")

# 4. Roxygen documentation, with the title and description a person writes.
roxygen_file <- washr::setup_roxygen()
rox <- readLines(roxygen_file)
rox[rox == sprintf("#' %s: Title goes here", pkg)] <- "#' Truck trips of a faecal sludge emptying service"
rox[rox == "#' Description of the data goes here..."] <- "#' One row per trip of an emptying truck, with the date, the truck and the volume emptied."
label <- length(rox)
rox <- c(rox[seq_len(label - 1)], "#' @source Fixture data written for the washr scaffold check.", rox[label])
writeLines(rox, roxygen_file)
devtools::document()

# 5. to 9. DESCRIPTION, metadata, README, website, brand, citation.
washr::update_description()
washr::update_metadata()
washr::setup_readme(has_example = TRUE)
devtools::build_readme()
washr::setup_website(has_example = TRUE)
washr::use_brand()
washr::update_citation(doi = "10.5281/zenodo.11185699")
washr::update_metadata()

# Second run of every re-runnable step: no file may change (the claim in
# NEWS and in the vignette). docs/ is left out, the site build is not
# byte-stable.
tree_md5 <- function() {
  files <- list.files(".", recursive = TRUE, all.files = TRUE, full.names = TRUE)
  files <- files[!grepl("^\\./(docs|\\.git)/", files)]
  tools::md5sum(files)
}
before <- tree_md5()
washr::setup_ci()
washr::setup_rawdata()
washr::update_dictionary()
washr::setup_roxygen()
washr::update_description()
washr::update_metadata()
washr::use_brand()
washr::update_citation(build = FALSE)
washr::update_metadata()
after <- tree_md5()
changed <- union(
  setdiff(names(after), names(before)),
  names(before)[!is.na(after[names(before)]) & before != after[names(before)]]
)
changed <- union(changed, setdiff(names(before), names(after)))
if (length(changed) > 0) {
  stop("The second run changed ", length(changed), " file(s): ",
       paste(changed, collapse = ", "))
}
message("scaffold check: second run changed no file")

# The package's own gate agrees: no item of the readiness report fails.
readiness <- washr::check_publication_readiness()
if (!isTRUE(attr(readiness, "ready"))) {
  stop("check_publication_readiness() reports failing items: ",
       paste(readiness$id[readiness$status == "fail"], collapse = ", "))
}
