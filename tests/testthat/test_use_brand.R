options(usethis.quiet = TRUE)
# TEST use_brand ---------------------------------------------------------------

make_brand_source <- function(dir = tempfile("brandsrc")) {
  dir.create(file.path(dir, "logos"), recursive = TRUE)
  writeLines(
    c(
      "meta:",
      "  name: openwashdata",
      "color:",
      "  palette:",
      "    owd-purple: \"#5b195b\"",
      "  primary: owd-purple",
      "logo:",
      "  images:",
      "    icon: logos/icon.png",
      "  small: icon"
    ),
    file.path(dir, "_brand.yml")
  )
  writeBin(as.raw(1:8), file.path(dir, "logos", "icon.png"))
  dir
}

test_that("use_brand installs the brand and referenced logos", {
  create_local_package()
  rlang::local_interactive(FALSE)
  src <- make_brand_source()
  written <- use_brand(source = src, pkgdown = FALSE)
  expect_true(file.exists("_brand.yml"))
  expect_true(file.exists("logos/icon.png"))
  expect_setequal(written, c("_brand.yml", "logos/icon.png"))
})

test_that("use_brand reads logo entries that carry a path and an alt text", {
  create_local_package()
  rlang::local_interactive(FALSE)
  src <- make_brand_source()
  writeLines(
    c(
      "meta:",
      "  name: openwashdata",
      "color:",
      "  palette:",
      "    owd-purple: \"#5b195b\"",
      "  primary: owd-purple",
      "logo:",
      "  images:",
      "    icon:",
      "      path: logos/icon.png",
      "      alt: openwashdata, stacked wordmark",
      "    badge:",
      "      path: logos/badge.png",
      "      alt: openwashdata badge",
      "  small: icon",
      "  medium:",
      "    path: logos/wordmark.png",
      "    alt: openwashdata wordmark"
    ),
    file.path(src, "_brand.yml")
  )
  writeBin(as.raw(1:8), file.path(src, "logos", "badge.png"))
  writeBin(as.raw(1:8), file.path(src, "logos", "wordmark.png"))
  written <- use_brand(source = src, pkgdown = FALSE)
  expect_setequal(
    written,
    c("_brand.yml", "logos/icon.png", "logos/badge.png", "logos/wordmark.png")
  )
})

test_that("use_brand is idempotent and reports refreshed files", {
  create_local_package()
  rlang::local_interactive(FALSE)
  src <- make_brand_source()
  use_brand(source = src, pkgdown = FALSE)
  second <- use_brand(source = src, pkgdown = FALSE)
  expect_length(second, 0)
  # A change in the central source must reach the consumer on refresh.
  writeBin(as.raw(9:16), file.path(src, "logos", "icon.png"))
  third <- use_brand(source = src, pkgdown = FALSE)
  expect_identical(third, "logos/icon.png")
})

test_that("use_brand wires an existing _pkgdown.yml to the brand", {
  create_local_package()
  rlang::local_interactive(FALSE)
  src <- make_brand_source()
  writeLines(c("template:", "  bootstrap: 5"), "_pkgdown.yml")
  written <- use_brand(source = src)
  config <- yaml::read_yaml("_pkgdown.yml")
  expect_identical(config$template$bslib$brand, "_brand.yml")
  expect_true("_pkgdown.yml" %in% written)
  # A second run leaves the wiring untouched.
  expect_false("_pkgdown.yml" %in% use_brand(source = src))
})

test_that("use_brand skips the pkgdown wiring when no _pkgdown.yml exists", {
  create_local_package()
  rlang::local_interactive(FALSE)
  src <- make_brand_source()
  expect_no_error(use_brand(source = src))
  expect_false(file.exists("_pkgdown.yml"))
})

test_that("use_brand errors clearly on a missing source file", {
  create_local_package()
  rlang::local_interactive(FALSE)
  src <- tempfile("emptysrc")
  dir.create(src)
  expect_error(use_brand(source = src, pkgdown = FALSE), "not found")
})

test_that("use_brand build ignores the brand file and the logo directory (#133)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  src <- make_brand_source()
  use_brand(source = src, pkgdown = FALSE)
  ignored <- readLines(".Rbuildignore")
  expect_true("^_brand\\.yml$" %in% ignored)
  expect_true("^logos$" %in% ignored)
  use_brand(source = src, pkgdown = FALSE)
  expect_identical(readLines(".Rbuildignore"), ignored)
})

test_that("use_brand wires _pkgdown.yml as text and keeps comments and long lines", {
  create_local_package()
  rlang::local_interactive(FALSE)
  src <- make_brand_source()
  funding <- paste("        text: This project was funded by the [Open Research Data Program",
                   "of the ETH Board](https://ethrat.ch/en/eth-domain/open-research-data/).")
  config <- c("# a comment that must survive",
              "url: https://openwashdata.github.io/testpkg/",
              "template:",
              "  bootstrap: 5",
              "home:",
              "  sidebar:",
              "    components:",
              "      custom:",
              "        title: Funding",
              funding)
  writeLines(config, "_pkgdown.yml")
  written <- use_brand(source = src)
  expect_true("_pkgdown.yml" %in% written)
  after <- readLines("_pkgdown.yml")
  expect_true(all(config %in% after))
  expect_identical(yaml::read_yaml("_pkgdown.yml")$template$bslib$brand, "_brand.yml")
  expect_length(use_brand(source = src), 0)
  expect_identical(readLines("_pkgdown.yml"), after)
})

