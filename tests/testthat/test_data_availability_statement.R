options(usethis.quiet = TRUE)

# The guluswm 1.0.0 release as a fixture: ten authors, the last of them with
# role cre only, a middle initial, the website in _pkgdown.yml, CSV and Excel
# files in inst/extdata and the DOI in CITATION.cff.
gulu_authors <- function() {
  c(
    utils::person("Ivan", "Feni", role = "aut"),
    utils::person("Abubakar", "Batte", role = "aut"),
    utils::person("James", "Omal", role = "aut"),
    utils::person("Charles", "Wakhata", role = "aut"),
    utils::person("Juliet", "Amindre", role = "aut"),
    utils::person("Alex", "Candia", role = "aut"),
    utils::person("Rebecca", "Lamwaka", role = "aut"),
    utils::person("Grace", "Okello", role = "aut"),
    utils::person("Charles B.", "Niwagaba", role = "aut"),
    utils::person("Lars", "Schöbitz", role = "cre")
  )
}

create_das_fixture <- function(authors = gulu_authors(),
                               doi = "10.5281/zenodo.23918126",
                               site = TRUE, extdata = c("csv", "xlsx"),
                               env = parent.frame()) {
  create_local_package(env = env)
  rlang::local_interactive(FALSE, frame = env)
  desc::desc_set(
    Package = "guluswm",
    Title = "Household Waste Survey and Characterisation in Gulu City, Uganda",
    Version = "1.0.0",
    License = "CC BY 4.0",
    Date = "2026-11-03",
    URL = "https://github.com/openwashdata/guluswm"
  )
  desc::desc_set_authors(authors)
  if (site) {
    writeLines("url: https://openwashdata.github.io/guluswm/", "_pkgdown.yml")
  }
  if (length(extdata)) {
    dir.create(file.path("inst", "extdata"), recursive = TRUE)
    file.create(file.path("inst", "extdata", paste0("guluswm_survey.", extdata)))
  }
  writeLines(c(
    "cff-version: 1.2.0",
    "message: 'To cite package \"guluswm\" in publications use:'",
    "type: dataset",
    "title: 'guluswm: Household Waste Survey and Characterisation in Gulu City, Uganda'",
    "version: 1.0.0",
    if (!is.null(doi)) paste0("doi: ", doi),
    "authors:",
    "- family-names: Feni",
    "  given-names: Ivan",
    "date-released: '2026-11-03'"
  ), "CITATION.cff", useBytes = TRUE)
  invisible(TRUE)
}

gulu_reference <- paste0(
  "Feni, I., Batte, A., Omal, J., Wakhata, C., Amindre, J., Candia, A., ",
  "Lamwaka, R., Okello, G., Niwagaba, C. B., & Schöbitz, L. (2026). ",
  "guluswm: Household Waste Survey and Characterisation in Gulu City, Uganda ",
  "(Version 1.0.0) [Data set]. Zenodo. https://doi.org/10.5281/zenodo.23918126. ",
  "Available at https://github.com/openwashdata/guluswm"
)

gulu_statement <- paste(
  "The household survey and waste characterisation data supporting this study",
  "are openly available under a CC BY 4.0 licence in the R data package guluswm,",
  "version 1.0.0, archived on Zenodo at https://doi.org/10.5281/zenodo.23918126",
  "(Feni et al., 2026). The data can also be downloaded as CSV and Excel files",
  "from https://openwashdata.github.io/guluswm/. Household coordinates and free",
  "text answers are not included, to protect the privacy of the respondents."
)

test_that("data_availability_statement() reproduces the guluswm 1.0.0 text (#155)", {
  create_das_fixture()
  desc::desc_set(`Config/washr/withheld` = "Household coordinates and free text answers are not included, to protect the privacy of the respondents.")
  out <- data_availability_statement(
    subject = "The household survey and waste characterisation data"
  )
  expect_s3_class(out, "washr_data_availability")
  expect_identical(names(out), c("reference", "statement", "in_text"))
  expect_identical(out[["reference"]], gulu_reference)
  expect_identical(out[["statement"]], gulu_statement)
  expect_identical(out[["in_text"]], "Feni et al., 2026")
})

test_that("the statement opens with 'The data' by default and has no withheld sentence without the field (#155)", {
  create_das_fixture()
  out <- data_availability_statement()
  expect_match(out[["statement"]], "^The data supporting this study are openly available")
  expect_match(out[["statement"]], "from https://openwashdata.github.io/guluswm/\\.$")
  expect_no_match(out[["statement"]], "privacy")
})

test_that("data_availability_statement() stops without a DOI (#155)", {
  create_das_fixture(doi = NULL)
  expect_error(data_availability_statement(), "carries no DOI yet")
  unlink("CITATION.cff")
  expect_error(data_availability_statement(), "carries no DOI yet")
})

