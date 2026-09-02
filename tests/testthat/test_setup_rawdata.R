options(usethis.quiet = TRUE)

test_that("setup_rawdata() writes the processing script from the template with the package name filled in", {
  pkg <- create_local_package()
  rlang::local_interactive(FALSE)
  setup_rawdata()
  script_path <- file.path("data-raw", "data_processing.R")
  expect_true(file.exists(script_path))
  script <- readLines(script_path)
  expect_false(any(grepl("{{{", script, fixed = TRUE)))
  expect_true(any(grepl(paste0("use_data(", basename(pkg)), script, fixed = TRUE)))
  expect_true("^data-raw$" %in% readLines(".Rbuildignore"))
})

test_that("setup_rawdata() re-run leaves an unchanged script alone", {
  create_local_package()
  rlang::local_interactive(FALSE)
  setup_rawdata()
  before <- tools::md5sum(file.path("data-raw", "data_processing.R"))
  expect_no_error(setup_rawdata())
  expect_identical(tools::md5sum(file.path("data-raw", "data_processing.R")), before)
})

test_that("setup_rawdata() stops outside a package", {
  withr::local_dir(withr::local_tempdir())
  expect_error(setup_rawdata(), "not in the correct working directory")
})
