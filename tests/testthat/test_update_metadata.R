options(usethis.quiet = TRUE)

# A data package with two datasets, an ORCID, a funder, a DOI and three
# exports (csv, xlsx, csv.gz). `complete = FALSE` leaves date, keywords,
# coverage and the DOI out, to test the blank report.
create_metadata_fixture <- function(env = parent.frame(), complete = TRUE) {
  create_local_package(env = env)
  rlang::local_interactive(FALSE, frame = env)
  pkg <- desc::desc_get("Package")[[1]]
  desc::desc_set(
    Title = "Trips and trucks in Kampala",
    Description = "Faecal sludge logistics data from Kampala. Two tables.",
    License = "CC BY 4.0",
    URL = paste0("https://github.com/openwashdata/", pkg, ", https://openwashdata.github.io/", pkg, "/")
  )
  desc::desc_set_authors(c(
    utils::person("Jane", "Doe", email = "jane@example.org", role = c("aut", "cre"),
                  comment = c(ORCID = "0000-0002-1825-0097")),
    utils::person("Global Health Engineering, ETH Zurich", role = "fnd")
  ))
  if (complete) {
    desc::desc_set(
      Date = "2026-07-08",
      `X-schema.org-keywords` = "sanitation, faecal sludge, Kampala",
      `X-schema.org-spatialCoverage` = "Kampala, Uganda",
      `X-schema.org-temporalCoverage` = "2022-03-01/2022-09-30"
    )
  }
  dir.create("data-raw")
  utils::write.csv(data.frame(
    directory = "data",
    file_name = c("trips.rda", "trips.rda", "trucks.rda"),
    variable_name = c("id", "volume", "plate"),
    variable_type = c("integer", "numeric", "character"),
    description = c("Trip identifier", "Volume in litres", ""),
    stringsAsFactors = FALSE
  ), file.path("data-raw", "dictionary.csv"), row.names = FALSE)
  dir.create(file.path("inst", "extdata"), recursive = TRUE)
  for (f in c("trips.csv", "trips.xlsx", "trucks.csv.gz")) {
    writeLines("x", file.path("inst", "extdata", f))
  }
  if (complete) {
    suppressMessages(update_citation(doi = "10.5281/zenodo.11185699"))
  }
  invisible(pkg)
}

test_that("update_metadata() derives the Dataset from the canonical sources", {
  pkg <- create_metadata_fixture()
  d <- suppressMessages(update_metadata())
  expect_identical(d[["@context"]], "https://schema.org")
  expect_identical(d[["@type"]], "Dataset")
  expect_identical(d$name, "Trips and trucks in Kampala")
  expect_identical(d$alternateName, pkg)
  expect_identical(d$version, "0.0.0.9000")
  expect_identical(d$datePublished, "2026-07-08")
  expect_identical(d$license, "https://creativecommons.org/licenses/by/4.0/")
  expect_identical(d$url, paste0("https://openwashdata.github.io/", pkg, "/"))
  expect_identical(d$identifier, "10.5281/zenodo.11185699")
  expect_identical(d$sameAs, "https://doi.org/10.5281/zenodo.11185699")
  expect_identical(as.character(d$keywords), c("sanitation", "faecal sludge", "Kampala"))
  expect_identical(d$spatialCoverage$name, "Kampala, Uganda")
  expect_identical(d$temporalCoverage, "2022-03-01/2022-09-30")
  expect_true(isTRUE(d$isAccessibleForFree))
})

test_that("update_metadata() maps Authors@R to creator, maintainer, funder and publisher", {
  create_metadata_fixture()
  d <- suppressMessages(update_metadata())
  expect_length(d$creator, 1)
  expect_identical(d$creator[[1]]$name, "Jane Doe")
  expect_identical(d$creator[[1]]$sameAs, "https://orcid.org/0000-0002-1825-0097")
  expect_null(d$creator[[1]]$email)
  expect_identical(d$maintainer$email, "jane@example.org")
  expect_identical(d$funder[[1]][["@type"]], "Organization")
  expect_identical(d$funder[[1]]$name, "Global Health Engineering, ETH Zurich")
  expect_identical(d$publisher$name, "openwashdata")
})

