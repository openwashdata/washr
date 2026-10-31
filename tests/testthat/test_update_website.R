options(usethis.quiet = TRUE)
# TEST update_website ----------------------------------------------------------

# A _pkgdown.yml as washr 1.2.0 wrote it, with the comments, the brand wiring
# and a hand edit a package carries: no navbar, no footer, no community block.
old_config <- function(pkg) {
  c("# Standard _pkgdown.yml, written by washr::setup_website() from DESCRIPTION.",
    "# washr keeps this file as it is on every later run.",
    paste0("url: https://openwashdata.github.io/", pkg, "/"),
    "template:",
    "  bslib:",
    "    brand: _brand.yml",
    "  bootstrap: 5",
    "  includes:",
    "    in_header: |",
    "      <script defer data-domain=\"openwashdata.github.io\" src=\"https://plausible.io/js/script.js\"></script>",
    "",
    "home:",
    "  links:",
    "    - icon: github",
    "      text: GitHub repository",
    paste0("      href: https://github.com/openwashdata/", pkg),
    "  sidebar:",
    "    structure: [links, citation, authors, dev, custom]",
    "    components:",
    "      custom:",
    "        title: Funding",
    "        text: This project was funded by the [Open Research Data Program of the ETH Board](https://ethrat.ch/en/eth-domain/open-research-data/).",
    "",
    "authors:",
    "  footer:",
    "    roles: [cre, fnd]",
    "    text: \"Crafted by\"",
    "  sidebar:",
    "    roles: [cre, aut, ctb]",
    "    before: \"So *who* does the work?\"",
    "    after: \"Thanks all!\"",
    "",
    "# One entry per data object in data/, each under its own descriptive name.",
    "# Add every new data object here, or the site build stops.",
    "reference:",
    "- title: \"Data\"",
    paste0("  desc: \"Access the ", pkg, " datasets\""),
    "  contents:",
    "  - trips  # hand edited")
}

# A package with DESCRIPTION filled by update_description() and the old file.
website_update_fixture <- function(env = parent.frame(), github_user = NULL) {
  create_local_package(env = env)
  rlang::local_interactive(FALSE, frame = env)
  pkg <- desc::desc_get("Package")[[1]]
  desc::desc_set(Title = "One table", Description = "A fixture with one table.")
  desc::desc_set_authors(utils::person("Jane", "Doe", email = "jane@example.org",
                                       role = c("aut", "cre")))
  trips <- data.frame(id = 1:3)
  usethis::use_data(trips)
  suppressMessages(update_description(github_user = github_user))
  writeLines(old_config(pkg), "_pkgdown.yml")
  testthat::local_mocked_bindings(build_site = function(...) invisible(NULL), .package = "pkgdown", .env = env)
  invisible(pkg)
}

quiet_update <- function(...) {
  withr::with_options(list(washr.quiet = TRUE), update_website(...))
}

test_that("update_website() stops when no _pkgdown.yml exists", {
  create_local_package()
  rlang::local_interactive(FALSE)
  expect_error(update_website(), "setup_website")
})

