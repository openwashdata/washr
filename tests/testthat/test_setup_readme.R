options(usethis.quiet = TRUE)
# TEST setup_readme ------------------------------------------------------------
test_that("setup_readme() stops before writing when data/ holds no data object (#74)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  expect_error(setup_readme(), "No data object")
  expect_false(file.exists("README.Rmd"))
})

test_that("setup_readme runs when there is data objects", {
  create_local_package()
  rlang::local_interactive(FALSE)
  d1 <- data.frame(id = 1:3, name = c("A", "B", "C"))
  usethis::use_data(d1)
  expect_no_error(setup_readme())
})

test_that("setup_readme refuses to overwrite an existing README.Rmd (#64)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  d1 <- data.frame(id = 1:3, name = c("A", "B", "C"))
  usethis::use_data(d1)
  writeLines(c("# HAND-WRITTEN README", "do not lose this"), "README.Rmd")
  before <- readLines("README.Rmd")
  expect_error(setup_readme(), "force")
  expect_identical(readLines("README.Rmd"), before)
})

test_that("setup_readme(force = TRUE) overwrites an existing README.Rmd", {
  create_local_package()
  rlang::local_interactive(FALSE)
  d1 <- data.frame(id = 1:3, name = c("A", "B", "C"))
  usethis::use_data(d1)
  writeLines("# OLD README", "README.Rmd")
  expect_no_error(setup_readme(force = TRUE))
  expect_false(identical(readLines("README.Rmd"), "# OLD README"))
})

test_that("setup_readme() substitutes the package name in the license link (#101)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  d1 <- data.frame(id = 1:3, name = c("A", "B", "C"))
  usethis::use_data(d1)
  setup_readme()
  license <- grep("LICENSE.md", readLines("README.Rmd"), fixed = TRUE, value = TRUE)
  expect_length(license, 1)
  expect_false(grepl("%7B", license, fixed = TRUE))
  expect_match(license,
               paste0("openwashdata/", desc::desc_get("Package"), "/blob/main/LICENSE.md"),
               fixed = TRUE)
})

test_that("setup_readme(has_example = TRUE) adds the Example section with a ggplot2 scaffold (#74)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  d1 <- data.frame(id = 1:3, name = c("A", "B", "C"))
  usethis::use_data(d1)
  setup_readme(has_example = TRUE)
  readme <- readLines("README.Rmd")
  expect_true("## Example" %in% readme)
  expect_true(any(grepl("# d1 |>", readme, fixed = TRUE)))
  expect_true(any(grepl("ggplot(aes(", readme, fixed = TRUE)))
  expect_false(any(grepl("{{{", readme, fixed = TRUE)))
})

test_that("setup_readme() omits the Example section by default and documents the first data object (#74)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  zebra <- data.frame(id = 1)
  apple <- data.frame(id = 1)
  usethis::use_data(zebra, apple)
  withr::with_options(list(usethis.quiet = FALSE),
                      expect_message(setup_readme(), "2 data objects"))
  readme <- readLines("README.Rmd")
  expect_false("## Example" %in% readme)
  expect_true(any(grepl("### apple", readme, fixed = TRUE)))
  expect_false(any(grepl("{{{", readme, fixed = TRUE)))
})
