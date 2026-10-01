options(usethis.quiet = TRUE)

# A package taken through the workflow, with the files that the build steps
# outside washr produce (README.md, the help page) written by hand.
readiness_fixture <- function(env = parent.frame()) {
  create_local_package(env = env)
  rlang::local_interactive(FALSE, frame = env)
  pkg <- desc::desc_get("Package")[[1]]
  desc::desc_set(Title = "Truck Trips in a Fixture City",
                 Description = "Trips of faecal sludge trucks, recorded for a test fixture.",
                 `X-schema.org-keywords` = "fixture, sanitation",
                 `X-schema.org-spatialCoverage` = "Kampala, Uganda",
                 `X-schema.org-temporalCoverage` = "2022-03-01/2022-09-30")
  desc::desc_set_authors(utils::person("Jane", "Doe", email = "jane@example.org",
                                       role = c("aut", "cre")))
  trips <- data.frame(id = 1:3, volume = c(1.5, 2, 3.25))
  usethis::use_data(trips)
  suppressMessages({
    setup_rawdata()
    setup_dictionary()
    dict_path <- file.path("data-raw", "dictionary.csv")
    dict <- utils::read.csv(dict_path)
    dict$description <- paste("Describes", dict$variable_name)
    utils::write.csv(dict, dict_path, row.names = FALSE)
    setup_roxygen()
    update_description()
    setup_readme()
    setup_ci()
    update_citation(build = FALSE)
  })
  dir.create("man", showWarnings = FALSE)
  writeLines(c("\\name{trips}", "\\title{Trips}", "\\source{Collected by hand}"),
             file.path("man", "trips.Rd"))
  writeLines(c("# fixture",
               paste0("[Download CSV](https://github.com/openwashdata/", pkg,
                      "/raw/main/inst/extdata/trips.csv)")),
             "README.md")
  usethis::use_template("_pkgdown.yml", save_as = "_pkgdown.yml",
                        data = pkgdown_template_data(),
                        package = "washr")
  invisible(pkg)
}

# A copy of the fixture to break, so every case starts from the passing state.
broken_copy <- function(env = parent.frame()) {
  target <- withr::local_tempfile(.local_envir = env)
  dir.create(target)
  file.copy(list.files(".", all.files = TRUE, no.. = TRUE), target, recursive = TRUE)
  target
}

status_of <- function(result, id) result$status[result$id == id]

quiet_check <- function(...) {
  withr::with_options(list(washr.quiet = TRUE), check_publication_readiness(...))
}

tree_md5 <- function(dir = ".") {
  files <- list.files(dir, recursive = TRUE, all.files = TRUE, full.names = TRUE)
  tools::md5sum(files)
}

test_that("a package taken through the workflow passes every applicable item (#82)", {
  readiness_fixture()
  before <- tree_md5()
  result <- quiet_check()
  expect_identical(tree_md5(), before)

  expect_s3_class(result, c("washr_readiness", "data.frame"), exact = TRUE)
  expect_named(result, c("id", "area", "check", "status", "detail", "fix"))
  expect_identical(result$id, vapply(readiness_checks(), function(chk) chk$id, character(1)))
  expect_false(anyDuplicated(result$id) > 0)
  expect_setequal(unique(result$area), c("metadata", "data", "docs", "tests"))
  expect_true(all(result$status %in% c("pass", "fail", "na")))
  expect_identical(result$id[result$status == "fail"], character())
  # the package is held to its own Config/washr values; no pkgdown workflow
  expect_identical(result$id[result$status == "na"], "docs_untracked")

  expect_true(attr(result, "ready"))
  expect_identical(attr(result, "washr_version"), as.character(utils::packageVersion("washr")))
  expect_match(attr(result, "package"), "0.0.0.9000", fixed = TRUE)
})