test_that("use_brand falls back to the yaml rewrite when bslib settings exist", {
  create_local_package()
  rlang::local_interactive(FALSE)
  src <- make_brand_source()
  writeLines(c("template:", "  bootstrap: 5", "  bslib:", "    primary: '#5b195b'"), "_pkgdown.yml")
  use_brand(source = src)
  config <- yaml::read_yaml("_pkgdown.yml")
  expect_identical(config$template$bslib$brand, "_brand.yml")
  expect_identical(config$template$bslib$primary, "#5b195b")
})

test_that("use_brand adds a template block when _pkgdown.yml has none", {
  create_local_package()
  rlang::local_interactive(FALSE)
  src <- make_brand_source()
  writeLines(c("# site", "url: https://example.org/"), "_pkgdown.yml")
  use_brand(source = src)
  config <- yaml::read_yaml("_pkgdown.yml")
  expect_identical(config$template$bslib$brand, "_brand.yml")
  expect_identical(config$template$bootstrap, 5L)
  expect_identical(readLines("_pkgdown.yml")[1], "# site")
})

# The default ref (#128): the latest release tag, recorded in DESCRIPTION.
local_brand_release <- function(tag, src, env = parent.frame()) {
  testthat::local_mocked_bindings(
    latest_brand_ref = function(repo) tag,
    brand_base_url = function(repo, ref) src,
    .env = env
  )
}

test_that("use_brand installs the latest release tag and records it (#128)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  src <- make_brand_source()
  local_brand_release("v1.1.0", src)
  expect_message(written <- use_brand(pkgdown = FALSE), "installed at")
  expect_setequal(written, c("_brand.yml", "logos/icon.png"))
  expect_identical(washr_config("brand"), "v1.1.0")

  before <- tools::md5sum(list.files(".", recursive = TRUE, all.files = TRUE))
  expect_message(again <- use_brand(pkgdown = FALSE), "up to date at")
  expect_length(again, 0)
  expect_identical(tools::md5sum(list.files(".", recursive = TRUE, all.files = TRUE)), before)
})

test_that("use_brand reports the old and the new ref after a brand release (#128)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  src <- make_brand_source()
  local_brand_release("v1.0.0", src)
  suppressMessages(use_brand(pkgdown = FALSE))
  writeBin(as.raw(8:1), file.path(src, "logos", "icon.png"))
  local_brand_release("v1.1.0", src)
  expect_message(written <- use_brand(pkgdown = FALSE), "moved from")
  expect_identical(written, "logos/icon.png")
  expect_identical(washr_config("brand"), "v1.1.0")
})

test_that("use_brand takes an explicit ref without asking for the latest tag (#128)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  src <- make_brand_source()
  testthat::local_mocked_bindings(
    latest_brand_ref = function(repo) stop("must not be called"),
    brand_base_url = function(repo, ref) src
  )
  suppressMessages(use_brand(ref = "main", pkgdown = FALSE))
  expect_identical(washr_config("brand"), "main")
})

test_that("use_brand reads the brand repository from DESCRIPTION (#81)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  src <- make_brand_source()
  asked <- NULL
  testthat::local_mocked_bindings(
    latest_brand_ref = function(repo) { asked <<- repo; "v2.0.0" },
    brand_base_url = function(repo, ref) src
  )
  desc::desc_set(`Config/washr/brand-source` = "exampleorg/brand")
  suppressMessages(use_brand(pkgdown = FALSE))
  expect_identical(asked, "exampleorg/brand")

  desc::desc_set(`Config/washr/brand-source` = "none")
  unlink(c("_brand.yml", "logos"), recursive = TRUE)
  expect_message(written <- use_brand(pkgdown = FALSE), "No brand repository")
  expect_length(written, 0)
  expect_false(file.exists("_brand.yml"))
})

test_that("use_brand names the repository and the ref when the lookup or the download fails (#128)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  testthat::local_mocked_bindings(
    latest_release_tag = function(repo) NULL,
    github_api = function(endpoint) NULL
  )
  expect_error(use_brand(pkgdown = FALSE), "latest release tag of .*openwashdata/brand")
  testthat::local_mocked_bindings(
    latest_brand_ref = function(repo) "v9.9.9",
    brand_base_url = function(repo, ref) "http://127.0.0.1:9/brand"
  )
  expect_error(use_brand(pkgdown = FALSE), "openwashdata/brand carries the file at the ref \"v9.9.9\"")
})

test_that("latest_brand_ref prefers the latest release and falls back to the highest tag (#128)", {
  testthat::local_mocked_bindings(
    latest_release_tag = function(repo) "v1.1.0",
    github_api = function(endpoint) stop("must not be called")
  )
  expect_identical(latest_brand_ref("openwashdata/brand"), "v1.1.0")
  testthat::local_mocked_bindings(
    latest_release_tag = function(repo) NULL,
    github_api = function(endpoint) {
      list(list(name = "v1.2.0"), list(name = "v1.10.0"), list(name = "draft"), list(name = "v1.9.3"))
    }
  )
  expect_identical(latest_brand_ref("openwashdata/brand"), "v1.10.0")
})
