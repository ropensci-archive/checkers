#' @import gsplot
#' @import dinosvg
#' @examples 
#' fname.geom.conc <- 'cache/munged_LandUse_geomConc.tsv'
#' fname.geom.pct <- 'cache/munged_LandUse_geomPct.tsv'
#' fname.site <- 'cache/munged_LandUse_site.tsv'
#' gap <- 0.15
#' gs.conc <- gsplotLandUseConc(fname.geom.conc, gap)
#' gs.landuse <- gsplotLandUsePct(fname.geom.pct, gap)

# Functions directly called by remake:make('figures_R.yaml')

visualizeLandUse_mobile <- function(...) {
  visualizeLandUse('mobile', ...)
}
visualizeLandUse_desktop <- function(...) {
  visualizeLandUse('desktop', ...)
}
visualizeLandUse_ie <- function(...) {
  visualizeLandUse('ie', ...)
}

# The workhorse function
visualizeLandUse <- function(tag, fname.geom.conc, fname.geom.pct,
                             fname.fig, gap = 0.15){
  
  gs.conc <- gsplotLandUseConc(fname.geom.conc, gap)
  gs.landuse <- gsplotLandUsePct(fname.geom.pct, gap)
  
  createBarFig(gs.conc, gs.landuse, fname.fig)
  
}

# Returns gsplot object for the top part of the figure
gsplotLandUseConc <- function(fname.data, gap){
  
  geom.df <-  read.table(fname.data, sep = "\t", stringsAsFactors = FALSE)
  sites <- unique(geom.df$site.name)
  
  site.ids <- data.frame('site.name'=sites, num=1:length(sites), stringsAsFactors = FALSE)
  geom.df <- left_join(geom.df, site.ids) %>% 
    mutate(id = paste0(num,'-',type), 
           onmousemove=sprintf("hovertext('%1.1f (particles/100gal)',evt)",conc_per_m3),
           onmouseout="hovertext(' ')") %>% 
    arrange(num) %>%
    #use gap specification for spacing bars
    mutate(x.right = x.left*gap + x.right,
           x.left = x.left*(1+gap), #xright calc before xleft calc bc it needs orig xleft vals
           x.middle = rowMeans(cbind(x.left, x.right))) %>%
    mutate(y.bottom = y.bottom/2.64172,
           y.top = y.top/2.64172)
  
  gs.conc <- gsplot() %>% 
    rect(geom.df$x.left, geom.df$y.bottom, 
         geom.df$x.right, geom.df$y.top,
         lwd=0.5, col = geom.df$rect.col, 
         border = NA,
         ylab = "Plastic particles\nper 100 gallons",
         ylim=c(0,5)) %>% 
    axis(side = 2, at = seq(0, 5, by=1)) %>%
    axis(1, labels=FALSE, lwd.tick = 0)
  
  # hack because we need to support gs extensions
  gs.conc$view.1.2$rect$id=geom.df$id
  gs.conc$view.1.2$rect$onmousemove = geom.df$onmousemove
  gs.conc$view.1.2$rect$onmouseout = geom.df$onmouseout
  
  return(gs.conc)
}

