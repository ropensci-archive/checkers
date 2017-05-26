#' @import data.table
#' @import dplyr
#' @import reshape2
#' @import readxl
#' @examples 
#' raw.data <- setDF(fread("cache/All_data_for_data_release.csv"))
#' data.in <- mungeLandUse(raw.data)
#' mungeLandUsePct(data.in, "cache/munged_LandUse_geomPct.tsv")
#' mungeLandUseConc(data.in, "cache/munged_LandUse_geomConc.tsv")
mungeLandUse <- function(raw.data){

  # ignore size classes for now, just look at totals
  allSizes <- filter(raw.data, sizeCategory == "total_all")
  
  # remove leftover blanks
  allSizes <- filter(allSizes, towLength_m.y != "DI BLANK")
  
  allSizesSub <- subset(allSizes, select=c("shortName", "UrbanPct", "populationDensity",
                                           "AgTotalPct","ForestPct","Water_WetlandPct","OtherLandUsePct",
                                           "sampleDate","flowCondition","flowConditionAKB",
                                           "conc_per_m3_frag","conc_per_m3_pellet","conc_per_m3_line",
                                           "conc_per_m3_film","conc_per_m3_foam"))

  allSizesSub$shortName[allSizesSub$shortName == "StLouis, MN"] <- "St Louis, MN"
  allSizesSub$shortName[allSizesSub$shortName == "StJoseph, MI"] <- "St Joseph, MI"
  
  siteOrder <- unique(allSizesSub$shortName)
  siteOrder <- siteOrder[c(1:2,29,3:28)]
  
  site.df <- data.frame(shortName = siteOrder, num=1:length(siteOrder), stringsAsFactors = FALSE)
  
  siteAvg <- mutate(allSizesSub, OtherPct = ForestPct + Water_WetlandPct + OtherLandUsePct) %>%
    group_by(shortName, UrbanPct, OtherPct, AgTotalPct) %>%
    summarise(meanFrag = mean(conc_per_m3_frag, na.rm=TRUE),
              meanPellet = mean(conc_per_m3_pellet, na.rm=TRUE),
              meanFiber = mean(conc_per_m3_line, na.rm=TRUE),
              meanFilm = mean(conc_per_m3_film, na.rm=TRUE),
              meanFoam = mean(conc_per_m3_foam, na.rm=TRUE)) %>%
    ungroup() %>%
    left_join(site.df) %>%
    arrange(num)
  
  # convert to long
  conc.summary <- melt(siteAvg, id.vars=c("shortName", "UrbanPct", "OtherPct", "AgTotalPct"), variable.name="type", value.name="conc_per_m3")

  # find position for site bars on the x-axis
  sites <- unique(conc.summary$shortName)
  
  sites[sites == "StLouis, MN"] <- "St Louis, MN"
  sites[sites == "StJoseph, MI"] <- "St Joseph, MI"
  
  num.sites <- length(sites)
  rect.seq <- seq(0, 100, length.out = num.sites+1)
  
  site.geom.df <- data.frame(site.name = sites,
                                 x.left = head(rect.seq, -1),
                                 x.right = tail(rect.seq, -1),
                                 stringsAsFactors = FALSE) %>% 
    rowwise() %>% 
    mutate(x.middle = mean(c(x.left, x.right))) %>% 
    ungroup()
  
  return(list(conc.summary = conc.summary, site.geom.df = site.geom.df))
}

#' @examples 
#' SI1 <- read_excel("cache/SI_Table 1_site_characteristics_for_PUB_2.xlsx", skip = 2)

mungeSiteTable <- function(SI1, target_name){
  # SI1 <- read_excel(file.path(tempFolder, files$fname[2]), skip = 2)
  land.per.cols <- which(is.na(names(SI1)))
  land.per.cols <- c(land.per.cols[1]-1, land.per.cols)
  names(SI1)[land.per.cols] <- SI1[1,land.per.cols]
  SI1 <- SI1[-1,]
  SI1[,land.per.cols] <- sapply(SI1[,land.per.cols], function(x) as.numeric(x))
  write.table(SI1, file=target_name, sep="\t")
  return(SI1)
}