test_that("the report goes through cli, can be silenced and prints again (#82)", {
  readiness_fixture()
  expect_message(result <- check_publication_readiness(), "Ready for publication", class = "cliMessage")
  expect_no_message(quiet_check())
  expect_invisible(quiet_check())
  expect_output(print(result), "Publication readiness")
  expect_output(print(result), "27 pass, 0 fail, 1 not applicable", fixed = TRUE)
  expect_identical(length(format(result)) > nrow(result), TRUE)
})

test_that("each item fails on its own gap and names the step that closes it (#82)", {
  readiness_fixture()
  rewrite <- function(file, fun) writeLines(fun(readLines(file, warn = FALSE)), file)
  breakers <- list(
    license = function(p) desc::desc_set(License = "MIT + file LICENSE", file = p),
    description_complete = function(p) {
      desc::desc_set(Title = "What the Package Does (One Line, Title Case)", file = p)
    },
    citation_cff = function(p) unlink(file.path(p, "CITATION.cff")),
    citation_version = function(p) desc::desc_set(Version = "9.9.9", file = p),
    citation_authors = function(p) {
      cat("# Firstname Lastname\n", file = file.path(p, "inst", "CITATION"), append = TRUE)
    },
    keywords = function(p) desc::desc_del("X-schema.org-keywords", file = p),
    coverage = function(p) desc::desc_del("X-schema.org-spatialCoverage", file = p),
    title_length = function(p) desc::desc_set(Title = strrep("Long Title ", 7), file = p),
    data_present = function(p) unlink(file.path(p, "data"), recursive = TRUE),
    dictionary_present = function(p) unlink(file.path(p, "data-raw", "dictionary.csv")),
    dictionary_coverage = function(p) {
      rewrite(file.path(p, "data-raw", "dictionary.csv"), function(x) x[-length(x)])
    },
    dictionary_descriptions = function(p) {
      rewrite(file.path(p, "data-raw", "dictionary.csv"),
              function(x) sub("Describes volume", "TODO", x, fixed = TRUE))
    },
    dictionary_schema = function(p) {
      rewrite(file.path(p, "data-raw", "dictionary.csv"),
              function(x) c(sub("variable_type", "type", x[1], fixed = TRUE), x[-1]))
    },
    roxygen_docs = function(p) unlink(file.path(p, "man", "trips.Rd")),
    readme = function(p) unlink(file.path(p, "README.md")),
    rd_source = function(p) {
      rewrite(file.path(p, "man", "trips.Rd"), function(x) x[!grepl("source", x)])
    },
    readme_extdata_links = function(p) writeLines("# fixture", file.path(p, "README.md")),
    vignettes_location = function(p) {
      dir.create(file.path(p, "vignettes"))
      writeLines("---", file.path(p, "vignettes", "analysis.Rmd"))
    },
    pkgdown_config = function(p) unlink(file.path(p, "_pkgdown.yml")),
    pkgdown_analytics = function(p) {
      rewrite(file.path(p, "_pkgdown.yml"), function(x) x[!grepl("plausible", x)])
    },
    pkgdown_url = function(p) {
      rewrite(file.path(p, "_pkgdown.yml"),
              function(x) sub("^url: .*$", "url: https://github.com/openwashdata/fixture", x))
    },
    check_workflow = function(p) unlink(file.path(p, ".github", "workflows", "R-CMD-check.yaml")),
    check_workflow_dev = function(p) {
      rewrite(file.path(p, ".github", "workflows", "R-CMD-check.yaml"),
              function(x) sub(", dev]", "]", x, fixed = TRUE))
    },
    check_badge = function(p) {
      rewrite(file.path(p, "README.Rmd"), function(x) x[!grepl("R-CMD-check", x)])
    }
  )
  for (id in names(breakers)) {
    target <- broken_copy()
    breakers[[id]](target)
    result <- quiet_check(target)
    expect_identical(status_of(result, !!id), "fail")
    expect_false(attr(result, "ready"))
    expect_true(nzchar(result$fix[result$id == id]))
  }
})