# Returns gsplot object for the bottom part of the figure
gsplotLandUsePct <- function(fname.data, gap){
  
  geom.df <-  read.table(fname.data, sep = "\t", stringsAsFactors = FALSE)
  
  sites <- unique(geom.df$site.name)
  site.ids <- data.frame('site.name'=sites, num=1:length(sites), stringsAsFactors = FALSE)
  
  geom.df <- left_join(geom.df, site.ids) %>% 
    mutate(id = paste0(num,'-',landuse.type), 
           onmousemove=sprintf("hovertext('%1.1f (pct)',evt)",landuse.pct),
           onmouseout="hovertext(' ')") %>% 
    arrange(num) %>%
    #use gap specification for spacing bars
    mutate(x.right = x.left*gap + x.right,
           x.left = x.left*(1+gap), #xright calc before xleft calc bc it needs orig xleft vals
           x.middle = rowMeans(cbind(x.left, x.right))) 
  
  gs_landuse <- gsplot() %>% 
    rect(geom.df$x.left, geom.df$y.bottom, 
         geom.df$x.right, geom.df$y.top,
         lwd=0.5, col = geom.df$rect.col,
         border = NA,
         ylab = "Land use\n(% of basin)",
         xlab = "Sampling locations") %>% 
    axis(side = 1, at = unique(geom.df$x.middle), 
         labels = unique(geom.df$site.name), 
         tick = FALSE, las = 2, cex.axis = 0.1) %>% 
    axis(side = 2, at = seq(0, 100, by=25))
  
  gs_landuse$view.1.2$rect$id=geom.df$id
  gs_landuse$view.1.2$rect$onmousemove = geom.df$onmousemove
  gs_landuse$view.1.2$rect$onmouseout = geom.df$onmouseout
  gs_landuse$side.1$axis$id=paste0('site-',1:length(sites))
  
  # determine steps for sorting
  q.sorted <- quickSortIterative(filter(geom.df, landuse.type == 'UrbanPct') %>% .$landuse.pct)
  gs_landuse$json <- q.sorted$swaps_ids

  # determine steps for reverting the sort
  q.desorted <- quickSortIterative(q.sorted$steps_ids[nrow(q.sorted$steps_ids),])
  siteIDs <- q.desorted$steps_vals[1,]
  qsortIDs <- q.desorted$steps_ids[1,]
  q.desorted$swaps_val <- matrix(siteIDs[match(q.desorted$swaps_ids, qsortIDs)], ncol=2, byrow=FALSE)
  gs_landuse$json_reverse <- q.desorted$swaps_val

  return(gs_landuse)
}

renameViewSides <- function(svg, side){
  attRename <- function(g, attr='id'){
    attrs <- XML:::xmlAttrs(g)
    attrs[[attr]] <- paste0(attrs[[attr]],'a')
    XML:::removeAttributes(g)
    XML:::addAttributes(g, .attrs = attrs) # renaming the ids as a hack because we are adding new views with the same names
    invisible(NULL)
  }
  
  
  attRename(dinosvg:::g_mask(svg, side=side))
  attRename(dinosvg:::g_view(svg, side=side))
  attRename(dinosvg:::g_side(svg, side=side[1]))
  attRename(dinosvg:::g_side(svg, side=side[2]))
  
  xpath = sprintf("//*[local-name()='g'][@clip-path='url(#mask-%s-%s)']", side[1], side[2])
  masked.nodes <- xpathApply(dinosvg:::g_view(svg, side=c(side[1],paste0(side[2],'a'))), xpath)
  sapply(masked.nodes, function(x) attRename(x, attr='clip-path'))
  invisible(svg)
}

addParticleLegend <- function(svg, cols, id.names){
  legend.keys <- data.frame(keys=c("meanFiber","meanPellet", "meanFilm", "meanFoam", "meanFrag"), 
                            names = c("Fiber & Lines","Beads & Pellets", "Films", "Foams", "Fragments"), stringsAsFactors = FALSE)
  
  key.names <- unname(sapply(id.names, function(x) strsplit(x,'[-]')[[1]][2]))
  legend.params <- group_by(data.frame(cols=cols, keys=key.names, stringsAsFactors = FALSE), keys) %>% 
    summarize(col = unique(cols)[1]) %>% 
    left_join(legend.keys, by='keys') %>% 
    select(names, col,keys) %>% 
    arrange(keys = c("meanFiber","meanFrag", "meanFoam","meanFilm","meanPellets")) %>%
    data.frame
  axes.bounds <- xpathApply(dinosvg:::g_view(svg,c(1,2)), "//*[local-name()='g'][@id='axes']//*[local-name()='rect']")[[1]]
  y.spc = 3
  width = 8
  pos.y = as.numeric(XML:::xmlAttrs(axes.bounds)[['y']])+2.5
  pos.x = as.numeric(XML:::xmlAttrs(axes.bounds)[['x']])+2.5
  g <- newXMLNode('g', parent=svg, at=1, attrs = c(id = 'static-legend'))
  for (i in 1:nrow(legend.params)){
    newXMLNode('rect', parent=g, at=1, attrs = c(y=pos.y, x=pos.x, height=width, width=width, fill=legend.params$col[i], stroke='none'))
    pos.y = pos.y+y.spc+width
    newXMLNode('text', parent=g, attrs = c(y=pos.y-width/2, x=pos.x+width, dx="0.33em", stroke="none", fill="#000000", 'text-anchor'='begin', class='sub-label'), newXMLTextNode(legend.params$names[i]))
  }
}

