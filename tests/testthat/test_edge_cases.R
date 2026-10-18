options(usethis.quiet = TRUE)

# Cases found by the review of the 1.2.0 candidate. Each one failed before.

edge_fixture <- function(env = parent.frame(), data = TRUE) {
  create_local_package(env = env)
  rlang::local_interactive(FALSE, frame = env)
  desc::desc_set(Title = "One table", Description = "A fixture with one table.")
  desc::desc_set_authors(utils::person("Jane", "Doe", email = "jane@example.org",
                                       role = c("aut", "cre")))
  if (data) {
    trips <- data.frame(id = 1:3, volume = c(1.5, 2, 3.25))
    usethis::use_data(trips)
  }
  invisible(desc::desc_get("Package")[[1]])
}

test_that("naming another organisation after a first run moves the package there", {
  pkg <- edge_fixture()
  suppressMessages(update_description())
  desc::desc_set(`Config/washr/doi-provider` = "datacite")
  suppressMessages(update_description(github_user = "https://github.com/YourOrg/"))
  expect_identical(desc::desc_get_urls(), paste0("https://github.com/YourOrg/", pkg))
  expect_identical(pkg_org(), "YourOrg")
  expect_identical(pkg_pages_url(), paste0("https://yourorg.github.io/", pkg, "/"))
  expect_identical(desc::desc_get_field("BugReports"),
                   paste0("https://github.com/YourOrg/", pkg, "/issues"))
  expect_identical(washr_config("funding"), "none")
  expect_identical(washr_config("analytics-domain"), "none")
  expect_identical(washr_config("zenodo-community"), "none")
  expect_identical(washr_config("brand-source"), "none")
  # an edited field stays
  expect_identical(washr_config("doi-provider"), "datacite")
  expect_error(update_description(github_user = "yourorg"), "github_user")
})

test_that("every way of writing the repository gives the same organisation", {
  expect_identical(
    normalise_github_url(c("https://github.com/MyOrg/pkg.git", "https://github.com/MyOrg/pkg/",
                           "http://www.github.com/MyOrg/pkg", "https://github.com/MyOrg/pkg#readme",
                           "https://myorg.github.io/pkg/", "https://github.com/MyOrg")),
    c(rep("https://github.com/MyOrg/pkg", 4), NA, NA)
  )
  pkg <- edge_fixture()
  desc::desc_set_urls(paste0("https://github.com/MyOrg/", pkg, ".git"))
  suppressMessages(update_description())
  expect_length(desc::desc_get_urls(), 1)
  expect_identical(desc::desc_get_field("BugReports"),
                   paste0("https://github.com/MyOrg/", pkg, "/issues"))
  expect_identical(readme_template_data()$repo_slug, paste0("MyOrg/", pkg))
  suppressMessages(update_description())
  expect_length(desc::desc_get_urls(), 1)
})

test_that("each package gets its own files when only the working directory changes", {
  rlang::local_interactive(FALSE)
  root <- withr::local_tempdir()
  old_project <- tryCatch(usethis::proj_get(), error = function(e) NULL)
  withr::defer(usethis::proj_set(old_project, force = TRUE))
  for (name in c("pkga", "pkgb")) {
    usethis::create_package(file.path(root, name), open = FALSE, rstudio = FALSE,
                            check_name = FALSE)
  }
  withr::local_dir(file.path(root, "pkga"))
  suppressMessages({ setup_ci(); setup_rawdata(); update_zenodo_json() })
  setwd(file.path(root, "pkgb"))
  suppressMessages({ setup_ci(); setup_rawdata(); update_zenodo_json() })
  expect_true(file.exists(file.path(root, "pkgb", "data-raw", "data_processing.R")))
  ignored <- readLines(file.path(root, "pkgb", ".Rbuildignore"))
  expect_true(all(c("^\\.github$", "^data-raw$", "^\\.zenodo\\.json$") %in% ignored))
  expect_identical(sum(readLines(file.path(root, "pkga", ".Rbuildignore")) == "^data-raw$"), 1L)
})

