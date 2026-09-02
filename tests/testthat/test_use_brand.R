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