addLandUseLegend <- function(svg, cols, id.names){
  key.names <- unname(sapply(id.names, function(x) strsplit(x,'[-]')[[1]][2]))
  legend.keys <- data.frame(keys=c("UrbanPct","AgTotalPct", "OtherPct"), 
                            names = c("Urban","Agriculture", "Other"), stringsAsFactors = FALSE)
  legend.params <- group_by(data.frame(cols=cols, keys=key.names, stringsAsFactors = FALSE), keys) %>% 
    summarize(col = unique(cols)[1]) %>% left_join(legend.keys, by='keys') %>% select(names, col,keys) %>% data.frame
  axes.bounds <- xpathApply(dinosvg:::g_view(svg,c(1,'2a')), "//*[local-name()='g'][@id='axes']//*[local-name()='rect']")[[1]]
  x.spc = 50
  width = 8
  pos.y = as.numeric(XML:::xmlAttrs(axes.bounds)[['y']])-15
  pos.x = as.numeric(XML:::xmlAttrs(axes.bounds)[['x']])+135
  g <- newXMLNode('g', parent=svg, at=1, attrs = c(id = 'static-legend'))
  for (i in 1:nrow(legend.params)){
    newXMLNode('rect', parent=g, at=1, attrs = c(y=pos.y, x=pos.x, height=width, width=width, fill=legend.params$col[i], stroke='none'))
    newXMLNode('text', parent=g, attrs = c(y=pos.y+width/2, x=pos.x+width, dy="0.33em", dx="0.33em", stroke="none", fill="#000000", 'text-anchor'='begin', class='sub-label'), newXMLTextNode(legend.params$names[i]))
    pos.x = pos.x+x.spc+width
  }
}
modifyAttr <- function(g, value){
  attrs <- XML:::xmlAttrs(g)
  attrs[[names(value)]] <- as.character(value)
  XML:::removeAttributes(g)
  XML:::addAttributes(g, .attrs = attrs)
  invisible(g)
}
reformatLabelText <- function(svg.side, y.top){

  g.lab <- dinosvg:::xpath_one(svg.side, "//*[local-name()='g'][@id='axis-label']")
  attrs <- XML:::xmlAttrs(g.lab)
  attrs[['text-anchor']] <- 'begin'
  XML:::removeAttributes(g.lab)
  XML:::addAttributes(g.lab, .attrs = attrs)
  lab <- dinosvg:::xpath_one(g.lab, "//*[local-name()='text']")
  text <- strsplit(xmlValue(lab),'\n')[[1]]
  xmlValue(lab) <- paste0(text[1],' ')
  newXMLNode('tspan', parent = lab, attrs = c('class'='sub-label'), newXMLTextNode(text[2]))
  attrs <- XML:::xmlAttrs(lab)
  attrs[['dx']] <- "-20"
  attrs[['dy']] = "-0.5em"
  attrs[['y']] = y.top
  attrs <- attrs[-which(names(attrs) == 'transform')]
  XML:::removeAttributes(lab)
  XML:::addAttributes(lab, .attrs = attrs)
  
}