test_that("a failing item prints with its fix and the verdict (#82)", {
  readiness_fixture()
  unlink("CITATION.cff")
  expect_message(result <- check_publication_readiness(), "Not ready for publication",
                 class = "cliMessage")
  report <- format(result)
  expect_true(any(grepl("CITATION.cff present: file missing", report, fixed = TRUE)))
  expect_true(any(grepl("Run update_citation().", report, fixed = TRUE)))
  expect_true(any(grepl("not applicable, CITATION.cff missing", report, fixed = TRUE)))
})

test_that("items that cannot be decided are not applicable, with the reason (#82)", {
  readiness_fixture()
  target <- broken_copy()
  unlink(file.path(target, "CITATION.cff"))
  unlink(file.path(target, "_pkgdown.yml"))
  unlink(file.path(target, "data-raw", "dictionary.csv"))
  unlink(file.path(target, ".github"), recursive = TRUE)
  unlink(file.path(target, "data"), recursive = TRUE)
  result <- quiet_check(target)
  na_ids <- c("citation_version", "citation_authors", "dictionary_coverage",
              "dictionary_descriptions", "dictionary_schema", "roxygen_docs",
              "pkgdown_analytics", "pkgdown_url", "pkgdown_funding", "pkgdown_brand",
              "docs_untracked", "check_workflow_dev")
  expect_identical(unname(result$status[match(na_ids, result$id)]), rep("na", length(na_ids)))
  expect_true(all(nzchar(result$detail[match(na_ids, result$id)])))
  expect_identical(status_of(result, "citation_cff"), "fail")
  expect_identical(status_of(result, "pkgdown_config"), "fail")
  expect_identical(status_of(result, "check_workflow"), "fail")
})

test_that("the organisation profile sets what the site items expect (#82)", {
  pkg <- readiness_fixture()
  none <- quiet_check(profile = list(analytics = "none"))
  expect_identical(status_of(none, "pkgdown_analytics"), "na")

  funding <- "funded by the [Open Research Data Program of the ETH Board]"
  expect_identical(status_of(quiet_check(profile = list(funding_text = funding)), "pkgdown_funding"), "pass")
  expect_identical(status_of(quiet_check(profile = list(funding_text = "Funded by nobody")), "pkgdown_funding"), "fail")

  pattern <- "https://openwashdata.github.io/<package>/"
  expect_identical(status_of(quiet_check(profile = list(site_url_pattern = pattern)), "pkgdown_url"), "pass")
  other <- quiet_check(profile = list(site_url_pattern = "https://example.org/<package>/"))
  expect_identical(status_of(other, "pkgdown_url"), "fail")
  expect_match(other$detail[other$id == "pkgdown_url"], paste0("expected https://example.org/", pkg, "/"), fixed = TRUE)

  required <- quiet_check(profile = list(keywords_required = c("fixture", "WASH")))
  expect_identical(status_of(required, "keywords"), "fail")
  expect_match(required$detail[required$id == "keywords"], "missing: WASH", fixed = TRUE)

  expect_identical(status_of(quiet_check(profile = list(brand = "none")), "pkgdown_brand"), "pass")
  cat("template:\n  bslib:\n    brand: _brand.yml\n", file = "_pkgdown.yml", append = TRUE)
  expect_identical(status_of(quiet_check(profile = list(brand = "none")), "pkgdown_brand"), "fail")
  expect_identical(status_of(quiet_check(profile = list(brand = "openwashdata")), "pkgdown_brand"), "pass")

  expect_error(quiet_check(profile = list(analytics = "matomo")), "plausible")
  expect_error(quiet_check(profile = "openwashdata"), "named list")
})

test_that("keyword drift from CITATION.cff is a detail, not a failure (#82)", {
  readiness_fixture()
  desc::desc_set(`X-schema.org-keywords` = "fixture, sanitation, trucks")
  result <- quiet_check()
  expect_identical(status_of(result, "keywords"), "pass")
  expect_match(result$detail[result$id == "keywords"], "CITATION.cff differs", fixed = TRUE)
})

