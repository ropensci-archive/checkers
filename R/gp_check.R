#' Wrapper of goodpractice gp
#'
#' @param path Path to a data analysis root.
#' @param checks Character vector, the checks to run. Defaults to
#'   all checks.
#' @param extra_preps Custom preparation functions. See
#'   \code{\link[goodpractice]{make_prep}} on creating preparation functions.
#' @param extra_checks Custom checks.
#' @param quiet Whether to suppress output from the preparation
#'   functions. Note that not all preparation functions produce output,
#'   even if this option is set to \code{FALSE}.
#' @return A checkers object that you can query
#'   with a simple API. See \code{\link{results}} to start.
#' @export
#' @importFrom goodpractice gp
#' @importFrom goodpractice all_checks
#' @examples
#' check_results <- gp_check(path=system.file("scripts", package="checkers"),
#'          checks = "comments",
#'          extra_preps = list(scripts = prep_scripts),
#'          extra_checks = list(comments = check_well_commented))
#' check_results
gp_check <- function(path = ".", checks = all_checkers(),
                     extra_preps = all_prepers(),
                     extra_checks =all_extra_checkers(),
                     quiet = TRUE){

  if(is.null(options()$checker)){
    load_config()
  }

  gp_out <- gp(path = path,
               checks = checks,
               extra_preps = extra_preps,
               extra_checks = extra_checks,
               quiet = quiet)

  return(gp_out)
}