JS_defineInitFunction <- function(){
  c('function init(evt){
    if ( window.svgDocument == null ) {
    svgDocument = evt.target.ownerDocument;
    svgDocument.sortLU = this.sortLU;}
    
}')
}

CSS_defineCSS <- function(){
  'text {
  cursor: default;
  font-family: Tahoma, Geneva, sans-serif;
}
.x-tick-label, #tooltip {
font-size: 10px;
}
.sub-label, .y-tick-label {
font-size: 8px;
}

.hidden {
opacity:0;
}
text{
font-size: 12px;

}'
}

JS_defineSwapLuFunction <- function(funname='sortLU', types, swaps.name, swap.length, duration=2){
  frame.interval <- round(duration/swap.length*1000)
  js.function <- 
    gsub('SWAPS', swaps.name, c(
      sprintf('function %s(){', funname),
      '\t var i = 0;',
      '\t window.myInterval = setInterval(function () {'   ,
      '\t\t if (i < SWAPS.length){',
      '\t\t\t var x0 = document.getElementById(SWAPS[i][0] + "-meanFiber").getAttribute("x");',
      '\t\t\t var x1 = document.getElementById(SWAPS[i][1] + "-meanFiber").getAttribute("x");',
      '\t\t\t var tr0vals = document.getElementById("site-" + SWAPS[i][0]).getAttribute("transform").split(/[,()]+/);',
      '\t\t\t var tr1vals = document.getElementById("site-" + SWAPS[i][1]).getAttribute("transform").split(/[,()]+/);',
      '\t\t\t var tr0new = tr0vals[0]+"("+tr1vals[1]+","+tr0vals[2]+") "+tr0vals[3]+"("+tr0vals[4]+")"',
      '\t\t\t var tr1new = tr1vals[0]+"("+tr0vals[1]+","+tr1vals[2]+") "+tr1vals[3]+"("+tr1vals[4]+")"',
      '\t\t\t document.getElementById("site-" + SWAPS[i][0]).setAttribute("transform", tr0new);',
      '\t\t\t document.getElementById("site-" + SWAPS[i][1]).setAttribute("transform", tr1new);',
      sprintf('\t\t\t document.getElementById(SWAPS[i][0] + "-%s").setAttribute("x", x1);',types),
      sprintf('\t\t\t document.getElementById(SWAPS[i][1] + "-%s").setAttribute("x", x0);',types),
      '\t\t\t i++',
      '\t\t} else {',
      '\t\t\t clearInterval(window.myInterval);',
      sprintf('\t}}, %s)',frame.interval),
      '}'))
  return(paste(js.function, collapse='\n'))
}

