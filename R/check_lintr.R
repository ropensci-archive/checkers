lint_directory = function (path = ".", relative_path = TRUE, ...)
{
  files <- dir(path = path,
               pattern = "\\.(R|r|Rmd|rmd)$", recursive = TRUE,
               full.names = TRUE)
  files <- normalizePath(files)
  lints <- lintr:::flatten_lints(lapply(files, function(file) {
    lint(file, ..., parse_settings = FALSE)
  }))
  lints <- lintr:::reorder_lints(lints)
  if (relative_path == TRUE) {
    lints[] <- lapply(lints, function(x) {
      x$filename <- rex::re_substitutes(x$filename, rex::rex(normalizePath(path),
                                                   one_of("/", "\\")), "")
      x
    })
    attr(lints, "path") <- path
  }
  class(lints) <- "lints"
  return(lints)
}

#' Prep for linting
#' This prep function is used to overwrite the goodpractice "lintr" prep
#' function so as to lint the entire directory rather than just package
#' files.
#' @export
prep_lint_dir <- make_prep("lintr", function(path, quiet) {
  path <- normalizePath(path)
  suppressMessages(
    lintr <- lint_directory(path, linters = goodpractice:::linters_to_lint)
  )
  return(lintr)
})

#goodpractice::gp(".", checks = "lintr_assignment_linter", extra_checks = list(), extra_preps = list(lintr=prep_lint_dir))