test_that("update_website() adds the footer, the navbar link and the community block to a 1.2.0 file and keeps the rest (#145)", {
  pkg <- website_update_fixture()
  before <- readLines("_pkgdown.yml")
  changed <- quiet_update()
  expect_setequal(changed, c("footer", "navbar", "sidebar"))
  lines <- readLines("_pkgdown.yml")
  parsed <- yaml::read_yaml("_pkgdown.yml")

  expect_identical(parsed$footer$structure$left, c("developed_by", "publisher"))
  expect_identical(parsed$footer$structure$right, c("washr", "built_with"))
  expect_identical(parsed$footer$components$publisher, washr_defaults()[["publisher"]])
  expect_identical(parsed$footer$components$washr, washr_footer_line())
  expect_identical(parsed$navbar$structure$right, c("search", "home", "github", "lightswitch"))
  expect_identical(parsed$navbar$components$home$href, "https://openwashdata.org")
  expect_identical(parsed$navbar$components$home$text, "openwashdata.org")
  expect_identical(parsed$home$sidebar$structure, c("links", "citation", "authors", "dev", "custom", "community"))
  expect_identical(parsed$home$sidebar$components$community$title, "openwashdata")
  expect_identical(parsed$home$sidebar$components$community$text, washr_defaults()[["community"]])
  expect_null(parsed$template$opengraph)

  # everything that was there is still there, verbatim, apart from the
  # sidebar structure, which now names the community block
  kept <- before[nzchar(before) & !grepl("^    structure:", before)]
  expect_true(all(kept %in% lines))
  expect_true("    structure: [links, citation, authors, dev, custom, community]" %in% lines)
  expect_identical(parsed$template$bslib$brand, "_brand.yml")
  expect_identical(parsed$reference[[1]]$contents, "trips")
  expect_true(any(grepl("^  - trips  # hand edited$", lines)))
  expect_true(any(grepl("^# One entry per data object", lines)))
  expect_true(any(grepl(washr_defaults()[["funding"]], lines, fixed = TRUE)))
  # the new texts stand on one line, as the readiness items read them
  expect_true(any(grepl(washr_defaults()[["publisher"]], lines, fixed = TRUE)))
  expect_true(any(grepl(washr_defaults()[["community"]], lines, fixed = TRUE)))
  # the footer comes before the reference index, the navbar before home
  keys <- yaml_top_keys(lines)
  expect_lt(keys[["navbar"]], keys[["home"]])
  expect_lt(keys[["footer"]], keys[["reference"]])
})

test_that("update_website() leaves a current file untouched (#145)", {
  website_update_fixture()
  quiet_update()
  before <- tools::md5sum("_pkgdown.yml")
  expect_length(quiet_update(), 0)
  expect_identical(tools::md5sum("_pkgdown.yml"), before)
  withr::with_options(list(usethis.quiet = FALSE),
                      expect_message(update_website(), "current"))
})

test_that("update_website() and update_description() refresh the washr version in the footer (#145)", {
  website_update_fixture()
  quiet_update()
  stale <- function() {
    lines <- readLines("_pkgdown.yml")
    idx <- grep("^    washr:", lines)
    lines[idx] <- "    washr: Package built with [washr](https://openwashdata.github.io/washr/) 1.0.0."
    writeLines(lines, "_pkgdown.yml")
  }
  stale()
  expect_identical(quiet_update(), "footer")
  expect_identical(yaml::read_yaml("_pkgdown.yml")$footer$components$washr, washr_footer_line())

  stale()
  suppressMessages(update_description())
  expect_identical(yaml::read_yaml("_pkgdown.yml")$footer$components$washr, washr_footer_line())
  expect_identical(desc::desc_get_field("Config/washr/version"), as.character(utils::packageVersion("washr")))
})

test_that("update_website() keeps a hand written navbar component and a sidebar that is switched off (#145)", {
  website_update_fixture()
  lines <- readLines("_pkgdown.yml")
  lines <- append(lines, c("navbar:", "  components:", "    home:", "      text: Mine", "      href: https://example.org", ""),
                  after = grep("^home:", lines) - 1L)
  lines[grep("^  sidebar:", lines)[1]] <- "  sidebar: false"
  lines <- lines[!grepl("^    (structure|components):|^      custom:|^        (title|text):", lines)]
  writeLines(lines, "_pkgdown.yml")
  withr::with_options(list(usethis.quiet = FALSE), {
    expect_message(expect_message(changed <- update_website(), "home component"), "sidebar")
  })
  expect_identical(changed, "footer")
  parsed <- yaml::read_yaml("_pkgdown.yml")
  expect_identical(parsed$navbar$components$home$href, "https://example.org")
  expect_null(parsed$navbar$structure)
  expect_false(parsed$home$sidebar)
})

