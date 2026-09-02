options(usethis.quiet = TRUE)

# A package with two data objects, run through the re-runnable core sequence.
core_fixture <- function(env = parent.frame()) {
  create_local_package(env = env)
  rlang::local_interactive(FALSE, frame = env)
  pkg <- desc::desc_get("Package")[[1]]
  desc::desc_set(Title = "Two tables", Description = "A fixture with two tables.",
                 `X-schema.org-keywords` = "fixture, test")
  desc::desc_set_authors(utils::person("Jane", "Doe", email = "jane@example.org",
                                       role = c("aut", "cre")))
  trips <- data.frame(id = 1:3, volume = c(1.5, 2, 3.25))
  trucks <- data.frame(plate = c("UAX 1", "UAX 2"), seen = as.Date(c("2022-03-01", "2022-04-01")))
  usethis::use_data(trips, trucks)
  dir.create(file.path("inst", "extdata"), recursive = TRUE)
  writeLines("x", file.path("inst", "extdata", "trips.csv"))
  invisible(pkg)
}

tree_md5 <- function() {
  files <- list.files(".", recursive = TRUE, all.files = TRUE, full.names = TRUE)
  files <- files[!grepl("^\\./(docs|\\.git)/", files)]
  sums <- tools::md5sum(files)
  names(sums) <- files
  sums
}

test_that("the re-runnable core sequence produces no diff on a second run (#73)", {
  core_fixture()
  run <- function() {
    setup_rawdata()
    setup_roxygen()
    update_description()
    update_citation(doi = "10.5281/zenodo.11185699")
    update_metadata(quiet = TRUE)
  }
  setup_rawdata()
  setup_dictionary()
  dict <- utils::read.csv(file.path("data-raw", "dictionary.csv"))
  dict$description <- paste("Describes", dict$variable_name)
  utils::write.csv(dict, file.path("data-raw", "dictionary.csv"), row.names = FALSE)
  suppressMessages(run())
  first <- tree_md5()
  suppressMessages(run())
  second <- tree_md5()
  expect_identical(names(first), names(second))
  expect_identical(unname(first), unname(second))
})

test_that("setup_dictionary() and setup_readme() refuse to overwrite and lose nothing", {
  core_fixture()
  setup_rawdata()
  setup_dictionary()
  dict_path <- file.path("data-raw", "dictionary.csv")
  before <- readLines(dict_path)
  expect_error(setup_dictionary(), "already exists")
  expect_identical(readLines(dict_path), before)
  suppressWarnings(setup_readme())
  writeLines("# hand written", "README.Rmd")
  expect_error(setup_readme(), "force")
  expect_identical(readLines("README.Rmd"), "# hand written")
})
