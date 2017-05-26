# function to clear the cached files from data/cache

clearCache <- function(names = NULL){
  cache_folder <- 'cache'
  cache_files <- list.files(cache_folder)
  
  if(is.null(names)){
    file.remove(file.path(cache_folder, cache_files))
    return(paste(length(cache_files), 'file(s) cleared'))
  } else {
    file.remove(file.path(cache_folder, names))
    return(paste(length(names), 'file(s) cleared'))
  }
  
}