test_that("update_metadata() lists one distribution per existing file with the right MIME type", {
  pkg <- create_metadata_fixture()
  d <- suppressMessages(update_metadata())
  files <- vapply(d$distribution, function(x) x$name, character(1))
  formats <- vapply(d$distribution, function(x) x$encodingFormat, character(1))
  urls <- vapply(d$distribution, function(x) x$contentUrl, character(1))
  expect_identical(files, c("trips.csv", "trips.xlsx", "trucks.csv.gz"))
  expect_identical(formats, c("text/csv",
                              "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                              "application/gzip"))
  # the repository, not the dataset, names the URL (#100)
  expect_true(all(grepl(paste0("openwashdata/", pkg, "/main/inst/extdata/"), urls, fixed = TRUE)))
  expect_false(any(grepl("openwashdata/trips/", urls, fixed = TRUE)))
})

test_that("update_metadata() prefixes variables by dataset when there are several", {
  create_metadata_fixture()
  d <- suppressMessages(update_metadata())
  names <- vapply(d$variableMeasured, function(x) x$name, character(1))
  expect_identical(names, c("trips.id", "trips.volume", "trucks.plate"))
  expect_identical(d$variableMeasured[[2]]$description, "Volume in litres")
  expect_null(d$variableMeasured[[3]]$description)
})

test_that("update_metadata() writes the pkgdown template and is idempotent", {
  create_metadata_fixture()
  target <- file.path("pkgdown", "templates", "in-header.html")
  suppressMessages(update_metadata())
  expect_true(file.exists(target))
  lines <- readLines(target)
  expect_identical(lines[[1]], "{{#includes}}{{{in_header}}}{{/includes}}")
  expect_true(any(grepl("application/ld+json", lines, fixed = TRUE)))
  expect_true("^pkgdown$" %in% readLines(".Rbuildignore"))
  before <- tools::md5sum(target)
  withr::local_options(usethis.quiet = FALSE)
  expect_message(update_metadata(), "up to date")
  expect_identical(tools::md5sum(target), before)
  # no staging folder and no inst/extdata/metadata.json
  expect_false(dir.exists(file.path("data", "metadata")))
  expect_false(file.exists(file.path("inst", "extdata", "metadata.json")))
})

test_that("update_metadata() reports the blank fields and where to fill them", {
  create_metadata_fixture(complete = FALSE)
  d <- suppressMessages(update_metadata())
  blank <- attr(d, "blank")
  expect_true(all(c("datePublished", "keywords", "spatialCoverage", "temporalCoverage",
                    "identifier (DOI)", "variable descriptions") %in% names(blank)))
  expect_match(blank[["spatialCoverage"]], "X-schema.org-spatialCoverage", fixed = TRUE)
  expect_null(d$datePublished)
  expect_null(d$sameAs)
  withr::with_options(list(usethis.quiet = FALSE),
                      expect_message(update_metadata(), "still blank"))
  full <- create_metadata_fixture()
  blank_full <- attr(suppressMessages(update_metadata()), "blank")
  expect_identical(names(blank_full), "variable descriptions")
})

test_that("update_metadata() stops without a dictionary", {
  create_local_package()
  rlang::local_interactive(FALSE)
  expect_error(update_metadata(), "Dictionary")
})

test_that("the JSON-LD parses and the embedded site head carries it (#68)", {
  skip_on_cran()
  skip_if_not(rmarkdown::pandoc_available("2.0"))
  create_metadata_fixture()
  suppressMessages(update_metadata())
  json <- readLines(file.path("pkgdown", "templates", "in-header.html"))
  json <- json[-(1:3)]
  json <- json[-length(json)]
  parsed <- jsonlite::fromJSON(paste(json, collapse = "\n"))
  expect_identical(parsed[["@type"]], "Dataset")
  usethis::use_template("_pkgdown.yml", save_as = "_pkgdown.yml",
                        data = list(name = desc::desc_get("Package")[[1]]),
                        ignore = FALSE, open = FALSE, package = "washr")
  writeLines("# Fixture", "README.md")
  # the home page alone proves the head template; a full build would try to
  # attach the fixture package for the reference examples
  suppressMessages({
    pkgdown::init_site()
    pkgdown::build_home(preview = FALSE, quiet = TRUE)
  })
  head <- readLines(file.path("docs", "index.html"))
  expect_true(any(grepl("application/ld+json", head, fixed = TRUE)))
  expect_true(any(grepl("plausible.io", head, fixed = TRUE)))
})