test_that("tracked docs/ fails only while the pkgdown workflow deploys the site (#82)", {
  skip_if(Sys.which("git") == "", "git is not available")
  readiness_fixture()
  git <- function(...) system2("git", c(...), stdout = FALSE, stderr = FALSE)
  dir.create("docs")
  writeLines("<html></html>", file.path("docs", "index.html"))
  writeLines("name: pkgdown", file.path(".github", "workflows", "pkgdown.yaml"))
  expect_identical(status_of(quiet_check(), "docs_untracked"), "na")
  git("init", "-q")
  git("add", "DESCRIPTION")
  expect_identical(status_of(quiet_check(), "docs_untracked"), "pass")
  git("add", "docs")
  result <- quiet_check()
  expect_identical(status_of(result, "docs_untracked"), "fail")
  expect_match(result$detail[result$id == "docs_untracked"], "1 tracked file(s)", fixed = TRUE)
})

test_that("a broken file fails its own items and leaves the rest standing (#82)", {
  readiness_fixture()
  writeBin(as.raw(c(0x00, 0x01)), file.path("data", "trips.rda"))
  result <- quiet_check()
  expect_identical(status_of(result, "data_present"), "fail")
  expect_identical(status_of(result, "license"), "pass")
})

test_that("bytes that are not UTF-8 in the dictionary fail the schema item only (#82)", {
  readiness_fixture()
  dict_path <- file.path("data-raw", "dictionary.csv")
  bytes <- readBin(dict_path, "raw", n = file.size(dict_path))
  marker <- charToRaw("Describes volume")
  at <- which(vapply(seq_len(length(bytes) - length(marker) + 1), function(i) {
    identical(bytes[i:(i + length(marker) - 1)], marker)
  }, logical(1)))
  writeBin(c(bytes[seq_len(at - 1)], charToRaw("Volume in m"), as.raw(0xB3), bytes[(at + length(marker)):length(bytes)]),
           dict_path)
  result <- quiet_check()
  expect_identical(status_of(result, "dictionary_schema"), "fail")
  expect_match(result$detail[result$id == "dictionary_schema"], "non-UTF-8 bytes", fixed = TRUE)
  expect_identical(status_of(result, "dictionary_coverage"), "pass")
  expect_identical(status_of(result, "dictionary_descriptions"), "pass")
})

test_that("check_publication_readiness() aborts outside a package root (#82)", {
  dir <- withr::local_tempdir()
  expect_error(check_publication_readiness(dir), "not the root of a package")
})

test_that("the .zenodo.json item follows DESCRIPTION", {
  readiness_fixture()
  expect_identical(status_of(quiet_check(), "zenodo_json"), "pass")
  desc::desc_set(Version = "9.9.9")
  stale <- quiet_check()
  expect_identical(status_of(stale, "zenodo_json"), "fail")
  expect_match(stale$detail[stale$id == "zenodo_json"], "differs")
  unlink(".zenodo.json")
  expect_match(quiet_check()$detail[quiet_check()$id == "zenodo_json"], "file missing")
})

test_that("a subset of the report is a plain data frame (#82)", {
  readiness_fixture()
  unlink("CITATION.cff")
  result <- quiet_check()
  failing <- result[result$status == "fail", c("id", "detail", "fix")]
  expect_s3_class(failing, "data.frame", exact = TRUE)
  expect_identical(failing$id[1], "citation_cff")
  expect_null(attr(failing, "ready"))
  expect_output(print(failing), "citation_cff")
  expect_s3_class(result[result$area == "docs", ], "data.frame", exact = TRUE)
  expect_identical(result[["id"]], result$id)
})

test_that("a text file with invalid UTF-8 bytes is still read (#82)", {
  readiness_fixture()
  con <- file("README.md", open = "ab")
  writeBin(as.raw(c(0x47, 0x65, 0x6e, 0xe8, 0x76, 0x65, 0x0a)), con)
  close(con)
  result <- quiet_check()
  expect_identical(status_of(result, "readme_extdata_links"), "pass")
  expect_false(any(grepl("stopped with an error", result$detail)))
})
