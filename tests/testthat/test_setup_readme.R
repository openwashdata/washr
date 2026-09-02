options(usethis.quiet = TRUE)
# TEST setup_readme ------------------------------------------------------------
test_that("setup_readme throws a warning when no tidy dataset available in data/", {
  create_local_package()
  rlang::local_interactive(FALSE)
  expect_warning(setup_readme())
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