createBarFig <- function(gs.conc, gs.landuse, target_name){
  gs.landuse$global$par$mar <- c(9.1, 1.5, 15.5, 1.5)
  gs.landuse$css <- CSS_defineCSS()
  
  svg <- dinosvg::svg(gs.landuse, width = 6, height = 6.3, as.xml=TRUE, onload="init(evt)")
  
  renameViewSides(svg, gsplot:::as.side(names(gsplot:::sides(gs.landuse))))
  xlab <- dinosvg:::xpath_one(dinosvg:::g_side(svg,"1a"), "//*[local-name()='g'][@id='axis-label']//*[local-name()='text']")
  modifyAttr(xlab, c('dy' = "7.5em"))
  
  un.conc.types <- unique(unlist(lapply(gs.conc$view.1.2$rect$id,function(x) strsplit(x, '[-]')[[1]][2])))
  un.lu.types <- unique(unlist(lapply(gs.landuse$view.1.2$rect$id,function(x) strsplit(x, '[-]')[[1]][2])))
  all.types = c(un.lu.types, un.conc.types)

  LU.swaps <- jsonlite::toJSON(gs.landuse$json)
  LU.revswaps <- jsonlite::toJSON(gs.landuse$json_reverse)
  dinosvg:::add_ecmascript(svg, sprintf(
    '%s\n%s\nvar swaps = %s\nvar revswaps = %s\n%s\n%s\n%s\n%s', 
    JS_defineInitFunction(), 
    'var highlightBaseHeight = Number(document.getElementById("highlight-fill").getAttribute("height"));',
    LU.swaps, 
    LU.revswaps,
    '\t var svg = document.querySelector("svg")
     \t var pt = svg.createSVGPoint();
     \t var toolkeys = {"meanFiber":"Fiber & Lines","meanPellet":"Beads & Pellets", "meanFilm":"Films", "meanFoam":"Foams", "meanFrag":"Fragments", "UrbanPct":"Urban", "AgTotalPct":"Agriculture", "OtherPct":"Other"}
     \t var xmax = Number(svg.getAttribute("viewBox").split(" ")[2]);',
    JS_defineSwapLuFunction('sortLU', all.types, 'swaps', swap.length=nrow(gs.landuse$json), duration=1.5),
    JS_defineSwapLuFunction('sortLUrev', all.types, 'revswaps', swap.length=nrow(gs.landuse$json_reverse), duration=1.5),
    JS_defineHoverFunction()))
  gs.conc$global$par$mar <- c(17.5, 1.5, 1.5, 1.5)
  svg <- dinosvg::svg(svg, gs.conc, as.xml=TRUE)
  
  y2.pos <- XML:::xmlAttrs(XML:::xmlChildren(dinosvg:::g_mask(svg, side=c(1,2)))$rect)[['y']]
  y2a.pos <- XML:::xmlAttrs(XML:::xmlChildren(dinosvg:::g_mask(svg, side=c(1,"2a")))$rect)[['y']]
  reformatLabelText(dinosvg:::g_side(svg,"2a"), y.top=y2a.pos)
  reformatLabelText(dinosvg:::g_side(svg,"2"), y.top=y2.pos)
  
  tick.labs <- xpathApply(dinosvg:::g_side(svg,"1a"), "//*[local-name()='g'][@id='axis-side-1a']//*[local-name()='g'][@id='tick-labels']//*[local-name()='text']")
  lapply(tick.labs, modifyAttr, c('class'='x-tick-label'))
  tick.labs <- xpathApply(dinosvg:::g_side(svg,"2a"), "//*[local-name()='g'][@id='axis-side-2a']//*[local-name()='g'][@id='tick-labels']//*[local-name()='text']")
  lapply(tick.labs, modifyAttr, c('class'='y-tick-label'))
  tick.labs <- xpathApply(dinosvg:::g_side(svg,"2"), "//*[local-name()='g'][@id='axis-side-2']//*[local-name()='g'][@id='tick-labels']//*[local-name()='text']")
  lapply(tick.labs, modifyAttr, c('class'='y-tick-label'))
  
  
  addParticleLegend(svg, cols = gs.conc$view.1.2$rect$col, id.names = gs.conc$view.1.2$rect$id)
  addLandUseLegend(svg, cols = gs.landuse$view.1.2$rect$col, id.names = gs.landuse$view.1.2$rect$id)
  newXMLNode('rect', parent=svg, attrs = c(id="tooltip_bg", x="0", y="0", rx="2.5", ry="2.5", width="55", height="27", fill='white', 'stroke-width'="0.5", stroke='#696969', class="hidden"))
  newXMLNode('rect', parent=svg, attrs = c(id='tool_key', x="0", y="0", width="7", height="7", fill="none", stroke="none"))
  newXMLNode('text', parent=svg, attrs = c(id="tooltip_key", dx="2em", dy="-2em" , stroke="none", fill="#000000", 'text-anchor'="begin", class='sub-label'), newXMLTextNode(' '))
  newXMLNode('text', parent=svg, attrs = c(id="tooltip", dx="0.5em", dy="-0.33em", stroke="none", fill="#000000", 'text-anchor'='begin'), newXMLTextNode(' '))

  mask.bottom <- XML:::xmlChildren(dinosvg:::g_mask(svg, side=c(1,'2a')))$rect
  y.pos2 <- XML:::xmlAttrs(mask.bottom)[['y']]
  height <- as.numeric(XML:::xmlAttrs(mask.bottom)[['height']]) + as.numeric(y.pos2) - as.numeric(y2.pos)
  newXMLNode('rect', parent=svg, at=1, attrs = c(y=y2.pos, height=height, width="0", fill="#ffffb2", stroke='#ffff4c', rx="2", ry="2", id='highlight-fill'))
  dinosvg:::write_svg(svg, target_name)
}



