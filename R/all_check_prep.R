#' @export
#' @examples
#'
all_checkers <- function(){

  main_defaults <- c("comments","version_control")

  if(length(options()$checkers[["goodpractice"]]) > 0){
    main_defaults <- c(main_defaults, options()$checkers[["goodpractice"]])
  }

  if(length(options()$checkers[["make_pref_pkg_check"]]) > 0){
    main_defaults <- c(main_defaults, names(options()$checkers[["make_pref_pkg_check"]]))
  }

  return(main_defaults)
}

#' @export
#' @examples
#'
all_extra_checkers <- function(){
  main_defaults <- list("comments"=check_well_commented,
                        "version_control"=check_version_control)

  pref_list <- options()$checkers[["make_pref_pkg_check"]]

  if(length(pref_list) > 0){

    for(i in names(pref_list)){
      favored <- pref_list[[i]]$favored
      unfavored <- pref_list[[i]]$unfavored
      check_fun <- make_pref_pkg_check(favored = favored,
                                       unfavored = unfavored)
      main_defaults[[i]] <- check_fun
    }

  }

  return(main_defaults)
}

#' @export
#' @examples
#'
all_prepers <- function(){
  return(list("scripts" = prep_scripts,
              "version_control" = prep_version_control,
              "lintr" = prep_lint_dir,
              "packages" = prep_packages))
}
