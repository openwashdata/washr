options(usethis.quiet = TRUE)

# TEST update_description ------------------------------------------------------
test_that("update_description() sets the openwashdata fields", {
  create_local_package()
  rlang::local_interactive(FALSE)
  pkgname <- desc::desc_get("Package")[[1]]
  update_description()
  expect_equal(desc::desc_get("Language")[[1]], "en-GB")
  expect_equal(desc::desc_get("LazyData")[[1]], "true")
  expect_equal(desc::desc_get("Date")[[1]], as.character(Sys.Date()))
  expect_true(paste0("https://github.com/openwashdata/", pkgname)
              %in% desc::desc_get_urls())
  expect_equal(desc::desc_get("BugReports")[[1]],
               paste0("https://github.com/openwashdata/", pkgname, "/issues"))
})

test_that("update_description() sets CC BY 4.0 when no license is present", {
  create_local_package()
  rlang::local_interactive(FALSE)
  update_description()
  expect_equal(desc::desc_get("License")[[1]], "CC BY 4.0")
})

test_that("update_description() preserves an existing license (#63)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  desc::desc_set("License", "GPL (>= 3)")
  update_description()
  expect_equal(desc::desc_get("License")[[1]], "GPL (>= 3)")
  expect_false(file.exists("LICENSE.md"))
})

test_that("update_description() preserves existing URL entries (#63)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  desc::desc_set_urls("https://openwashdata.github.io/testpkg/")
  update_description()
  urls <- desc::desc_get_urls()
  expect_true("https://openwashdata.github.io/testpkg/" %in% urls)
  expect_true(any(grepl("github.com/openwashdata/", urls, fixed = TRUE)))
})

test_that("update_description() merges Config/Needs/website entries (#59)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  desc::desc_set("Config/Needs/website",
                 "rmarkdown, leaflet, htmlwidgets, webshot2")
  update_description()
  entries <- trimws(strsplit(desc::desc_get_field("Config/Needs/website"),
                             ",")[[1]])
  expect_setequal(entries,
                  c("rmarkdown", "leaflet", "htmlwidgets", "webshot2"))
})

test_that("update_description() honors the file argument (#63)", {
  pkg <- create_local_package()
  rlang::local_interactive(FALSE)
  desc::desc_set("License", "GPL (>= 3)")
  withr::local_dir(withr::local_tempdir())
  expect_no_error(update_description(file = pkg))
  expect_equal(desc::desc_get("Language", file = pkg)[[1]], "en-GB")
})

test_that("DESCRIPTION full-file snapshot (#65)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  desc::desc_set("Config/Needs/website", "rmarkdown, leaflet")
  desc::desc_set_urls("https://openwashdata.github.io/testpkg/")
  update_description()
  pkgname <- desc::desc_get("Package")[[1]]
  lines <- readLines("DESCRIPTION")
  lines <- gsub(pkgname, "PKGNAME", lines, fixed = TRUE)
  lines <- gsub(as.character(Sys.Date()), "YYYY-MM-DD", lines, fixed = TRUE)
  lines <- sub("^RoxygenNote:.*$", "RoxygenNote: SCRUBBED", lines)
  expect_snapshot(cat(lines, sep = "\n"))
})