JS_defineInitFunction <- function(){
  c('function init(evt){
    if ( window.svgDocument == null ) {
    svgDocument = evt.target.ownerDocument;
    svgDocument.sortLU = this.sortLU;
    svgDocument.sortLUrev = this.sortLUrev;
    var mainDocument = window.parent.document;
    mainDocument.addEventListener("landUseTrigger", sortLU, false);
    }
}')
}

JS_defineHoverFunction <- function(){
  'function cursorPoint(evt){
  pt.x = evt.clientX; pt.y = evt.clientY;
  return pt.matrixTransform(svg.getScreenCTM().inverse());
};
  function hovertext(text, evt){
  var highlight = document.getElementById("highlight-fill");
  var tooltip = document.getElementById("tooltip");
  var tooltip_bg = document.getElementById("tooltip_bg");
  var tool_key = document.getElementById("tool_key");
  var tooltip_key = document.getElementById("tooltip_key");
  tooltip.setAttribute("text-anchor","begin");
  tooltip.setAttribute("dx","0.5em");
  tooltip_key.setAttribute("text-anchor","begin");
  tooltip_key.setAttribute("dx","1.6em");
  if (evt === undefined){
  highlight.setAttribute("width","0");
  tooltip.setAttribute("class","hidden");
  tooltip_key.setAttribute("class","hidden");
  tooltip.firstChild.data = text;
  tooltip_bg.setAttribute("class","hidden");
  tooltip_bg.setAttribute("x",0);
  tooltip_bg.setAttribute("y",0);
  tool_key.setAttribute("fill","none");
  } else {
  var pt = cursorPoint(evt)
  highlight.setAttribute("width",evt.target.getAttribute("width"));
  highlight.setAttribute("x",evt.target.getAttribute("x"));
  var siteNum = evt.target.getAttribute("id").split("-")[0];
  highlight.setAttribute("height", 6 + highlightBaseHeight + Number(document.getElementById("site-" + siteNum).getComputedTextLength()));
  tooltip.setAttribute("x",pt.x);
  tooltip.setAttribute("y",pt.y);
  tooltip.firstChild.data = text;
  tooltip_bg.setAttribute("x",pt.x+2);
  tooltip_bg.setAttribute("y",pt.y-25);
  tooltip.setAttribute("class","shown");
  tooltip_key.setAttribute("x",pt.x);
  tooltip_key.setAttribute("y",pt.y);
  tooltip_key.setAttribute("class","sub-label");
  var keytext = evt.target.getAttribute("id").split("-")[1];
  tooltip_key.firstChild.data = toolkeys[keytext];
  tooltip_bg.setAttribute("class","shown");
  tool_key.setAttribute("fill", evt.target.getAttribute("fill"));
  tool_key.setAttribute("x",pt.x+5);
  tool_key.setAttribute("y",pt.y-23);
  var length = Math.max(tooltip.getComputedTextLength(), tooltip_key.getComputedTextLength()+12);
  tooltip_bg.setAttribute("width", length+6);
  if (pt.x+length+8 > xmax){
  tooltip.setAttribute("text-anchor","end");
  tooltip.setAttribute("dx","-0.5em");
  tooltip_bg.setAttribute("x",pt.x-8-length);
  tool_key.setAttribute("x",pt.x-12);
  tooltip_key.setAttribute("text-anchor","end");
  tooltip_key.setAttribute("dx","-1.6em");
  }
  }
  }'
}
