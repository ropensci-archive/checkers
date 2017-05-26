# check_xml <- make_pref_pkg_check("XML", "xml2")
# goodpractice::gp("inst/scripts", checks="XML", extra_preps=list(packages=prep_packages), extra_checks = list(XML = check_xml))
#' @export
prep_packages = make_prep("packages", function(path, quiet) {
  packrat:::dirDependencies(path)
  })

#' @export
make_pref_pkg_check <- function(unfavored, favored) {

  make_check(
    description = paste0(unfavored,
                         " is an unfavored package"),
    tags = character(0),
    preps = c("packages"),

    gp = function(state) {
      paste0(
        "Use preferred packages. You are using ", unfavored,
        ". Preferred alternatives are: ",
        paste0(favored, collapse = ", "), ".")
    },
    check = function(state) {
      !(unfavored %in% state$packages)
    }
  )
}
