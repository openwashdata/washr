options(usethis.quiet = TRUE)

dict_path <- file.path("data-raw", "dictionary.csv")

# A package with one data object and a dictionary with written descriptions.
dict_fixture <- function(env = parent.frame()) {
  create_local_package(env = env)
  rlang::local_interactive(FALSE, frame = env)
  suppressMessages(setup_rawdata())
  trips <- data.frame(id = 1:3, volume = c("1.5", "2", "3.25"), site = c("a", "b", "c"))
  usethis::use_data(trips)
  suppressMessages(setup_dictionary())
  dict <- utils::read.csv(dict_path)
  dict$description <- c("Trip id", "Volume emptied", "Site name")
  utils::write.csv(dict, dict_path, row.names = FALSE)
  invisible(dict_path)
}

# Every cell as typed.
read_cells <- function() {
  utils::read.csv(dict_path, colClasses = "character", na.strings = character(),
                  check.names = FALSE, encoding = "UTF-8")
}

# All messages of a call as one string, unwrapped.
messages_of <- function(expr) {
  withr::local_options(cli.width = 1000)
  msgs <- character()
  withCallingHandlers(expr, message = function(m) {
    msgs <<- c(msgs, conditionMessage(m))
    invokeRestart("muffleMessage")
  })
  paste(msgs, collapse = "")
}

test_that("update_dictionary() keeps descriptions when variables come and go (#13)", {
  dict_fixture()
  trips <- data.frame(id = 1:3, volume = c("1.5", "2", "3.25"), truck = c("x", "y", "z"))
  usethis::use_data(trips, overwrite = TRUE)
  expect_invisible(path <- suppressMessages(update_dictionary()))
  expect_identical(path, dict_path)
  dict <- read_cells()
  expect_identical(names(dict), c("directory", "file_name", "variable_name", "variable_type", "description"))
  expect_identical(dict$variable_name, c("id", "volume", "truck"))
  expect_identical(dict$description, c("Trip id", "Volume emptied", ""))
  expect_identical(dict$directory, rep("data/", 3))
  expect_identical(dict$file_name, rep("trips.rda", 3))
  expect_identical(dict$variable_type, c("integer", "character", "character"))
})

test_that("update_dictionary() keeps the columns a user added, the pkgreview#37 round trip (#13)", {
  dict_fixture()
  # unit sits between the standard columns, allowed_values and a note at the end
  dict <- read_cells()
  dict <- data.frame(dict[1:4], unit = c("", "litres", ""), dict[5],
                     allowed_values = c("", "", "a; b; c"),
                     `review note` = c("001", "", "NA"), check.names = FALSE)
  utils::write.csv(dict, dict_path, row.names = FALSE)

  trips <- data.frame(id = 1:3, truck = c("x", "y", "z"),
                      volume = c("1.5", "2", "3.25"), site = c("a", "b", "c"))
  usethis::use_data(trips, overwrite = TRUE)
  suppressMessages(update_dictionary())

  after <- read_cells()
  expect_identical(names(after), names(dict))
  expect_identical(after$variable_name, c("id", "truck", "volume", "site"))
  expect_identical(after$unit, c("", "", "litres", ""))
  expect_identical(after$allowed_values, c("", "", "", "a; b; c"))
  expect_identical(after$`review note`, c("001", "", "", "NA"))
  expect_identical(after$description, c("Trip id", "", "Volume emptied", "Site name"))
})

test_that("update_dictionary() names what changed and prints the description of a possible rename (#13)", {
  dict_fixture()
  dict <- read_cells()
  dict$unit <- c("", "litres", "")
  utils::write.csv(dict, dict_path, row.names = FALSE)
  trips <- data.frame(id = 1:3, volume_l = c(1.5, 2, 3.25), site = c("a", "b", "c"))
  usethis::use_data(trips, overwrite = TRUE)
  msg <- messages_of(update_dictionary())
  expect_match(msg, "Updated")
  expect_match(msg, "Added 1 variable: \"trips$volume_l\"", fixed = TRUE)
  expect_match(msg, "Removed 1 variable: \"trips$volume\"", fixed = TRUE)
  expect_match(msg, "was renamed")
  expect_match(msg, "description: Volume emptied; unit: litres", fixed = TRUE)
  expect_match(msg, "Write the description of 1 variable")
  expect_identical(read_cells()$description, c("Trip id", "", "Site name"))
})

