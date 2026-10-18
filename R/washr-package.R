#' @section Messages and return values:
#' Every function reports through cli with three kinds of lines: a success
#' line for a file it wrote, an info line for something it kept or skipped,
#' and an arrow line for the next step that is left to you. Each function
#' returns what it wrote, invisibly: the path of the file, or the paths when
#' there are several. [update_metadata()] returns the metadata as a list.
#'
#' Set `options(washr.quiet = TRUE)` to silence these lines, for example in
#' scripts. Warnings and errors are never silenced.
#'
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom lifecycle deprecated
## usethis namespace: end
NULL
