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

# The plain text citation chunk of the template, run as knitr would run it.
citation_chunk <- function(readme = readLines("README.Rmd")) {
  start <- grep("^```\\{r, echo=FALSE, results='asis'\\}", readme)
  stopifnot(length(start) == 1)
  end <- start + which(readme[(start + 1):length(readme)] == "```")[1]
  paste(capture.output(eval(parse(text = readme[(start + 1):(end - 1)]), envir = new.env())),
        collapse = "\n")
}

test_that("setup_readme() states the DOI, the version and the source article in plain text (#137)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  d1 <- data.frame(id = 1:3, name = c("A", "B", "C"))
  usethis::use_data(d1)
  setup_readme()
  readme <- readLines("README.Rmd")
  pkg <- desc::desc_get("Package")[[1]]
  expect_false(any(grepl("{{{", readme, fixed = TRUE)))
  expect_true(any(grepl(paste0("https://openwashdata.github.io/", pkg, "/authors.html"), readme, fixed = TRUE)))

  # Before the first DOI: only the pointers
  text <- citation_chunk(readme)
  expect_false(grepl("Cite version", text, fixed = TRUE))
  expect_match(text, "authors page", fixed = TRUE)

  writeLines(c("cff-version: 1.2.0", "version: 1.0.0", "doi: 10.5281/zenodo.1234567",
               "references:", "- type: article", "  doi: 10.1000/source"), "CITATION.cff")
  desc::desc_set(`X-schema.org-isBasedOn` = "https://doi.org/10.1000/source")
  text <- citation_chunk(readme)
  expect_match(text, "Cite version 1.0.0 of", fixed = TRUE)
  expect_match(text, "[10.5281/zenodo.1234567](https://doi.org/10.5281/zenodo.1234567)", fixed = TRUE)
  expect_match(text, "first published in <https://doi.org/10.1000/source>", fixed = TRUE)
})

test_that("the download links follow the release tag, and main for a development version (#137)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  d1 <- data.frame(id = 1:3, name = c("A", "B", "C"))
  usethis::use_data(d1)
  setup_readme()
  readme <- readLines("README.Rmd")
  start <- grep("^version <- read.dcf", readme)
  ref_code <- readme[start + 0:1]
  env <- new.env()
  eval(parse(text = ref_code), envir = env)
  expect_identical(env$ref, "main")
  desc::desc_set(Version = "1.2.0")
  eval(parse(text = ref_code), envir = env)
  expect_identical(env$ref, "v1.2.0")
  expect_true(any(grepl('/raw/", ref, "/inst/extdata/"', readme, fixed = TRUE)))
})
