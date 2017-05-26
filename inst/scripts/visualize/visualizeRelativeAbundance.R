#' @import dinosvg
#' @import dplyr
#' @import yaml
#' @import XML
#' @examples 
#' visualizeRelativeAbundance("desktop","cache/mungedRelativeAbundance.tsv","data/siteText.yaml","test.svg")


# Functions directly called by remake::make('figures_R.yaml')
visualizeRelativeAbundance_mobile <- function(...) {
  visualizeRelativeAbundance('mobile', ...)
}
visualizeRelativeAbundance_desktop <- function(...) {
  visualizeRelativeAbundance('desktop', ...)
}
visualizeRelativeAbundance_ie <- function(...) {
  visualizeRelativeAbundance('ie', ...)
}

# The workhorse function
visualizeRelativeAbundance <- function(tag='desktop', file.in, file.text, target_name){

  template.svg = paste(readLines('data/relativeAbundance.mustache'), collapse='\n')
  json.file <- sprintf('data/relativeAbundance-%s.json', tag)
  pointers = paste(readLines(json.file), collapse='\n')
  cat(whisker.render(template.svg, data= list('pointers-json'=pointers)),file = target_name)
}