test_that("update_dictionary() refreshes the type and says so (#13)", {
  dict_fixture()
  trips <- data.frame(id = 1:3, volume = c(1.5, 2, 3.25), site = factor(c("a", "b", "c")))
  usethis::use_data(trips, overwrite = TRUE)
  msg <- messages_of(update_dictionary())
  expect_match(msg, "Changed the type of 2 variables")
  expect_match(msg, "trips$volume (character to numeric)", fixed = TRUE)
  expect_match(msg, "Every variable has a description")
  dict <- read_cells()
  expect_identical(dict$variable_type, c("integer", "numeric", "factor"))
  expect_identical(dict$description, c("Trip id", "Volume emptied", "Site name"))
})

test_that("update_dictionary() follows data objects that are added and removed (#13)", {
  dict_fixture()
  areas <- data.frame(name = c("north", "south"), households = c(120L, 80L))
  usethis::use_data(areas)
  msg <- messages_of(update_dictionary())
  expect_match(msg, "Added 2 variables")
  dict <- read_cells()
  # data objects in alphabetical order, variables in data order
  expect_identical(dict$file_name, c(rep("areas.rda", 2), rep("trips.rda", 3)))
  expect_identical(dict$variable_name, c("name", "households", "id", "volume", "site"))
  expect_identical(dict$description, c("", "", "Trip id", "Volume emptied", "Site name"))

  file.remove(file.path("data", "areas.rda"))
  msg <- messages_of(update_dictionary())
  expect_match(msg, "Removed 2 variables")
  expect_no_match(msg, "was renamed")
  expect_identical(read_cells()$variable_name, c("id", "volume", "site"))
})

test_that("update_dictionary() writes nothing when the data did not change (#13)", {
  dict_fixture()
  before <- tools::md5sum(dict_path)
  msg <- messages_of(update_dictionary())
  expect_match(msg, "up to date")
  expect_identical(tools::md5sum(dict_path), before)

  # after a real update, a second run leaves the file byte identical
  trips <- data.frame(id = 1:3, volume = c("1.5", "2", "3.25"), truck = c("x", "y", "z"))
  usethis::use_data(trips, overwrite = TRUE)
  suppressMessages(update_dictionary())
  first <- tools::md5sum(dict_path)
  expect_false(identical(first, before))
  expect_match(messages_of(update_dictionary()), "up to date")
  expect_identical(tools::md5sum(dict_path), first)
})

test_that("update_dictionary() leaves a hand formatted file alone when its content is current (#13)", {
  dict_fixture()
  # unquoted cells and Windows line endings, as a spreadsheet may save them
  writeBin(charToRaw(paste0(
    "directory,file_name,variable_name,variable_type,description\r\n",
    "data/,trips.rda,id,integer,Trip id\r\n",
    "data/,trips.rda,volume,character,Volume emptied\r\n",
    "data/,trips.rda,site,character,Site name\r\n")), dict_path)
  before <- tools::md5sum(dict_path)
  expect_match(messages_of(update_dictionary()), "up to date")
  expect_identical(tools::md5sum(dict_path), before)
})

test_that("update_dictionary() carries awkward text through a rewrite (#13)", {
  dict_fixture()
  awkward <- c("Id, as issued; \"quoted\" and 'single'",
               "First line\nsecond line",
               "Caf\u00e9 in Z\u00fcrich, 20 \u00b0C {braces}")
  dict <- read_cells()
  dict$description <- awkward
  utils::write.csv(dict, dict_path, row.names = FALSE, fileEncoding = "UTF-8")
  trips <- data.frame(id = 1:3, volume = c("1.5", "2", "3.25"), site = c("a", "b", "c"),
                      truck = c("x", "y", "z"))
  usethis::use_data(trips, overwrite = TRUE)
  suppressMessages(update_dictionary())
  after <- read_cells()
  expect_identical(after$description, c(awkward, ""))
  expect_identical(Encoding(after$description[3]), "UTF-8")
  # the file holds UTF-8 bytes in the layout utils::write.csv() gives
  bytes <- readBin(dict_path, "raw", file.size(dict_path))
  expect_true(grepl("Caf\xc3\xa9", rawToChar(bytes), fixed = TRUE, useBytes = TRUE))
  expect_false(any(bytes == as.raw(0x0d)))
  reference <- withr::local_tempfile()
  utils::write.csv(after, reference, row.names = FALSE, fileEncoding = "UTF-8", eol = "\n")
  expect_identical(readBin(reference, "raw", file.size(reference)), bytes)

  # the rename hint prints such a description without tripping over the braces
  trips$place <- trips$site
  trips$site <- NULL
  usethis::use_data(trips, overwrite = TRUE)
  expect_match(messages_of(update_dictionary()), "{braces}", fixed = TRUE)
})

