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

test_that("setup_rawdata() exports one dataset through the loop by default (#103)", {
  pkg <- create_local_package()
  rlang::local_interactive(FALSE)
  setup_rawdata()
  script <- readLines(file.path("data-raw", "data_processing.R"))
  name <- basename(pkg)
  expect_identical(grep("use_data(", script, fixed = TRUE, value = TRUE),
                   paste0("usethis::use_data(", name, ", overwrite = TRUE)"))
  expect_true(paste0('for (name in c("', name, '")) {') %in% script)
  expect_true(any(grepl("readr::write_csv(obj,", script, fixed = TRUE)))
  expect_true(any(grepl("openxlsx::write.xlsx(obj,", script, fixed = TRUE)))
  expect_no_error(parse(text = script))
})

test_that("setup_rawdata(datasets = ) writes a use_data() line per dataset and loops over the names (#103)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  setup_rawdata(datasets = c("trips", "trucks"))
  script <- readLines(file.path("data-raw", "data_processing.R"))
  expect_identical(grep("use_data(", script, fixed = TRUE, value = TRUE),
                   c("usethis::use_data(trips, overwrite = TRUE)",
                     "usethis::use_data(trucks, overwrite = TRUE)"))
  expect_true('for (name in c("trips", "trucks")) {' %in% script)
  expect_false(any(grepl("{{", script, fixed = TRUE)))
  expect_no_error(parse(text = script))
})

test_that("setup_rawdata() stops on a dataset name that is not a valid R name and writes nothing (#103)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  expect_error(setup_rawdata(datasets = c("trips", "2trucks")), "not a valid R name")
  expect_error(setup_rawdata(datasets = "truck trips"), "truck.trips", fixed = TRUE)
  expect_error(setup_rawdata(datasets = c("trips", "trips")), "more than once")
  expect_error(setup_rawdata(datasets = character()), "character vector")
  expect_false(file.exists(file.path("data-raw", "data_processing.R")))
})

test_that("setup_rawdata() does not read data/ (#103)", {
  pkg <- create_local_package()
  rlang::local_interactive(FALSE)
  trips <- data.frame(id = 1:2)
  usethis::use_data(trips)
  setup_rawdata()
  script <- readLines(file.path("data-raw", "data_processing.R"))
  expect_identical(grep("use_data(", script, fixed = TRUE, value = TRUE),
                   paste0("usethis::use_data(", basename(pkg), ", overwrite = TRUE)"))
})