test_that("subject must be a single non-empty string (#155)", {
  create_das_fixture()
  expect_error(data_availability_statement(subject = ""), "subject")
  expect_error(data_availability_statement(subject = c("a", "b")), "subject")
})

test_that("the in-text citation names one, two, or the first author with et al. (#155)", {
  create_das_fixture(authors = utils::person("Ivan", "Feni", role = c("aut", "cre")))
  out <- data_availability_statement()
  expect_identical(out[["in_text"]], "Feni, 2026")
  expect_match(out[["reference"]], "^Feni, I\\. \\(2026\\)\\. ")

  create_das_fixture(authors = c(
    utils::person("Ivan", "Feni", role = "aut"),
    utils::person("Abubakar", "Batte", role = "cre")
  ))
  out <- data_availability_statement()
  expect_identical(out[["in_text"]], "Feni & Batte, 2026")
  expect_match(out[["reference"]], "^Feni, I\\., & Batte, A\\. \\(2026\\)\\. ")
  expect_match(out[["statement"]], "(Feni & Batte, 2026)", fixed = TRUE)

  create_das_fixture(authors = gulu_authors()[1:3])
  expect_identical(data_availability_statement()[["in_text"]], "Feni et al., 2026")
})

test_that("contributors are left out and organisations keep their name (#155)", {
  create_das_fixture(authors = c(
    utils::person("Kampala Capital City Authority", role = "aut"),
    utils::person(c("Ana", "María"), "Götsch", role = "cre"),
    utils::person("Sam", "Helper", role = "ctb"),
    utils::person("Global Health Engineering, ETH Zurich", role = "fnd")
  ))
  out <- data_availability_statement()
  expect_match(out[["reference"]],
               "^Kampala Capital City Authority, & Götsch, A\\. M\\. \\(2026\\)")
  expect_no_match(out[["reference"]], "Helper|Global Health")
  expect_identical(out[["in_text"]], "Kampala Capital City Authority & Götsch, 2026")
})

test_that("APA initials keep middle initials and hyphenated names (#155)", {
  expect_identical(apa_initials("Charles B."), "C. B.")
  expect_identical(apa_initials(c("Ana", "María")), "A. M.")
  expect_identical(apa_initials("Jean-Paul"), "J.-P.")
  expect_identical(apa_initials("Émile"), "É.")
})

test_that("a reference with more than 20 authors lists 19, an ellipsis and the last (#155)", {
  persons <- do.call(c, lapply(1:21, function(i) {
    utils::person(paste0("Given", i), paste0("Family", i), role = "aut")
  }))
  list21 <- apa_author_list(persons)
  expect_match(list21, "^Family1, G\\., ")
  expect_match(list21, "Family19, G\\., \\. \\. \\. Family21, G\\.$")
  expect_no_match(list21, "Family20|&")

  list20 <- apa_author_list(persons[1:20])
  expect_match(list20, "Family19, G\\., & Family20, G\\.$")
})

test_that("the download sentence needs a website and files in inst/extdata (#155)", {
  create_das_fixture(site = FALSE)
  expect_no_match(data_availability_statement()[["statement"]], "downloaded")

  create_das_fixture(extdata = "csv")
  expect_match(data_availability_statement()[["statement"]],
               "downloaded as CSV files from https://openwashdata.github.io/guluswm/.",
               fixed = TRUE)

  create_das_fixture(extdata = character())
  expect_no_match(data_availability_statement()[["statement"]], "downloaded")
})

test_that("a development version gives a warning (#155)", {
  create_das_fixture()
  desc::desc_set(Version = "1.0.0.9000")
  expect_warning(out <- data_availability_statement(), "development version")
  expect_match(out[["reference"]], "(Version 1.0.0.9000)", fixed = TRUE)
})

test_that("another DOI provider drops Zenodo from the reference (#155)", {
  create_das_fixture()
  desc::desc_set(`Config/washr/doi-provider` = "datacite")
  out <- data_availability_statement()
  expect_no_match(out[["reference"]], "Zenodo")
  expect_match(out[["statement"]], "archived at https://doi.org/", fixed = TRUE)
})

test_that("printing shows the three parts (#155)", {
  create_das_fixture()
  out <- data_availability_statement()
  printed <- cli::ansi_strip(capture.output(print(out)))
  expect_identical(printed[c(1, 4, 7)],
                   c("Reference", "Data availability statement", "In-text citation"))
  expect_identical(printed[[2]], out[["reference"]])
})

test_that("clipboard = TRUE copies the reference and the statement (#155)", {
  skip_if_not_installed("clipr")
  create_das_fixture()
  # The clipboard of the machine is left alone: write_clip() is mocked
  copied <- NULL
  local_mocked_bindings(write_clip = function(content, ...) copied <<- content,
                        .package = "clipr")
  out <- suppressMessages(data_availability_statement(clipboard = TRUE))
  expect_identical(copied, paste(out[["reference"]], out[["statement"]], sep = "\n\n"))
})