test_that("update_website() adds only the washr line for a package of another organisation (#145)", {
  pkg <- website_update_fixture(github_user = "https://github.com/exampleorg")
  changed <- quiet_update()
  expect_identical(changed, "footer")
  parsed <- yaml::read_yaml("_pkgdown.yml")
  expect_identical(parsed$footer$structure$left, "developed_by")
  expect_null(parsed$footer$components$publisher)
  expect_identical(parsed$footer$components$washr, washr_footer_line())
  expect_null(parsed$navbar)
  expect_identical(parsed$home$sidebar$structure, c("links", "citation", "authors", "dev", "custom"))
  expect_length(quiet_update(), 0)
})

test_that("update_website() sets the Open Graph image of the installed brand and follows a new ref (#145)", {
  website_update_fixture()
  image <- function(ref) {
    list(src = paste0("https://raw.githubusercontent.com/openwashdata/brand/", ref, "/assets/social-preview.png"),
         alt = "openwashdata, social preview image")
  }
  testthat::local_mocked_bindings(brand_opengraph_image = function(...) image("v1.1.0"))
  expect_true("opengraph" %in% quiet_update())
  parsed <- yaml::read_yaml("_pkgdown.yml")
  expect_identical(parsed$template$opengraph$image$src, image("v1.1.0")$src)
  expect_identical(parsed$template$opengraph$image$alt, "openwashdata, social preview image")
  expect_identical(parsed$template$bslib$brand, "_brand.yml")
  expect_length(quiet_update(), 0)

  testthat::local_mocked_bindings(brand_opengraph_image = function(...) image("v1.2.0"))
  expect_identical(quiet_update(), "opengraph")
  expect_identical(yaml::read_yaml("_pkgdown.yml")$template$opengraph$image$src, image("v1.2.0")$src)

  # an image someone chose stays
  lines <- readLines("_pkgdown.yml")
  lines[grep("^      src:", lines)] <- "      src: man/figures/card.png"
  writeLines(lines, "_pkgdown.yml")
  expect_length(quiet_update(), 0)
  expect_identical(yaml::read_yaml("_pkgdown.yml")$template$opengraph$image$src, "man/figures/card.png")
})

test_that("brand_opengraph_image() needs an installed brand and an existing file (#145)", {
  website_update_fixture()
  expect_null(brand_opengraph_image(probe = FALSE))
  writeLines(c("meta:", "  name: openwashdata"), "_brand.yml")
  desc::desc_set(`Config/washr/brand` = "v1.1.0")
  image <- brand_opengraph_image(probe = FALSE)
  expect_identical(image$src, "https://raw.githubusercontent.com/openwashdata/brand/v1.1.0/assets/social-preview.png")
  expect_identical(image$alt, "openwashdata, social preview image")
  testthat::local_mocked_bindings(url_exists = function(url) FALSE)
  expect_null(brand_opengraph_image())
  testthat::local_mocked_bindings(url_exists = function(url) TRUE)
  expect_identical(brand_opengraph_image()$src, image$src)
})

test_that("yaml_add_item() edits flow, scalar and block lists in place", {
  flow <- yaml_add_item("    right: [search, github, lightswitch]", 1L, "home", before = c("github", "lightswitch"))
  expect_identical(flow$lines, "    right: [search, home, github, lightswitch]")
  expect_true(flow$changed)
  expect_false(yaml_add_item(flow$lines, 1L, "home")$changed)
  expect_false(yaml_add_item("    right: [\"home\", github]", 1L, "home")$changed)

  scalar <- yaml_add_item("    right: built_with", 1L, "washr", first = TRUE)
  expect_identical(scalar$lines, "    right: [washr, built_with]")
  expect_false(yaml_add_item("    right: washr", 1L, "washr")$changed)

  block <- yaml_add_item(c("    right:", "      - search", "      - github"), 1L, "home", before = "github")
  expect_identical(block$lines, c("    right:", "      - search", "      - home", "      - github"))
  expect_false(yaml_add_item(block$lines, 1L, "home")$changed)
  empty <- yaml_add_item(c("    right:", "    left: x"), 1L, "washr")
  expect_identical(empty$lines, c("    right:", "      - washr", "    left: x"))
})
