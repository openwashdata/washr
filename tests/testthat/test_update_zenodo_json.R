options(usethis.quiet = TRUE)

# A data package with a person who has an ORCID and an affiliation, a person
# with two given names, an organisation as author, and a contributor and a
# funder that do not belong among the creators.
create_zenodo_fixture <- function(env = parent.frame()) {
  create_local_package(env = env)
  rlang::local_interactive(FALSE, frame = env)
  pkg <- desc::desc_get("Package")[[1]]
  desc::desc_set(
    Title = "Trips and trucks in Kampala",
    Description = "Faecal sludge logistics data from Kampala. Two tables.",
    License = "CC BY 4.0",
    Date = "2026-07-08",
    URL = paste0("https://github.com/openwashdata/", pkg, ", https://openwashdata.github.io/", pkg, "/"),
    `X-schema.org-keywords` = "sanitation, faecal sludge, Kampala"
  )
  desc::desc_set_authors(c(
    utils::person("Jane", "Doe", email = "jane@example.org", role = c("aut", "cre"),
                  comment = c(ORCID = "0000-0002-1825-0097", affiliation = "ETH Zurich")),
    utils::person(c("Ana", "María"), "Götsch", role = "aut",
                  comment = c(ORCID = "https://orcid.org/0000-0001-5109-3700")),
    utils::person("Kampala Capital City Authority", role = "aut"),
    utils::person("Sam", "Helper", role = "ctb"),
    utils::person("Global Health Engineering, ETH Zurich", role = "fnd")
  ))
  invisible(pkg)
}

read_zenodo_json <- function() {
  jsonlite::fromJSON(".zenodo.json", simplifyVector = FALSE)
}

test_that("update_zenodo_json() derives the deposit metadata from DESCRIPTION (#56)", {
  create_zenodo_fixture()
  suppressMessages(update_zenodo_json())
  z <- read_zenodo_json()
  expect_identical(names(z), c("title", "description", "upload_type", "creators",
                               "license", "keywords", "version", "communities"))
  expect_identical(z$title, "Trips and trucks in Kampala")
  expect_identical(z$description, "Faecal sludge logistics data from Kampala. Two tables.")
  expect_identical(z$upload_type, "dataset")
  expect_identical(z$license, "cc-by-4.0")
  expect_identical(z$keywords, list("sanitation", "faecal sludge", "Kampala"))
  expect_identical(z$version, "0.0.0.9000")
  expect_identical(z$communities, list(list(identifier = "openwashdata")))
})

test_that("creators are the aut and cre roles, with ORCID and affiliation (#56)", {
  create_zenodo_fixture()
  suppressMessages(update_zenodo_json())
  creators <- read_zenodo_json()$creators
  expect_length(creators, 3)
  expect_identical(creators[[1]], list(name = "Doe, Jane", affiliation = "ETH Zurich",
                                       orcid = "0000-0002-1825-0097"))
  # two given names, non-ASCII characters, and an ORCID given as a URL
  expect_identical(creators[[2]], list(name = "Götsch, Ana María",
                                       orcid = "0000-0001-5109-3700"))
  # an organisation has no family name and keeps its name as it is
  expect_identical(creators[[3]], list(name = "Kampala Capital City Authority"))
})

test_that("the file is UTF-8 with LF line endings and a trailing newline (#56)", {
  create_zenodo_fixture()
  suppressMessages(update_zenodo_json())
  bytes <- readBin(".zenodo.json", "raw", file.size(".zenodo.json"))
  expect_identical(bytes[length(bytes)], charToRaw("\n"))
  expect_false(any(bytes == charToRaw("\r")))
  text <- rawToChar(bytes)
  Encoding(text) <- "UTF-8"
  expect_true(validUTF8(text))
  expect_match(text, "Götsch, Ana María", fixed = TRUE)
  expect_match(text, "^\\{\n  \"title\": ")
})

test_that("the License field maps to the identifier Zenodo uses (#56)", {
  create_zenodo_fixture()
  desc::desc_set("License", "MIT + file LICENSE")
  suppressMessages(update_zenodo_json())
  expect_identical(read_zenodo_json()$license, "mit")
  desc::desc_set("License", "GPL (>= 3)")
  suppressMessages(update_zenodo_json())
  expect_identical(read_zenodo_json()$license, "gpl-3.0-or-later")
  for (key in names(license_map)) {
    expect_named(license_map[[key]], c("url", "zenodo"))
    expect_identical(license_url(key), license_map[[key]][["url"]])
    expect_identical(license_zenodo(key), license_map[[key]][["zenodo"]])
  }
  expect_identical(license_url("Custom licence"), "Custom licence")
})

test_that("an unknown license is left out and the message says what Zenodo does (#56)", {
  create_zenodo_fixture()
  desc::desc_set("License", "file LICENSE")
  messages <- paste(capture_messages(update_zenodo_json()), collapse = " ")
  expect_match(gsub("\\s+", " ", messages), "has no license: .*CC0 1\\.0")
  expect_null(read_zenodo_json()$license)
})

