options(usethis.quiet = TRUE)

test_that("setup_ci() writes the check workflow with the dev trigger and build ignores .github (#86)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  path <- setup_ci()
  expect_identical(path, file.path(".github", "workflows", "R-CMD-check.yaml"))
  expect_true(file.exists(path))
  # yaml parses the key `on` as the boolean TRUE (YAML 1.1), so the triggers
  # are checked on the raw lines
  lines <- readLines(path)
  expect_identical(sum(grepl("^    branches: \\[main, master, dev\\]$", lines)), 2L)
  wf <- yaml::read_yaml(path)
  expect_identical(wf$name, "R-CMD-check")
  expect_length(wf$jobs$`R-CMD-check`$strategy$matrix$config, 5)
  expect_true("^\\.github$" %in% readLines(".Rbuildignore"))
})

test_that("setup_ci() keeps an existing workflow file as it is", {
  create_local_package()
  rlang::local_interactive(FALSE)
  dir.create(file.path(".github", "workflows"), recursive = TRUE)
  writeLines("name: hand written", file.path(".github", "workflows", "R-CMD-check.yaml"))
  withr::with_options(list(usethis.quiet = FALSE),
                      expect_message(setup_ci(), "kept as it is"))
  expect_identical(readLines(file.path(".github", "workflows", "R-CMD-check.yaml")), "name: hand written")
})

test_that("setup_ci() adds the badge to an existing README.Rmd once, from the repository URL (#86)", {
  pkg <- create_local_package()
  rlang::local_interactive(FALSE)
  desc::desc_set_urls("https://github.com/someorg/somepkg")
  writeLines(c("# pkg", "<!-- badges: start -->", "<!-- badges: end -->"), "README.Rmd")
  setup_ci()
  readme <- readLines("README.Rmd")
  badge <- grep("R-CMD-check.yaml/badge.svg", readme, fixed = TRUE, value = TRUE)
  expect_length(badge, 1)
  expect_match(badge, "github.com/someorg/somepkg/actions", fixed = TRUE)
  expect_identical(which(readme == badge), which(readme == "<!-- badges: end -->") - 1L)
  setup_ci()
  expect_length(grep("R-CMD-check.yaml/badge.svg", readLines("README.Rmd"), fixed = TRUE), 1)
})

test_that("setup_ci() falls back to the openwashdata organisation without a repository URL", {
  pkg <- create_local_package()
  rlang::local_interactive(FALSE)
  writeLines(c("<!-- badges: start -->", "<!-- badges: end -->"), "README.Rmd")
  setup_ci()
  badge <- grep("badge.svg", readLines("README.Rmd"), fixed = TRUE, value = TRUE)
  expect_match(badge, paste0("github.com/openwashdata/", basename(pkg), "/actions"), fixed = TRUE)
})

test_that("the README template carries the check badge (#86)", {
  create_local_package()
  rlang::local_interactive(FALSE)
  d1 <- data.frame(id = 1:3)
  usethis::use_data(d1)
  setup_readme()
  expect_true(any(grepl("actions/workflows/R-CMD-check.yaml/badge.svg", readLines("README.Rmd"), fixed = TRUE)))
})

test_that("setup_ci() stops outside a package", {
  withr::local_dir(withr::local_tempdir())
  expect_error(setup_ci(), "not in the correct working directory")
})
