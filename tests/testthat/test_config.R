options(usethis.quiet = TRUE)

# A package with one data object, ready for the publishing steps.
config_fixture <- function(env = parent.frame()) {
  create_local_package(env = env)
  rlang::local_interactive(FALSE, frame = env)
  desc::desc_set(Title = "One table", Description = "A fixture with one table.")
  desc::desc_set_authors(utils::person("Jane", "Doe", email = "jane@example.org",
                                       role = c("aut", "cre")))
  trips <- data.frame(id = 1:3, volume = c(1.5, 2, 3.25))
  usethis::use_data(trips)
  invisible(desc::desc_get("Package")[[1]])
}

test_that("update_description() writes the Config/washr fields with the openwashdata defaults (#81)", {
  config_fixture()
  suppressMessages(update_description())
  expect_match(washr_config("funding"), "Open Research Data Program of the ETH Board", fixed = TRUE)
  expect_identical(washr_config("analytics-domain"), "openwashdata.github.io")
  expect_identical(washr_config("doi-provider"), "zenodo")
  expect_identical(washr_config("zenodo-community"), "openwashdata")
  expect_identical(washr_config("brand-source"), "openwashdata/brand")
  expect_identical(washr_config("version"), as.character(utils::packageVersion("washr")))
})

test_that("update_description() keeps edited fields and Config entries it does not own (#81)", {
  config_fixture()
  desc::desc_set(`Config/washr/funding` = "Funded by the Example Foundation.",
                 `Config/washr/analytics-domain` = "none",
                 `Config/other/setting` = "kept",
                 `Config/testthat/parallel` = "true")
  suppressMessages(update_description())
  suppressMessages(update_description())
  expect_identical(washr_config("funding"), "Funded by the Example Foundation.")
  expect_identical(washr_config("analytics-domain"), "none")
  expect_identical(desc::desc_get_field("Config/other/setting"), "kept")
  expect_identical(desc::desc_get_field("Config/testthat/parallel"), "true")
})

test_that("update_description() takes the organisation from URL and writes none for another one (#81)", {
  pkg <- config_fixture()
  desc::desc_set_urls(paste0("https://github.com/exampleorg/", pkg))
  expect_message(update_description(), "Config/washr/funding")
  expect_identical(github_repo_url(), paste0("https://github.com/exampleorg/", pkg))
  expect_length(desc::desc_get_urls(), 1)
  expect_identical(desc::desc_get_field("BugReports"),
                   paste0("https://github.com/exampleorg/", pkg, "/issues"))
  expect_identical(washr_config("funding"), "none")
  expect_identical(washr_config("analytics-domain"), "none")
  expect_identical(washr_config("zenodo-community"), "none")
  expect_identical(washr_config("brand-source"), "none")
  expect_identical(washr_config("doi-provider"), "zenodo")
})

test_that("update_description(github_user = ) still names the organisation (#81)", {
  pkg <- config_fixture()
  suppressMessages(update_description(github_user = "https://github.com/exampleorg"))
  expect_identical(pkg_org(), "exampleorg")
  expect_identical(pkg_repo_url(), paste0("https://github.com/exampleorg/", pkg))
  expect_identical(pkg_pages_url(), paste0("https://exampleorg.github.io/", pkg, "/"))
})

test_that("the pkgdown template reads its values from DESCRIPTION (#81)", {
  pkg <- config_fixture()
  render <- function() {
    unlink("_pkgdown.yml")
    usethis::use_template("_pkgdown.yml", save_as = "_pkgdown.yml",
                          data = pkgdown_template_data(), package = "washr")
    yaml::read_yaml("_pkgdown.yml")
  }

  suppressMessages(update_description())
  owd <- render()
  expect_identical(owd$url, paste0("https://openwashdata.github.io/", pkg, "/"))
  expect_identical(owd$home$links[[1]]$href, paste0("https://github.com/openwashdata/", pkg))
  expect_match(owd$template$includes$in_header, 'data-domain="openwashdata.github.io"', fixed = TRUE)
  expect_match(owd$home$sidebar$components$custom$text, "ETH Board", fixed = TRUE)
  expect_true(any(grepl(washr_defaults()[["funding"]], readLines("_pkgdown.yml"), fixed = TRUE)))

  desc::desc_set_urls(paste0("https://github.com/exampleorg/", pkg))
  desc::desc_set(`Config/washr/funding` = "Funded by: the \"Example\" Foundation.",
                 `Config/washr/analytics-domain` = "none",
                 `Config/washr/pages-domain` = "data.example.org")
  other <- render()
  expect_identical(other$url, paste0("https://data.example.org/", pkg, "/"))
  expect_identical(other$home$links[[1]]$href, paste0("https://github.com/exampleorg/", pkg))
  expect_null(other$template$includes)
  expect_identical(other$home$sidebar$components$custom$text,
                   "Funded by: the \"Example\" Foundation.")

  desc::desc_set(`Config/washr/funding` = "none")
  expect_null(render()$home$sidebar)
})

