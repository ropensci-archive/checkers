# reading in the data for chapter 1

#' @import data.table
#' @import dplyr
#' @import tidyr
#' @import jsonlite
#' @examples 
#' mungeRelativeAbundance(fread("cache/All_data_for_data_release.csv"), "mungedRelativeAbundance.tsv")

mungeRelativeAbundance <- function(raw.data, target_name){

  
  # allSizes <- filter(raw.data, sizeCategory == "total_all")
  # allSizes <- filter(allSizes, towLength_m.y != "DI BLANK")
  
  raw.data$sizeCategory <- ifelse(raw.data$sizeCategory == "0.125mm_1mm", "0.333mm_1mm", raw.data$sizeCategory)
  
  relAbundAll <- raw.data %>%
    group_by(sizeCategory) %>%
    summarise(
      meanRelAbundFrag = mean(relAbundFrag, na.rm=TRUE),
      meanRelAbundPellet = mean(relAbundPellet, na.rm=TRUE),
      meanRelAbundLine = mean(relAbundLine, na.rm=TRUE),
      meanRelAbundFilm = mean(relAbundFilm, na.rm=TRUE),
      meanRelAbundFoam = mean(relAbundFoam, na.rm=TRUE)) 
  
  # scale the means so they add up to 100% for each size class"
  relAbundAll$totalMeans <- relAbundAll$meanRelAbundFrag + relAbundAll$meanRelAbundPellet + relAbundAll$meanRelAbundLine + 
    relAbundAll$meanRelAbundFilm + relAbundAll$meanRelAbundFoam  
  relAbundAll$scaledFrag <- relAbundAll$meanRelAbundFrag / relAbundAll$totalMeans
  relAbundAll$scaledPellet <- relAbundAll$meanRelAbundPellet / relAbundAll$totalMeans
  relAbundAll$scaledLine <- relAbundAll$meanRelAbundLine / relAbundAll$totalMeans
  relAbundAll$scaledFilm <- relAbundAll$meanRelAbundFilm / relAbundAll$totalMeans
  relAbundAll$scaledFoam <- relAbundAll$meanRelAbundFoam / relAbundAll$totalMeans
  
  # filter to only size category "total"
  relAbundAll <- filter(relAbundAll, sizeCategory == "total_all")
  
  # filter to just scaled means
  relAbundScaled <- select(relAbundAll, scaledFrag:scaledFoam)
  
  relAbundAllLong <- t(relAbundScaled)
  
  percent.data <- data.frame(Microplastic.Type = row.names(relAbundAllLong), 
                             Percent.Type = relAbundAllLong*100,
                             stringsAsFactors = FALSE) 
  row.names(percent.data) <- NULL
  
  percent.data <- rowwise(percent.data) %>% 
              mutate(Figure.Name = switch(Microplastic.Type,
                        scaledFrag = "Fragment",
                        scaledPellet = "Pellet/Bead",
                        scaledLine = "Fiber/Line",
                        scaledFilm = "Film",
                        scaledFoam = "Foam"))
  # 
  # clean.data <- allSizes %>% 
  #   select(starts_with('count')) %>% 
  #   gather() %>% 
  #   rename(Microplastic.Type = key, Count = value) %>% 
  #   group_by(Microplastic.Type) %>% 
  #   summarize(Count = sum(Count, na.rm = TRUE)) 
  # 
  # total.count <- clean.data$Count[which(clean.data$Microplastic.Type == "countTotal")]
  # 
  # percent.data <- clean.data %>% 
  #   mutate(Percent.Type = (Count/total.count)*100) %>% 
  #   filter(!Microplastic.Type %in% c("countOther", "countTotal")) %>% 
  #   rowwise() %>% 
  #   mutate(Figure.Name = switch(Microplastic.Type,
  #                               countFrag = "Fragment",
  #                               countPellet = "Pellet/Bead",
  #                               countLine = "Fiber/Line",
  #                               countFilm = "Film",
  #                               countFoam = "Foam"))
  
  write.table(percent.data, target_name, sep="\t")
  return(target_name)
}