test_that("update_dictionary() reads a file with a byte order mark and drops empty rows (#13)", {
  dict_fixture()
  writeBin(c(as.raw(c(0xEF, 0xBB, 0xBF)), charToRaw(paste0(
    "directory,file_name,variable_name,variable_type,description\n",
    "data/,trips.rda,id,integer,Trip id\n",
    "data/,trips.rda,volume,character,Volume emptied\n",
    "data/,trips.rda,site,character,Site name\n",
    ",,,,\n"))), dict_path)
  msg <- messages_of(update_dictionary())
  expect_match(msg, "Dropped 1 empty row")
  after <- read_cells()
  expect_identical(names(after)[1], "directory")
  expect_identical(after$description, c("Trip id", "Volume emptied", "Site name"))
})

test_that("update_dictionary() adds a standard column the dictionary lacks (#13)", {
  dict_fixture()
  dict <- read_cells()
  utils::write.csv(dict[c("file_name", "variable_name", "description")], dict_path, row.names = FALSE)
  msg <- messages_of(update_dictionary())
  expect_match(msg, "Added 2 columns")
  after <- read_cells()
  expect_identical(names(after), c("file_name", "variable_name", "description", "directory", "variable_type"))
  expect_identical(after$description, c("Trip id", "Volume emptied", "Site name"))
  expect_identical(after$variable_type, c("integer", "character", "character"))
})

test_that("update_dictionary() reorders rows to follow the data (#13)", {
  dict_fixture()
  dict <- read_cells()
  utils::write.csv(dict[c(3, 1, 2), ], dict_path, row.names = FALSE)
  expect_match(messages_of(update_dictionary()), "Reordered the rows")
  after <- read_cells()
  expect_identical(after$variable_name, c("id", "volume", "site"))
  expect_identical(after$description, c("Trip id", "Volume emptied", "Site name"))
})

test_that("update_dictionary() stops with a hint instead of guessing (#13)", {
  withr::with_dir(withr::local_tempdir(),
                  expect_error(update_dictionary(), "not in the correct working directory"))

  create_local_package()
  rlang::local_interactive(FALSE)
  suppressMessages(setup_rawdata())
  err <- rlang::catch_cnd(update_dictionary(), "error")
  expect_match(conditionMessage(err), "No dictionary found")
  expect_match(conditionMessage(err), "setup_dictionary")

  writeLines("directory,file_name,variable_name,variable_type,description", dict_path)
  expect_error(update_dictionary(), "no tidy data")

  trips <- data.frame(id = 1:3)
  usethis::use_data(trips)
  writeLines(c("variable,description", "id,Trip id"), dict_path)
  before <- readLines(dict_path)
  err <- rlang::catch_cnd(update_dictionary(), "error")
  expect_match(conditionMessage(err), "lacks 2 columns")
  expect_match(conditionMessage(err), "file_name")
  expect_identical(readLines(dict_path), before)

  writeLines(c("directory,file_name,variable_name,variable_type,description",
               "data/,trips.rda,id,integer,Trip id",
               "data/,trips.rda,id,integer,Another text"), dict_path)
  before <- readLines(dict_path)
  expect_error(update_dictionary(), "more than one row")
  expect_identical(readLines(dict_path), before)
})

test_that("update_dictionary() is silent under washr.quiet (#13)", {
  dict_fixture()
  trips <- data.frame(id = 1:3, truck = c("x", "y", "z"))
  usethis::use_data(trips, overwrite = TRUE)
  withr::local_options(washr.quiet = TRUE)
  expect_no_message(update_dictionary())
  expect_identical(read_cells()$variable_name, c("id", "truck"))
})

test_that("setup_dictionary() points at update_dictionary() when the dictionary exists (#13)", {
  dict_fixture()
  err <- rlang::catch_cnd(setup_dictionary(), "error")
  expect_match(conditionMessage(err), "already exists")
  expect_match(conditionMessage(err), "update_dictionary")
})
