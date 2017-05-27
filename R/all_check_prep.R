#' @export
#' @examples
#'
all_checkers <- function(){

  main_defaults <- c("comments","version_control")

  if(length(options()$checkers[["goodpractice"]]) > 0){
    main_defaults <- c(main_defaults, options()$checkers[["goodpractice"]])
  }

  pref_list <- options()$checkers[["make_pref_pkg_check"]]
  if_then_list <- options()$checkers[["if_this_than_that"]]

  if(length(pref_list) > 0){
    main_defaults <- c(main_defaults, names(pref_list))
  }

  if(length(if_then_list) > 0){
    main_defaults <- c(main_defaults, names(if_then_list))
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
  if_then_list <- options()$checkers[["if_this_than_that"]]

  if(length(pref_list) > 0){
    for(i in names(pref_list)){
      favored <- pref_list[[i]]$favored
      unfavored <- pref_list[[i]]$unfavored
      check_fun <- make_pref_pkg_check(favored = favored,
                                       unfavored = unfavored)
      main_defaults[[i]] <- check_fun
    }
  }

  if(length(if_then_list) > 0){
    for(i in names(if_then_list)){
      if_this <- if_then_list[[i]]$if_this
      needs_that <- if_then_list[[i]]$needs_that
      check_fun <- make_fun_pair_check(fun1 = if_this,
                                       fun2 = needs_that)
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
              "functions" = prep_functions,
              "lintr" = prep_lint_dir,
              "packages" = prep_packages))
}
