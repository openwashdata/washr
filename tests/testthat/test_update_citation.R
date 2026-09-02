options(usethis.quiet = TRUE)

# TEST update_citation ---------------------------------------------------------
test_that("update_citation() runs without a doi (#57)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  desc::desc_set("Date", "2026-07-23")
  expect_no_error(suppressMessages(update_citation()))
  expect_true(file.exists("CITATION.cff"))
  expect_true(file.exists(file.path("inst", "CITATION")))
  expect_false(any(grepl("^doi:", readLines("CITATION.cff"))))
})

test_that("update_citation(doi = NULL) does not inject an empty DOI badge (#58)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  desc::desc_set("Date", "2026-07-23")
  writeLines(c("# pkg", "<!-- badges: start -->", "<!-- badges: end -->"),
             "README.Rmd")
  suppressMessages(update_citation(doi = NULL))
  expect_false(any(grepl("zenodo.org/badge/DOI", readLines("README.Rmd"),
                         fixed = TRUE)))
})

test_that("update_citation() leaves no .bk1 backup files behind (#60)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  desc::desc_set("Date", "2026-07-23")
  suppressMessages(update_citation(doi = "10.5281/zenodo.11185699"))
  suppressMessages(update_citation(doi = "10.5281/zenodo.11185699"))
  expect_length(list.files(".", pattern = "\\.bk[0-9]+$", recursive = TRUE), 0)
})

test_that("update_citation() adds CITATION.cff to .Rbuildignore (#102)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  desc::desc_set("Date", "2026-07-23")
  suppressMessages(update_citation())
  expect_true(file.exists(".Rbuildignore"))
  expect_true("^CITATION\\.cff$" %in% readLines(".Rbuildignore"))
  suppressMessages(update_citation())
  expect_length(grep("CITATION", readLines(".Rbuildignore"), fixed = TRUE), 1)
})

test_that("add_citation_badge() errors clearly without the badges-end marker", {
  create_local_package()
  writeLines(c("# pkg", "no badge markers here"), "README.Rmd")
  expect_error(add_citation_badge("10.5281/zenodo.11185699"), "badges: end")
})

test_that("add_citation_badge() replaces an existing DOI badge instead of duplicating", {
  create_local_package()
  writeLines(c("# pkg", "<!-- badges: start -->", "<!-- badges: end -->"),
             "README.Rmd")
  add_citation_badge("10.5281/zenodo.111")
  add_citation_badge("10.5281/zenodo.222")
  badges <- grep("zenodo.org/badge/DOI", readLines("README.Rmd"),
                 fixed = TRUE, value = TRUE)
  expect_length(badges, 1)
  expect_match(badges, "zenodo.222", fixed = TRUE)
})

test_that("add_citation_badge() heals a broken empty badge left by 1.0.1 (#58)", {
  create_local_package()
  writeLines(c("# pkg", "<!-- badges: start -->",
               "[![DOI](https://zenodo.org/badge/DOI/.svg)](https://zenodo.org/doi/)",
               "<!-- badges: end -->"),
             "README.Rmd")
  add_citation_badge("10.5281/zenodo.333")
  badges <- grep("zenodo.org/badge/DOI", readLines("README.Rmd"),
                 fixed = TRUE, value = TRUE)
  expect_length(badges, 1)
  expect_match(badges, "zenodo.333", fixed = TRUE)
})

test_that("CITATION.cff full-file snapshot (#65)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  desc::desc_set("Date", "2026-07-23")
  suppressMessages(update_citation(doi = "10.5281/zenodo.11185699"))
  pkgname <- desc::desc_get("Package")[[1]]
  cff <- gsub(pkgname, "PKGNAME", readLines("CITATION.cff"), fixed = TRUE)
  expect_snapshot(cat(cff, sep = "\n"))
})
