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

test_that("update_citation() re-run without a doi keeps the DOI on file (#73)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  desc::desc_set("Date", "2026-07-23")
  suppressMessages(update_citation(doi = "10.5281/zenodo.11185699"))
  suppressMessages(update_citation())
  expect_identical(cffr::cff_read("CITATION.cff")$doi, "10.5281/zenodo.11185699")
})

test_that("update_citation() moves hand-added CITATION.cff keywords to DESCRIPTION and keeps them (#73)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  desc::desc_set("Date", "2026-07-23")
  suppressMessages(update_citation())
  cff <- readLines("CITATION.cff")
  writeLines(c(cff, "keywords:", "- sanitation", "- kampala"), "CITATION.cff")
  suppressMessages(update_citation())
  expect_identical(desc::desc_get_field("X-schema.org-keywords"), "sanitation, kampala")
  expect_identical(unlist(cffr::cff_read("CITATION.cff")$keywords), c("sanitation", "kampala"))
  # DESCRIPTION stays canonical on later runs (cffr pads a single keyword
  # with "r-package" to satisfy the CFF schema, so check membership)
  desc::desc_set("X-schema.org-keywords", "water")
  suppressMessages(update_citation())
  keywords <- unlist(cffr::cff_read("CITATION.cff")$keywords)
  expect_true("water" %in% keywords)
  expect_false(any(c("sanitation", "kampala") %in% keywords))
})

test_that("update_citation(build = FALSE) adds the badge but skips the README and site rebuilds (#75)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  desc::desc_set("Date", "2026-07-23")
  writeLines(c("# pkg", "<!-- badges: start -->", "<!-- badges: end -->"), "README.Rmd")
  suppressMessages(update_citation(doi = "10.5281/zenodo.11185699", build = FALSE))
  expect_true(any(grepl("zenodo.11185699.svg", readLines("README.Rmd"), fixed = TRUE)))
  expect_false(file.exists("README.md"))
})

test_that("update_citation() declares the work as a dataset in CITATION.cff (#56)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  desc::desc_set("Date", "2026-07-23")
  suppressMessages(update_citation())
  expect_equal(cffr::cff_read("CITATION.cff")$type, "dataset")
  suppressMessages(update_citation(type = "software"))
  expect_equal(cffr::cff_read("CITATION.cff")$type, "software")
})

# TEST source articles (#134) --------------------------------------------------
# CSL JSON as doi.org returns it for a Crossref journal article, with the
# markup and line breaks Crossref titles carry
csl_fixture <- function(doi = "10.2166/wh.2026.173") {
  list(type = "journal-article", DOI = doi,
       title = "Seasonal changes in <i>water</i> quality\n  properties",
       author = list(list(given = "Thulfiqar", family = "Al-Graiti",
                          ORCID = "http://orcid.org/0000-0002-5514-690X"),
                     list(given = "Hasan A.", family = "Qazmooz")),
       `container-title` = "Journal of Water and Health",
       volume = "24", issue = "4", page = "518-534",
       issued = list(`date-parts` = list(list(2026, 3, 18))))
}

test_that("update_citation() cites the source article from X-schema.org-isBasedOn (#134)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  local_mocked_bindings(fetch_doi_csl = function(doi) csl_fixture(doi))
  desc::desc_set("Date", "2026-07-23")
  desc::desc_set("X-schema.org-isBasedOn", "https://doi.org/10.2166/wh.2026.173")
  suppressMessages(update_citation(build = FALSE))
  expect_true(cffr::cff_validate("CITATION.cff", verbose = FALSE))
  cff <- cffr::cff_read("CITATION.cff")
  expect_null(cff$`preferred-citation`)
  expect_match(cff$message, "cite both the data package and the original article", fixed = TRUE)
  expect_length(cff$references, 1)
  ref <- cff$references[[1]]
  expect_identical(ref$type, "article")
  expect_identical(ref$doi, "10.2166/wh.2026.173")
  expect_identical(ref$title, "Seasonal changes in water quality properties")
  expect_identical(ref$journal, "Journal of Water and Health")
  expect_identical(ref$authors[[1]]$orcid, "https://orcid.org/0000-0002-5514-690X")
  # inst/CITATION holds the package and the article under the same header
  cit <- utils::readCitationFile(file.path("inst", "CITATION"), meta = list(Encoding = "UTF-8"))
  expect_length(cit, 2)
  expect_match(paste(readLines(file.path("inst", "CITATION")), collapse = "\n"),
               "citHeader(", fixed = TRUE)
})