test_that("setup_readme(force = TRUE) keeps README.Rmd when it cannot write a new one", {
  edge_fixture(data = FALSE)
  writeLines("# hand written", "README.Rmd")
  expect_error(setup_readme(force = TRUE), "No data object")
  expect_identical(readLines("README.Rmd"), "# hand written")
})

test_that("washr.quiet silences update_citation(), cffr included", {
  edge_fixture()
  withr::local_options(washr.quiet = TRUE, usethis.quiet = FALSE)
  expect_no_message(update_citation(build = FALSE))
  expect_true(file.exists("CITATION.cff"))
})

test_that("update_description() sets the license whichever way the file is named", {
  edge_fixture()
  suppressMessages(update_description(file = "DESCRIPTION"))
  expect_identical(desc::desc_get_field("License"), "CC BY 4.0")
})

test_that("a renamed data object prints what was written about its variables", {
  edge_fixture()
  suppressMessages({ setup_rawdata(); setup_dictionary() })
  dict_path <- file.path("data-raw", "dictionary.csv")
  dict <- utils::read.csv(dict_path)
  dict$description <- c("Trip identifier", "Volume emptied")
  utils::write.csv(dict, dict_path, row.names = FALSE)
  unlink(file.path("data", "trips.rda"))
  truck_trips <- data.frame(id = 1:3, volume = c(1.5, 2, 3.25))
  usethis::use_data(truck_trips)
  out <- paste(utils::capture.output(update_dictionary(), type = "message"), collapse = "\n")
  expect_match(out, "Trip identifier", fixed = TRUE)
  expect_match(out, "Volume emptied", fixed = TRUE)
})

test_that("the readiness report covers each data object and reads the funding text as YAML does", {
  pkg <- edge_fixture()
  trucks <- data.frame(id = 1:2, plate = c("UAX 1", "UAX 2"))
  usethis::use_data(trucks)
  suppressMessages({ setup_rawdata(); setup_dictionary() })
  dict_path <- file.path("data-raw", "dictionary.csv")
  dict <- utils::read.csv(dict_path)
  dict$description <- "Described"
  utils::write.csv(dict[!(dict$file_name == "trucks.rda" & dict$variable_name == "id"), ],
                   dict_path, row.names = FALSE)
  check <- function(...) withr::with_options(list(washr.quiet = TRUE), check_publication_readiness(...))
  coverage <- check()
  expect_identical(coverage$status[coverage$id == "dictionary_coverage"], "fail")
  expect_match(coverage$detail[coverage$id == "dictionary_coverage"], "id", fixed = TRUE)

  funding <- "Funded by: the \"SNSF\" (grant #5)"
  desc::desc_set(`Config/washr/funding` = funding)
  usethis::use_template("_pkgdown.yml", save_as = "_pkgdown.yml",
                        data = pkgdown_template_data(), package = "washr")
  quoted <- check()
  expect_identical(quoted$status[quoted$id == "pkgdown_funding"], "pass")
  folded <- "This project was funded by the [Open Research Data Program of the ETH\n          Board](https://ethrat.ch/en/eth-domain/open-research-data/)."
  writeLines(c("url: https://openwashdata.github.io/x/", "home:", "  sidebar:", "    components:",
               "      custom:", "        title: Funding", paste0("        text: ", folded)),
             "_pkgdown.yml")
  wrapped <- check(profile = list(funding_text = washr_defaults()[["funding"]]))
  expect_identical(wrapped$status[wrapped$id == "pkgdown_funding"], "pass")
})

test_that("a package of another organisation is held to its own license", {
  pkg <- edge_fixture()
  desc::desc_set(License = "CC0")
  desc::desc_set_urls(paste0("https://github.com/exampleorg/", pkg))
  check <- function(...) withr::with_options(list(washr.quiet = TRUE), check_publication_readiness(...))
  own <- check()
  expect_identical(own$status[own$id == "license"], "pass")
  standard <- check(profile = list(analytics = "none"))
  expect_identical(standard$status[standard$id == "license"], "fail")
})
