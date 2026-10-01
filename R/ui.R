# User-facing messages (#84). Every message goes through cli, with the same
# three kinds in every function: a success line for what was written, an info
# line for what was kept or skipped, and an arrow line for the next step that
# is left to the user. Errors use cli::cli_abort() and warnings
# cli::cli_warn() directly.
#
# options(washr.quiet = TRUE) silences the three kinds and the usethis
# helpers washr calls. Warnings and errors are never silenced.

is_quiet <- function() {
  isTRUE(getOption("washr.quiet", FALSE))
}

ui_done <- function(text, .envir = parent.frame()) {
  if (!is_quiet()) cli::cli_alert_success(text, .envir = .envir)
  invisible(NULL)
}

ui_info <- function(text, .envir = parent.frame()) {
  if (!is_quiet()) cli::cli_alert_info(text, .envir = .envir)
  invisible(NULL)
}

ui_todo <- function(text, .envir = parent.frame()) {
  if (!is_quiet()) cli::cli_alert(text, .envir = .envir)
  invisible(NULL)
}

# Pass washr.quiet on to usethis for the rest of the calling function.
local_quiet <- function(.frame = parent.frame()) {
  if (is_quiet()) rlang::local_options(usethis.quiet = TRUE, .frame = .frame)
  invisible(NULL)
}

# Abort unless the working directory is the root of a package.
check_pkg_root <- function(call = rlang::caller_env()) {
  if (is_pkg()) return(invisible(TRUE))
  cli::cli_abort(c(
    "You are not in the correct working directory for developing the data package.",
    "i" = "Run this from the package root, which holds DESCRIPTION and NAMESPACE."
  ), call = call)
}
