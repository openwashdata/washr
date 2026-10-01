options(usethis.quiet = TRUE)

# A package with one data object and a filled dictionary.
ui_fixture <- function(env = parent.frame()) {
  create_local_package(env = env)
  rlang::local_interactive(FALSE, frame = env)
  desc::desc_set(Title = "One table", Description = "A fixture with one table.")
  desc::desc_set_authors(utils::person("Jane", "Doe", email = "jane@example.org",
                                       role = c("aut", "cre")))
  trips <- data.frame(id = 1:3, volume = c(1.5, 2, 3.25))
  usethis::use_data(trips)
  invisible(NULL)
}

test_that("every function returns the path it wrote, invisibly (#84)", {
  ui_fixture()
  suppressMessages({
    expect_invisible(rawdata <- setup_rawdata())
    expect_invisible(dictionary <- setup_dictionary())
    dict <- utils::read.csv(dictionary)
    dict$description <- paste("Describes", dict$variable_name)
    utils::write.csv(dict, dictionary, row.names = FALSE)
    expect_invisible(roxygen <- setup_roxygen())
    expect_invisible(description <- update_description())
    expect_invisible(citation <- update_citation(build = FALSE))
    expect_invisible(readme <- setup_readme())
  })
  expect_identical(rawdata, file.path("data-raw", "data_processing.R"))
  expect_identical(dictionary, file.path("data-raw", "dictionary.csv"))
  expect_identical(basename(roxygen), "trips.R")
  expect_identical(description, file.path(".", "DESCRIPTION"))
  expect_identical(citation, c("CITATION.cff", file.path("inst", "CITATION"), ".zenodo.json"))
  expect_identical(readme, "README.Rmd")
  expect_true(all(file.exists(c(rawdata, dictionary, roxygen, description, citation, readme))))
})

test_that("messages are cli conditions that name the file written (#84)", {
  ui_fixture()
  expect_message(update_description(), "Updated", class = "cliMessage")
  expect_message(setup_ci(), "R-CMD-check.yaml", class = "cliMessage")
})

test_that("washr.quiet silences messages and keeps errors (#84)", {
  ui_fixture()
  withr::local_options(washr.quiet = TRUE, usethis.quiet = FALSE)
  expect_no_message(setup_ci())
  expect_no_message(setup_rawdata())
  expect_no_message(update_description())
  expect_no_message(setup_dictionary())
  expect_error(setup_dictionary(), "already exists")
  expect_error(update_metadata(), NA)
  expect_no_message(update_metadata())
})

test_that("check_pkg_root() names the function the user called (#84)", {
  withr::local_dir(withr::local_tempdir())
  err <- rlang::catch_cnd(setup_ci(), "error")
  expect_match(conditionMessage(err), "not in the correct working directory")
  expect_identical(as.character(err$call[[1]]), "setup_ci")
})
