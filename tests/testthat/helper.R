## Adapted from usethis package: https://github.com/r-lib/usethis/blob/9e64daf13ac1636187d59e6446d9526a414d8ba6/tests/testthat/helper.R

## MIT License
## Copyright (c) 2020 usethis authors
## Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
## The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

create_local_package <- function(dir = tempfile(pattern = "testpkg"),
                                 env = parent.frame(),
                                 rstudio = FALSE) {
  create_local_thing(dir, env, rstudio, "package")
}

create_local_thing <- function(dir = tempfile(pattern = pattern),
                               env = parent.frame(),
                               rstudio = FALSE,
                               thing = c("package", "project")) {
  thing <- match.arg(thing)
  if (dir.exists(dir)) {
    stop("Target dir ", dir, " already exists.")
  }

  # could be `NULL`, i.e. no active project
  old_project <- tryCatch(usethis::proj_get(), error = function(e) NULL)
  old_wd <- getwd()          # not necessarily same as `old_project`

  withr::defer(unlink(dir, recursive = TRUE), envir = env)

  switch(
      thing,
      package = usethis::create_package(
        dir,
        # This is for the sake of interactive development of snapshot tests.
        # When the active usethis project is a package created with this
        # function, testthat learns its edition from *that* package, not from
        # usethis. So, by default, opt in to testthat 3e in these ephemeral test
        # packages.
        fields = list("Config/testthat/edition" = "3"),
        rstudio = rstudio,
        open = FALSE,
        check_name = FALSE
      ),
      project = usethis::create_project(dir, rstudio = rstudio, open = FALSE)
    )

  withr::defer(usethis::proj_set(old_project, force = TRUE), envir = env)
  usethis::proj_set(dir)

  withr::defer(setwd(old_wd), envir = env)
  setwd(usethis::proj_get())

  invisible(usethis::proj_get())
}