test_that("the README template reads the repository and the license from DESCRIPTION (#81)", {
  pkg <- config_fixture()
  suppressMessages(update_description())
  suppressMessages(setup_readme())
  owd <- readLines("README.Rmd")
  expect_true(any(grepl(paste0('install_github("openwashdata/', pkg, '")'), owd, fixed = TRUE)))
  expect_true(any(grepl("License-CC_BY_4.0-lightgrey", owd, fixed = TRUE)))
  expect_true(any(grepl(paste0("[CC-BY](https://github.com/openwashdata/", pkg, "/blob/main/LICENSE.md)"),
                        owd, fixed = TRUE)))

  desc::desc_set_urls(paste0("https://github.com/exampleorg/", pkg))
  desc::desc_set(License = "CC BY-SA 4.0")
  suppressMessages(setup_readme(force = TRUE))
  other <- readLines("README.Rmd")
  expect_false(any(grepl("openwashdata", other, fixed = TRUE)))
  expect_true(any(grepl(paste0('install_github("exampleorg/', pkg, '")'), other, fixed = TRUE)))
  expect_true(any(grepl(paste0("https://github.com/exampleorg/", pkg, "/raw/main/inst/extdata/"),
                        other, fixed = TRUE)))
  expect_true(any(grepl("[![License: CC BY-SA 4.0](https://img.shields.io/badge/License-CC_BY--SA_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-sa/4.0/)",
                        other, fixed = TRUE)))
  expect_true(any(grepl("[CC BY-SA 4.0](", other, fixed = TRUE)))
})

test_that("the DOI badge follows Config/washr/doi-provider (#81)", {
  config_fixture()
  expect_identical(
    doi_badge("10.5281/zenodo.11185699"),
    "[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.11185699.svg)](https://zenodo.org/doi/10.5281/zenodo.11185699)"
  )
  desc::desc_set(`Config/washr/doi-provider` = "datacite")
  expect_identical(
    doi_badge("10.1234/my-data_v1"),
    "[![DOI](https://img.shields.io/badge/DOI-10.1234%2Fmy--data__v1-blue.svg)](https://doi.org/10.1234/my-data_v1)"
  )
  writeLines(c("<!-- badges: start -->", "[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1.svg)](https://zenodo.org/doi/10.5281/zenodo.1)", "<!-- badges: end -->"),
             "README.Rmd")
  add_citation_badge("10.1234/my-data_v1")
  readme <- readLines("README.Rmd")
  expect_identical(sum(grepl("[![DOI](", readme, fixed = TRUE)), 1L)
  expect_true(any(grepl("https://doi.org/10.1234/my-data_v1", readme, fixed = TRUE)))
})

test_that("check_publication_readiness() holds a package to its own Config/washr values (#81)", {
  pkg <- config_fixture()
  desc::desc_set_urls(paste0("https://github.com/exampleorg/", pkg))
  suppressMessages(update_description())
  profile <- package_profile()
  expect_identical(profile$analytics, "none")
  expect_identical(profile$brand, "none")
  expect_null(profile$funding_text)
  expect_identical(profile$site_url_pattern, "https://exampleorg.github.io/<package>/")
  desc::desc_set(`Config/washr/funding` = "Funded by the Example Foundation.")
  expect_identical(package_profile()$funding_text, "Funded by the Example Foundation.")
})