test_that("a package without aut or cre has no creators key and says so (#56)", {
  create_zenodo_fixture()
  desc::desc_set_authors(utils::person("Global Health Engineering", role = "fnd"))
  messages <- paste(capture_messages(update_zenodo_json()), collapse = " ")
  expect_match(messages, "has no creators")
  expect_null(read_zenodo_json()$creators)
})

test_that("the community comes from Config/washr/zenodo-community (#56, #81)", {
  create_zenodo_fixture()
  desc::desc_set("Config/washr/zenodo-community", "global-health-engineering")
  suppressMessages(update_zenodo_json())
  expect_identical(read_zenodo_json()$communities,
                   list(list(identifier = "global-health-engineering")))
  desc::desc_set("Config/washr/zenodo-community", "openwashdata, ghe")
  suppressMessages(update_zenodo_json())
  expect_identical(read_zenodo_json()$communities,
                   list(list(identifier = "openwashdata"), list(identifier = "ghe")))
  desc::desc_set("Config/washr/zenodo-community", "none")
  suppressMessages(update_zenodo_json())
  expect_null(read_zenodo_json()$communities)
})

test_that("washr_config() reads Config/washr fields and falls back to the default (#81)", {
  create_local_package()
  expect_null(washr_config("zenodo-community"))
  expect_identical(washr_config("zenodo-community", default = "openwashdata"), "openwashdata")
  desc::desc_set("Config/washr/zenodo-community", "  ghe  ")
  expect_identical(washr_config("zenodo-community", default = "openwashdata"), "ghe")
  expect_identical(washr_config("zenodo-community", file = "DESCRIPTION"), "ghe")
  expect_identical(washr_config("zenodo-community", file = getwd()), "ghe")
  # an empty field counts as absent
  lines <- readLines("DESCRIPTION")
  lines[startsWith(lines, "Config/washr/zenodo-community:")] <- "Config/washr/zenodo-community:"
  writeLines(lines, "DESCRIPTION")
  expect_identical(washr_config("zenodo-community", default = "openwashdata"), "openwashdata")
})

test_that("source articles become related identifiers next to the repository (#56, #134)", {
  pkg <- create_zenodo_fixture()
  suppressMessages(update_zenodo_json())
  # without a source Zenodo keeps its own link to the release tag
  expect_null(read_zenodo_json()$related_identifiers)
  desc::desc_set("X-schema.org-isBasedOn",
                 "https://doi.org/10.2166/wh.2026.173, 10.5281/zenodo.11185699")
  suppressMessages(update_zenodo_json())
  expect_identical(read_zenodo_json()$related_identifiers, list(
    list(identifier = paste0("https://github.com/openwashdata/", pkg), relation = "isSupplementTo"),
    list(identifier = "10.2166/wh.2026.173", relation = "isDerivedFrom"),
    list(identifier = "10.5281/zenodo.11185699", relation = "isDerivedFrom")
  ))
})

test_that("update_zenodo_json() is idempotent and build ignores the file (#56)", {
  create_zenodo_fixture()
  expect_message(update_zenodo_json(), "Wrote")
  first <- tools::md5sum(".zenodo.json")
  stamp <- file.mtime(".zenodo.json")
  expect_message(update_zenodo_json(), "up to date")
  expect_identical(tools::md5sum(".zenodo.json"), first)
  expect_identical(file.mtime(".zenodo.json"), stamp)
  expect_identical(sum(readLines(".Rbuildignore") == "^\\.zenodo\\.json$"), 1L)
})

test_that("update_zenodo_json() returns the path invisibly and respects washr.quiet (#56, #84)", {
  create_zenodo_fixture()
  suppressMessages(expect_invisible(path <- update_zenodo_json()))
  expect_identical(path, ".zenodo.json")
  desc::desc_set("License", "file LICENSE")
  withr::local_options(washr.quiet = TRUE, usethis.quiet = FALSE)
  expect_no_message(update_zenodo_json())
})

test_that("update_zenodo_json() stops outside a package (#56)", {
  withr::local_dir(withr::local_tempdir())
  expect_error(update_zenodo_json(), "No DESCRIPTION file found")
})

test_that("update_citation() writes .zenodo.json with the citation files (#56)", {
  create_zenodo_fixture()
  local_mocked_bindings(fetch_doi_csl = function(doi) NULL)
  desc::desc_set("X-schema.org-isBasedOn", "10.2166/wh.2026.173")
  paths <- suppressWarnings(suppressMessages(update_citation(build = FALSE)))
  expect_identical(paths, c("CITATION.cff", file.path("inst", "CITATION"), ".zenodo.json"))
  expect_true(all(file.exists(paths)))
  z <- read_zenodo_json()
  expect_identical(z$upload_type, "dataset")
  # the source is listed even when its lookup for CITATION.cff failed
  expect_identical(z$related_identifiers[[2]]$identifier, "10.2166/wh.2026.173")
  # a second run changes neither file
  before <- tools::md5sum(c("CITATION.cff", ".zenodo.json"))
  suppressWarnings(suppressMessages(update_citation(build = FALSE)))
  expect_identical(tools::md5sum(c("CITATION.cff", ".zenodo.json")), before)
})
