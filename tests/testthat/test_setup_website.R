options(usethis.quiet = TRUE)
# TEST setup_website -----------------------------------------------------------
test_that("setup_website throws an error when no README file available", {
  create_local_package()
  rlang::local_interactive(FALSE)
  expect_error(setup_website())
})

# The site build is mocked: these tests cover the file handling around it.
website_fixture <- function(env = parent.frame(), datasets = TRUE) {
  create_local_package(env = env)
  rlang::local_interactive(FALSE, frame = env)
  writeLines("# Fixture", "README.md")
  if (datasets) {
    trips <- data.frame(id = 1:2)
    trucks <- data.frame(plate = "UAX 1")
    usethis::use_data(trips, trucks)
  }
  testthat::local_mocked_bindings(build_site = function(...) invisible(NULL), .package = "pkgdown", .env = env)
  invisible(desc::desc_get("Package")[[1]])
}

test_that("setup_website() writes the template with the Pages URL and one reference entry per dataset", {
  pkg <- website_fixture()
  setup_website()
  config <- readLines("_pkgdown.yml")
  expect_true(any(grepl(paste0("^url: https://openwashdata.github.io/", pkg, "/$"), config)))
  expect_true(any(grepl(paste0("href: https://github.com/openwashdata/", pkg, "$"), config)))
  expect_true(any(grepl("^  - trips$", config)))
  expect_true(any(grepl("^  - trucks$", config)))
  parsed <- yaml::read_yaml("_pkgdown.yml")
  expect_identical(parsed$reference[[1]]$contents, c("trips", "trucks"))
  expect_false("docs" %in% readLines(".gitignore"))
})

test_that("setup_website() writes no reference block without data objects", {
  website_fixture(datasets = FALSE)
  setup_website()
  expect_null(yaml::read_yaml("_pkgdown.yml")$reference)
})

test_that("setup_website() keeps an existing _pkgdown.yml untouched on re-run (#73)", {
  website_fixture()
  writeLines(c("url: https://example.org/", "template:", "  bootstrap: 5", "# hand edited"), "_pkgdown.yml")
  before <- tools::md5sum("_pkgdown.yml")
  withr::with_options(list(usethis.quiet = FALSE),
                      expect_message(setup_website(), "kept as it is"))
  expect_identical(tools::md5sum("_pkgdown.yml"), before)
})

test_that("setup_website() survives a missing .gitignore (#73)", {
  website_fixture()
  writeLines("url: https://example.org/", "_pkgdown.yml")
  if (file.exists(".gitignore")) file.remove(".gitignore")
  expect_no_error(setup_website())
  expect_false(file.exists(".gitignore"))
})

test_that("setup_website() leaves docs ignored when a pkgdown workflow deploys the site (#104)", {
  website_fixture()
  dir.create(file.path(".github", "workflows"), recursive = TRUE)
  writeLines("name: pkgdown", file.path(".github", "workflows", "pkgdown.yaml"))
  setup_website()
  expect_true("docs" %in% readLines(".gitignore"))
  # explicit override wins
  setup_website(track_docs = TRUE)
  expect_false("docs" %in% readLines(".gitignore"))
})

test_that("setup_website(track_docs = FALSE) keeps docs ignored without a workflow (#104)", {
  website_fixture()
  setup_website(track_docs = FALSE)
  expect_true("docs" %in% readLines(".gitignore"))
})
