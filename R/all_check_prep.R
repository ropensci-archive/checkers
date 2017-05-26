#' @export
#' @examples
#'
all_checkers <- function(){

  main_defaults <- c("comments","version_control")

  if(length(options()$checkers[["goodpractice"]]) > 0){
    main_defaults <- c(main_defaults, options()$checkers[["goodpractice"]])
  }

  return(main_defaults)
}

#' @export
#' @examples
#'
all_extra_checkers <- function(){
  return(list("comments"=check_well_commented,
                "version_control"=check_version_control))
}

#' @export
#' @examples
#'
all_prepers <- function(){
  return(list("scripts" = prep_scripts,
              "version_control" = prep_version_control,
              "lintr" = prep_lint_dir))
}
