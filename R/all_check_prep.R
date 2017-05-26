#' @export
#' @examples
#'
all_checkers <- function(){
  return(c("comments","version_control"))
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
              "version_control" = prep_version_control))
}
