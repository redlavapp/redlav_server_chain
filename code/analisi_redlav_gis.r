############################################################

library(raster)
library(rts)
library(OpenStreetMap)
library(rasterVis)
library(ggplot2)
library(rgdal)
library(ggmap)
library(grid)
library(latticeExtra)
library(maptools)
library(plyr)
library(greenbrown)
library(plotKML)
library(RColorBrewer)

############################################################
# Setup directory

setwd("/home/alf/Scrivania/lav_proc_redlav/raster")
setwd("/home/alf/Scrivania/lav_proc_redlav/")
############################################################
# Load supplementary code

source("auxillary_functions.r")

############################################################

produttivita_zanza=readShapePoints("../vector/produttivita_zanza.shp")

selmi_cat=data.frame(category=produttivita_zanza$cat,
                     lon=produttivita_zanza$X,
                     lat=produttivita_zanza$Y,
                     area=produttivita_zanza$Area
                     )
prod_zanza=produttivita_zanza
prod_zanza@data=selmi_cat
writePointsShape(prod_zanza,"prod_zanza.shp")

##############################################################
georedlav=readRDS("geo_redlav.rds")
georedlav@data$lon=as.data.frame(coordinates(georedlav))$lon
georedlav@data$lat=as.data.frame(coordinates(georedlav))$lat
redlav_data=merge(prod_zanza@data,georedlav@data)

stat_cat_a=tapply(redlav_data$alpha_a, redlav_data$category, mean)
stat_cat_l=tapply(redlav_data$alpha_l, redlav_data$category, mean)
stat_cat_sd=tapply(redlav_data$alpha_l, redlav_data$category, mean)
summary(lm(m_egg ~ alpha_l+alpha_a+as.factor(category),data=redlav_data))
summary(lm(m_egg ~ as.factor(category)-1,data=redlav_data))

write.csv(georedlav@data,"georedlav.csv")
write.csv(redlav_data,"redlav_data.csv")

##############################################################
saveRDS(redlav_data,"redlav_data.rds")

