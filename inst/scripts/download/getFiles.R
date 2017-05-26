# function to cache files in data/cache

library(sbtools)
getFiles <- function(item.id, names = NULL, lookup.table){

  cache_folder <- 'cache'

  # look up table
  #data.relative.abundance matches with All_data_for_data_release.csv

  if(!dir.exists(cache_folder)){
    dir.create(cache_folder)
  }

  if(is.null(names)){
    files <- item_list_files(item.id)
    fpath <- file.path(cache_folder, files$fname)
    fexists <- file.exists(fpath)
    fpath_exists <- fpath[fexists]
    fpath_download <- item_file_download(item.id, names = files$fname[!fexists],
                                         destinations = fpath[!fexists])
  } else {
    fpath <- file.path(cache_folder, names)
    fexists <- file.exists(fpath)
    fpath_exists <- fpath[fexists]
    fpath_download <- NULL
    if(any(!fexists)){
      fpath_download <- item_file_download(item.id, names = names[!fexists],
                                           destinations = fpath[!fexists])
    }
  }

  names(fpath_exists) <- rep("Existed", length(fpath_exists))
  if(!is.null(fpath_download)){
    names(fpath_download) <- rep("Downloaded", length(fpath_exists))
  }

  fresults <- c(fpath_exists, fpath_download)
  return(fresults)
}
