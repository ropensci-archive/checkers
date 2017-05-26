#' @title Load checkers config
#'
#' @description Loads the config file into options which are
#'used elsewhere in the application.
#'
#' @param filename string to custom file
#'
#' @examples
#' load_config()
#' @export
#' @importFrom yaml yaml.load_file
load_config = function(filename) {

  if(missing(filename)){
    filename <- system.file("extdata", "default.yaml", package = "checkers")
  }

  checkers <- yaml.load_file(filename)

  options(checkers = checkers)
}


