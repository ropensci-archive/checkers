# To test this:
# check_gam <- make_fun_pair_check("gam", "gam.check")
# gp_check(path=system.file("scripts", package="checkers"),
#          checks = "check_gam",
#   extra_preps = list(functions = prep_functions),
#   extra_checks = list(check_gam = check_gam))


#' @importFrom utils getParseData
get_functions <- function(f) {
    pp <- parse(file = f, keep.source = TRUE)
    pd <- getParseData(pp)
    script_funs <- unique(pd$text[ pd$token %in% "SYMBOL_FUNCTION_CALL" ])
    script_funs
}

#' @export
#' @importFrom goodpractice make_prep
prep_functions <- make_prep("functions", function(path, quiet) {
    scripts <- r_script_files(path)
    funs <- unique(unlist(lapply(scripts, get_functions)))
    return(funs)
})

#' @export
make_fun_pair_check <- function(fun1, fun2) {

  make_check(
    description = paste0("Use", fun2, " if you use ", fun1),
    tags = character(0),
    preps = c("functions"),

    gp = function(state) {
      paste0(
        "Follow-up analyses with appropriate checks. You run `", fun1,
        "()` but never run `", fun2, "()`."
      )
    },
    check = function(state) {
      !(fun1 %in% state$functions && !(fun2 %in% state$functions))
    }
  )
}