test_that("update_citation() with a source article is idempotent and keeps the reference offline (#134)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  desc::desc_set("Date", "2026-07-23")
  desc::desc_set("X-schema.org-isBasedOn", "10.2166/wh.2026.173")
  local_mocked_bindings(fetch_doi_csl = function(doi) csl_fixture(doi))
  suppressMessages(update_citation(doi = "10.5281/zenodo.11185699", build = FALSE))
  first <- readLines("CITATION.cff")
  first_cit <- readLines(file.path("inst", "CITATION"))
  suppressMessages(update_citation(build = FALSE))
  expect_identical(readLines("CITATION.cff"), first)
  expect_identical(readLines(file.path("inst", "CITATION")), first_cit)
  # the lookup fails: the entry on file stays
  local_mocked_bindings(fetch_doi_csl = function(doi) NULL)
  suppressMessages(update_citation(build = FALSE))
  expect_identical(readLines("CITATION.cff"), first)
})

test_that("update_citation() leaves a source out when it cannot be looked up and nothing is on file (#134)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  desc::desc_set("Date", "2026-07-23")
  desc::desc_set("X-schema.org-isBasedOn", "10.2166/wh.2026.173")
  local_mocked_bindings(fetch_doi_csl = function(doi) NULL)
  expect_warning(suppressMessages(update_citation(build = FALSE)), "Could not look up")
  cff <- cffr::cff_read("CITATION.cff")
  expect_null(cff$references)
  expect_match(cff$message, "To cite package", fixed = TRUE)
})

test_that("update_citation() drops references that do not come from X-schema.org-isBasedOn (#134)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  desc::desc_set("Date", "2026-07-23")
  suppressMessages(update_citation(build = FALSE))
  # a hand-written second entry, as glaas carried one
  cat('\nbibentry(bibtype = "Misc", title = "GLAAS dataset", author = person("World Health Organization"), year = "2025")\n',
      file = file.path("inst", "CITATION"), append = TRUE)
  suppressMessages(update_citation(build = FALSE))
  expect_null(cffr::cff_read("CITATION.cff")$references)
  expect_length(utils::readCitationFile(file.path("inst", "CITATION"),
                                        meta = list(Encoding = "UTF-8")), 1)
})

test_that("source_dois() normalises DOI forms and skips values that are not DOIs (#134)", {
  create_local_package()
  desc::desc_set("X-schema.org-isBasedOn",
                 "doi:10.1371/journal.pwat.0000123, https://dx.doi.org/10.2166/wh.2026.173, glaas.who.int, 10.2166/wh.2026.173")
  expect_identical(suppressMessages(source_dois()),
                   c("10.1371/journal.pwat.0000123", "10.2166/wh.2026.173"))
})

test_that("csl_to_reference() maps a DataCite dataset to a CFF reference of type data (#134)", {
  csl <- list(type = "dataset", DOI = "10.5281/zenodo.11185699",
              title = "washopenresearch", publisher = "Zenodo",
              author = list(list(given = "Mian", family = "Zhong")),
              issued = list(`date-parts` = list(list(2024))))
  ref <- csl_to_reference(csl)
  expect_identical(ref$type, "data")
  expect_identical(ref$doi, "10.5281/zenodo.11185699")
  expect_identical(source_message(list(ref)),
                   "If you use this dataset, please cite both the data package and the original work listed under references.")
})
