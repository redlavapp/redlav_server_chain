###########################################################################################################################
# To install on linux EBImage R packages
# require(devtools)
# devtools::install_github("aoles/EBImage")

###########################################################################################################################


library(EBImage)
library(raster)


###########################################################################################################################
# create palette


redlav_pal=c("#FFFF00","#FFA500","#FF0000","#FF00FF")
redlav_cols <- colorRampPalette( c(redlav_pal))(255)

###########################################################################################################################
# function to create legend

create_trasparent_legend=function(r,namelegend,pal=brewer.pal(5,"YlOrRd"),i_h=480,w_h=480,trasparency=TRUE) {
require(EBImage)
require(raster)
require(RColorBrewer)  
rangelegend=c(min(values(r),na.rm=T),max(values(r),na.rm=T))
png("temp.png",width=i_h,height=w_h,units = "px")
suppressWarnings(plot(r, zlim=rangelegend,col=pal,legend.only=T))
dev.off()
a=readImage("temp.png")
img=a[380:480, 100:350,]
writeImage(img,"temp2.png")
Sys.sleep(1)
if (trasparency==FALSE ) { file.copy("temp2.png",namelegend)}

else
                         {
                           system(paste0("convert -transparent white temp2.png ",namelegend))
                         }

file.remove(c("temp.png","temp2.png"))
}


###########################################################################################################################
# adding alpha channel

add.alpha <- function(col, alpha=1){
  if(missing(col))
    stop("Please provide a vector of colours.")
  apply(sapply(col, col2rgb)/255, 2,
        function(x)
          rgb(x[1], x[2], x[3], alpha=alpha))
}

###########################################################################################################################
# make palette

makePalette <- function(colourvector) {
  cmat = cbind(t(col2rgb(colourvector)), 255)
  res = apply(cmat, 1, function(x) {
    sprintf("<Entry c1=\"%s\" c2=\"%s\" c3=\"%s\" c4=\"%s\"/>", x[1], x[2], 
            x[3], x[4])
  })
  res = paste(res, collapse = "\n")
  res
}

###########################################################################################################################
# make vrt palette files


makePaletteVRT <- function(raster, colourvector) {
  s = sprintf("<VRTDataset rasterXSize=\"%s\" rasterYSize=\"%s\">\n<VRTRasterBand dataType=\"Byte\" band=\"1\">\n<ColorInterp>Palette</ColorInterp>\n<ColorTable>\n", 
              ncol(raster), nrow(raster))
  p = makePalette(colourvector)
  s = paste0(s, p, "\n</ColorTable>\n</VRTRasterBand>\n</VRTDataset>\n")
  s
}

writePaletteVRT <- function(out, raster, colourvector) {
  s = makePaletteVRT(raster, colourvector)
  cat(s, file = out)
}

###########################################################################################################################
