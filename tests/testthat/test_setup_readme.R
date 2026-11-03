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

test_that("setup_readme() omits the Example section by default and documents every data object (#74, #103)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  zebra <- data.frame(id = 1)
  apple <- data.frame(id = 1)
  usethis::use_data(zebra, apple)
  suppressMessages(setup_readme())
  readme <- readLines("README.Rmd")
  expect_false("## Example" %in% readme)
  expect_identical(grep("^### ", readme, value = TRUE), c("### apple", "### zebra"))
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

test_that("setup_readme() names the publisher under Citation and shows the installed logo at the title (#145)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  trips <- data.frame(id = 1:3)
  usethis::use_data(trips)
  suppressMessages(update_description())
  suppressMessages(setup_readme())
  readme <- readLines("README.Rmd")
  expect_false(any(grepl("A data package published by", readme, fixed = TRUE)))
  cit <- grep("^## Citation$", readme)
  expect_identical(readme[cit + 2L], "Published by openwashdata, <https://openwashdata.org>.")
  expect_false(grepl("<img", readme[grep("^# ", readme)[1]], fixed = TRUE))

  # with the logo installed, the title shows it, linked to the website
  dir.create(file.path("man", "figures"), recursive = TRUE)
  writeBin(as.raw(1:8), file.path("man", "figures", "logo.png"))
  writeLines(c("meta:", "  name: openwashdata"), "_brand.yml")
  suppressMessages(setup_readme(force = TRUE))
  title <- readLines("README.Rmd")[readme_title_line(readLines("README.Rmd"))]
  expect_match(title, '^# [a-z0-9]+ <a href="https://openwashdata.org"><img src="man/figures/logo.png" align="right" width="120" alt="openwashdata" /></a>$')

  # another organisation: no sentence, a logo without a link
  desc::desc_set_urls(paste0("https://github.com/exampleorg/", desc::desc_get("Package")[[1]]))
  suppressMessages(update_description())
  suppressMessages(setup_readme(force = TRUE))
  readme <- readLines("README.Rmd")
  expect_false(any(grepl("Published by", readme, fixed = TRUE)))
  expect_match(readme[readme_title_line(readme)], '^# [a-z0-9]+ <img src="man/figures/logo.png" align="right" width="120" alt="openwashdata" />$')
})

# A package with the data objects named in `...` and dictionary rows for the
# ones in `documented`.
multi_readme_fixture <- function(objects, documented = objects, env = parent.frame()) {
  create_local_package(env = env)
  rlang::local_interactive(FALSE, frame = env)
  for (nm in objects) {
    assign(nm, data.frame(id = 1:3, value = c(1.5, 2, 3)))
    do.call(usethis::use_data, list(as.name(nm)))
  }
  dir.create("data-raw", showWarnings = FALSE)
  utils::write.csv(data.frame(
    directory = rep("data", 2 * length(documented)),
    file_name = rep(paste0(documented, ".rda"), each = 2),
    variable_name = rep(c("id", "value"), length(documented)),
    variable_type = rep(c("integer", "numeric"), length(documented)),
    description = rep(c("Identifier", "Value"), length(documented)),
    stringsAsFactors = FALSE
  ), file.path("data-raw", "dictionary.csv"), row.names = FALSE)
  invisible(desc::desc_get("Package")[[1]])
}

test_that("setup_readme() keeps the README of a single dataset as it was (#103)", {
  pkg <- multi_readme_fixture("d1")
  suppressMessages(setup_readme(has_example = TRUE))
  readme <- gsub(pkg, "PKGNAME", readLines("README.Rmd"), fixed = TRUE)
  expect_identical(sum(grepl("^### ", readme)), 1L)
  expect_true("The package provides access to ..." %in% readme)
  expect_false(any(grepl("{{", readme, fixed = TRUE)))
  # the snapshot is the README that washr 1.2.2 wrote for one dataset
  expect_snapshot(cat(readme, sep = "\n"))
})

test_that("setup_readme() writes one section per data object in data/, alphabetically (#103)", {
  multi_readme_fixture(c("zebra", "apple", "mango"))
  suppressMessages(setup_readme(has_example = TRUE))
  readme <- readLines("README.Rmd")
  expect_identical(grep("^### ", readme, value = TRUE),
                   c("### apple", "### mango", "### zebra"))
  for (nm in c("apple", "mango", "zebra")) {
    expect_true(paste0("The dataset `", nm, "` contains data about ... It has") %in% readme)
    expect_true(any(grepl(paste0('file_name == "', nm, '.rda"'), readme, fixed = TRUE)))
  }
  expect_true("The package provides access to 3 datasets ..." %in% readme)
  expect_false("The package provides access to ..." %in% readme)
  # the Example section keeps the first object
  example <- readme[seq(which(readme == "## Example"), which(readme == "## License"))]
  expect_true(any(grepl("# apple |>", example, fixed = TRUE)))
  expect_false(any(grepl("zebra", example, fixed = TRUE)))
  expect_false(any(grepl("{{", readme, fixed = TRUE)))
})

test_that("setup_readme(datasets = ) documents the named objects in their order (#103)", {
  multi_readme_fixture(c("apple", "mango", "zebra"))
  suppressMessages(setup_readme(datasets = c("zebra", "apple")))
  readme <- readLines("README.Rmd")
  expect_identical(grep("^### ", readme, value = TRUE), c("### zebra", "### apple"))
  expect_true("The package provides access to 2 datasets ..." %in% readme)
})

test_that("setup_readme() stops on a name that data/ does not hold and keeps the old README (#103)", {
  multi_readme_fixture(c("apple", "zebra"))
  writeLines("# OLD README", "README.Rmd")
  expect_error(setup_readme(force = TRUE, datasets = c("apple", "mango")), "mango")
  expect_identical(readLines("README.Rmd"), "# OLD README")
})

test_that("setup_readme() warns about a data object without dictionary rows (#103)", {
  multi_readme_fixture(c("apple", "zebra"), documented = "apple")
  withr::with_options(list(washr.quiet = FALSE), {
    out <- paste(utils::capture.output(setup_readme(), type = "message"), collapse = "\n")
  })
  expect_match(out, "zebra", fixed = TRUE)
  expect_match(out, "no rows", fixed = TRUE)
  expect_false(grepl("apple\" ha", out, fixed = TRUE))
  # a dictionary that covers every object gives no warning
  multi_readme_fixture(c("apple", "zebra"))
  withr::with_options(list(washr.quiet = FALSE), {
    out <- paste(utils::capture.output(setup_readme(), type = "message"), collapse = "\n")
  })
  expect_false(grepl("no rows", out, fixed = TRUE))
})