mungeLandUsePct <- function(data.in, fname.output){
  
  data.in.landuse <- data.in$conc.summary %>% 
    rename(site.name = shortName) %>% 
    select(-c(type, conc_per_m3)) %>% 
    unique() %>% 
    gather(key = 'landuse.type', value = 'landuse.pct', -site.name)
 
  geom.df.landuse.urban <- data.in.landuse %>%
    filter(landuse.type == "UrbanPct") %>% 
    mutate(y.bottom = 0,
           y.top = landuse.pct) 
  
  geom.df.landuse.ag <- data.in.landuse %>%
    filter(landuse.type == "AgTotalPct") %>% 
    inner_join(geom.df.landuse.urban[c('site.name','y.top')], by='site.name') %>% 
    mutate(y.bottom = y.top, y.top = y.top+landuse.pct)
  
  geom.df.landuse.other <- data.in.landuse %>%
    filter(landuse.type == "OtherPct") %>% 
    inner_join(geom.df.landuse.ag[c('site.name','y.top')], by='site.name') %>% 
    mutate(y.bottom = y.top, y.top = 100) # verified that these sum to either 100, 99.9 or 100.1
  
  geom.df.landuse <- bind_rows(geom.df.landuse.urban, 
                               geom.df.landuse.ag,
                               geom.df.landuse.other)
  
  sites <- data.in$site.geom.df

  geom.df.landuse <- left_join(sites, geom.df.landuse) %>% 
    rowwise() %>% 
    mutate(rect.col = switch(landuse.type,
                             UrbanPct = "#D2372C",
                             AgTotalPct = "#ffcc0a",
                             OtherPct = "#9BD733")) %>% 
    ungroup()
  
  write.table(geom.df.landuse, file=fname.output, sep="\t")
  return(fname.output)
}

mungeLandUseConc <- function(data.in, fname.output){
  
  data.in.conc <- data.in$conc.summary %>% 
    select(-c(UrbanPct, OtherPct, AgTotalPct)) %>% 
    rename(site.name = shortName) %>% 
    mutate(type = factor(type, levels = c("meanPellet", "meanFilm", "meanFoam", 
                                          "meanFrag", "meanFiber")), ordered = TRUE) 
  
  geom.df.conc.pellet <- data.in.conc %>%
    filter(type == "meanPellet") %>% 
    mutate(y.bottom = 0,
           y.top = conc_per_m3)
  
  geom.df.conc.film <- data.in.conc %>%
    filter(type == "meanFilm") %>% 
    inner_join(geom.df.conc.pellet[c('site.name','y.top')], by='site.name') %>% 
    mutate(y.bottom = y.top, y.top = y.top+conc_per_m3)
  
  geom.df.conc.foam <- data.in.conc %>%
    filter(type == "meanFoam") %>% 
    inner_join(geom.df.conc.film[c('site.name','y.top')], by='site.name') %>% 
    mutate(y.bottom = y.top, y.top = y.top+conc_per_m3)
  
  geom.df.conc.frag <- data.in.conc %>%
    filter(type == "meanFrag") %>% 
    inner_join(geom.df.conc.foam[c('site.name','y.top')], by='site.name') %>% 
    mutate(y.bottom = y.top, y.top = y.top+conc_per_m3)
  
  geom.df.conc.fiber <- data.in.conc %>%
    filter(type == "meanFiber") %>% 
    inner_join(geom.df.conc.frag[c('site.name','y.top')], by='site.name') %>% 
    mutate(y.bottom = y.top, y.top = y.top+conc_per_m3)
  
  geom.df.conc <- bind_rows(geom.df.conc.pellet, geom.df.conc.film,
                            geom.df.conc.foam, geom.df.conc.frag, 
                            geom.df.conc.fiber)
  
  sites <- data.in$site.geom.df

  geom.df.conc <- left_join(sites, geom.df.conc) %>% 
    rowwise() %>% 
    mutate(rect.col = switch(as.character(type),
                             meanPellet = "#4ebec2",
                             meanFilm = "#0b516b",
                             meanFoam = "#01b29F",
                             meanFrag = "#aadedc",
                             meanFiber = "#26b9da")) %>% 
    ungroup()
  
  write.table(geom.df.conc, file=fname.output, sep="\t")
  return(fname.output)
}
  