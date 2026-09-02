options(usethis.quiet = TRUE)
# TEST setup_roxygen --------------------------------------------------------
test_that("setup_roxygen throws error when no tidy dataset available in data/", {
  create_local_package()
  rlang::local_interactive(FALSE)
  washr::setup_rawdata()
  file.create("data-raw/dictionary.csv")
  expect_error(setup_roxygen(), "No tidy data sets")
})

test_that("setup_roxygen throws error when no dictionary data/", {
  create_local_package()
  rlang::local_interactive(FALSE)
  washr::setup_rawdata()
  d1 <- data.frame(id = 1:3, name = c("A", "B", "C"))
  usethis::use_data(d1)
  expect_error(setup_roxygen(), "dictionary does not exist")
})


test_that("re-run setup_roxygen on existing roxygen files won't change the title and description fields", {
  create_local_package()
  rlang::local_interactive(FALSE)
  washr::setup_rawdata()
  d1 <- data.frame(id = 1:3, name = c("A", "B", "C"))
  usethis::use_data(d1)
  washr::setup_dictionary()
  washr::setup_roxygen()
  doc <- readLines(file.path(getwd(), "R", "d1.R"))
  doc[1] <- "#' d1: Test dataset"
  writeLines(doc, file.path(getwd(), "R", "d1.R"))

  dict_path <- file.path(getwd(), "data-raw", "dictionary.csv")
  dict <- read.csv(dict_path)
  file.remove(dict_path)
  dict$description[1] <- "ID Number"
  write.csv(dict, dict_path)
  washr::setup_roxygen()
  expect_true(startsWith(readLines(file.path(getwd(), "R", "d1.R"))[1], "#' d1: Test dataset"))
})

test_that("setup_roxygen works well", {
  create_local_package()
  rlang::local_interactive(FALSE)
  washr::setup_rawdata()
  d1 <- data.frame(id = 1:3, name = c("A", "B", "C"))
  usethis::use_data(d1)
  washr::setup_dictionary()
  washr::setup_roxygen()
  expect_true(file.exists(file.path(getwd(), "R", "d1.R")))
})

roxygen_fixture <- function(env = parent.frame()) {
  create_local_package(env = env)
  rlang::local_interactive(FALSE, frame = env)
  washr::setup_rawdata()
  d1 <- data.frame(id = 1:3, name = c("A", "B", "C"))
  usethis::use_data(d1)
  washr::setup_dictionary()
  washr::setup_roxygen()
  file.path("R", "d1.R")
}

test_that("setup_roxygen() re-run keeps the text below the @format block (#73)", {
  doc_path <- roxygen_fixture()
  doc <- readLines(doc_path)
  label <- which(doc == '"d1"')
  doc <- append(doc, c("#' @source Collected by hand", "#' @examples", "#' head(d1)"), after = label - 1)
  writeLines(doc, doc_path)
  dict_path <- file.path("data-raw", "dictionary.csv")
  dict <- read.csv(dict_path)
  dict$description[1] <- "ID Number"
  write.csv(dict, dict_path, row.names = FALSE)
  washr::setup_roxygen()
  after <- readLines(doc_path)
  expect_true("#' @source Collected by hand" %in% after)
  expect_true("#' head(d1)" %in% after)
  expect_true(any(grepl("\\item{id}{ID Number}", after, fixed = TRUE)))
  expect_identical(after[length(after)], '"d1"')
  expect_identical(sum(grepl("@format", after, fixed = TRUE)), 1L)
})

test_that("setup_roxygen() rewrites nothing when the dictionary is unchanged (#73)", {
  doc_path <- roxygen_fixture()
  before <- file.info(doc_path)$mtime
  content <- readLines(doc_path)
  Sys.sleep(1.1)
  washr::setup_roxygen()
  expect_identical(readLines(doc_path), content)
  expect_identical(file.info(doc_path)$mtime, before)
})

test_that("setup_roxygen() errors clearly on a file without an @format line (#73)", {
  doc_path <- roxygen_fixture()
  writeLines(c("#' d1: hand written", "#' no format line here", '"d1"'), doc_path)
  expect_error(washr::setup_roxygen(), "@format")
})
