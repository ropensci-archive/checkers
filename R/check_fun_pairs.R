# To test this:
# x <- gp_check(path=system.file("scripts", package="checkers"),
#          checks = "fun_pairs",
#   extra_preps = list(version_control = prep_fun_pairs),
#   extra_checks = list(version_control = check_fun_pairs))


#' @importFrom utils getParseData
get_functions <- function(f) {
    pp <- parse(file = f, keep.source = TRUE)
    pd <- getParseData(pp)
    script_funs <- unique(pd$text[ pd$token %in% "SYMBOL_FUNCTION_CALL" ])
    script_funs
}

    


#' @export
#' @importFrom goodpractice make_prep
prep_fun_pairs <- make_prep("fun_pairs", function(path, quiet) {
    scripts <- r_script_files(path)
    funs <- do.call(rbind, lapply(scripts, get_functions))
    funs <- unique(funs)
    return(list(funs = funs))
})






