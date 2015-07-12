library(leaflet)
devtools::install_github("aoles/EBImage")
library(EBImage)
library(raster)


create_legend=function(r,rangelegend,namelegend) {
require(EBImage)
require(raster)
png("temp.png",heigth=480,weigth=480,units = "px")
plot(r, zlim=rangelegend,legend.only=T)
dev.off()
a=readImage("temp.png")
img=a[380:480, 100:350,]
writeImage(img,namelegend)
file.remove("temp.png")
}



r = raster()
r[] = 1

a=readImage("ciao.png")
r <- raster("/home/alf/Scrivania/lav_morab_LST/data/bologna_LST_JLA_mean_night.tif")
pal <- colorNumeric(brewer.pal(5,"YlOrRd"), values(r),
                    na.color = "transparent")

leaflet() %>% addTiles() %>%
  addRasterImage(r, colors = pal, opacity = 0.6) %>%
  addLegend(pal = pal, values = values(r),
            title = "LST_JLA_mean_night")
