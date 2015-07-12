#! /usr/bin/Rscript
########################################################################################


library(raster)
library(ncdf)
library(rgdal)
library(maptools)
library(RColorBrewer)
library(gdalUtils)


##########################################################################à

setwd("/home/XXXXX/procedure")

source("code/aux_images.r")

##########################################################################

redlav_point_weather=readRDS("vectors/redlav_point_weather.rds")
index_image=readRDS("indexes/index_image.rds")
data_mask=readRDS("indexes/data_mask.rds")
mask=readRDS("rasters/mask.rds")
BS=readRDS("rasters/BS.rds")


##############################################################
# load simulations 

res_list_simulation=readRDS("simulation/res_list_simulation_last.rds")

##############################################################
# last week 

n_data_tiger=nrow(res_list_simulation[[1]][[1]])

##############################################################
# Variables used in simulation
# index_day      eggs diapausant_eggs larvae pupae adult
##############################################################

###############################################################
# Vector data

adulti=data_mask
eggs=data_mask



###############################################################
# Create raster and filling data

adulti_raster=mask
eggs_raster=mask

names(adulti_raster)=c("dens_adulti")
names(eggs_raster)=c("dens_uova")
names(BS)=c("breeding_site")



###############################################################
#  Filling data from simulation object

for ( i in 1:nrow(index_image)) {
                                 adulti[index_image$ind_pixel[i]]=res_list_simulation[[index_image$ind_redpoint[i]]][[index_image$ind_tigercat[i]]][n_data_tiger,6]
                                 eggs[index_image$ind_pixel[i]]=res_list_simulation[[index_image$ind_redpoint[i]]][[index_image$ind_tigercat[i]]][n_data_tiger,2]

                               }


values(adulti_raster)=adulti
values(eggs_raster)=eggs

###############################################################
#  Calculate arela density of female adults

adulti_raster_i=BS*adulti_raster*(1/2.5)
eggs_raster_i=eggs_raster

###############################################################
# Focal smoothing of  data

adulti_raster<- focal(adulti_raster_i, w=matrix(1/9,nrow=3,ncol=3),na.rm=T)
eggs_raster<- focal(eggs_raster_i, w=matrix(1/9,nrow=3,ncol=3),na.rm=T)

###############################################################
# Create tileserver output


writeRaster(adulti_raster,"/home/XXXXX/data/output/redlav/data/adulti_raster_full.tif",overwrite=T)
writeRaster(eggs_raster,"/home/XXXXX/data/output/redlav/data/eggs_raster_full.tif",overwrite=T)

################################################################
# Crop to reliable extent

e <- extent(7.64, 11.92, 42.13, 44.82)


adulti_raster <- crop(adulti_raster, e) 
eggs_raster <- crop(eggs_raster, e) 



create_trasparent_legend(adulti_raster,"/home/XXXXX/data/output/redlav/images/legend_adu.png",pal=redlav_cols)
create_trasparent_legend(eggs_raster,"/home/XXXXX/data/output/redlav/images/legend_eggs.png",pal=redlav_cols)


writePaletteVRT("eggs_raster.vrt", eggs_raster,redlav_cols)
writePaletteVRT("adulti_raster.vrt", adulti_raster,redlav_cols)

writeRaster(adulti_raster,"/home/XXXXX/data/output/redlav/data/adulti_raster.tif",overwrite=T,datatype="INT1U")
writeRaster(eggs_raster,"/home/XXXXX/data/output/redlav/data/eggs_raster.tif",overwrite=T,datatype="INT1U")

system("python code/addPalette.py eggs_raster.vrt /home/XXXXX/data/output/redlav/data/eggs_raster.tif")
system("python code/addPalette.py adulti_raster.vrt /home/XXXXX/data/output/redlav/data/adulti_raster.tif")

system("gdal_translate -of vrt -expand rgba /home/XXXXX/data/output/redlav/data/eggs_raster.tif eggstemp.vrt")
system("gdal_translate -of vrt -expand rgba /home/XXXXX/data/output/redlav/data/adulti_raster.tif adutemp.vrt")


system("rm -rf /home/XXXXX/data/output/redlav/images/eggs_raster")
system("rm -rf /home/XXXXX/data/output/redlav/images/adu_raster")
 
system("python /code/gdal2tiles-multiprocess.py -s EPSG:4326 -p mercator --srcnodata=0,0,0  -z \'9-16\'  adutemp.vrt /home/salute/data/output/redlav/images/adu_raster")
system("python /code/gdal2tiles-multiprocess.py -s EPSG:4326 -p mercator --srcnodata=0,0,0  -z \'9-16\'  adutemp.vrt /home/salute/data/output/redlav/images/adu_raster")

# system("python /usr/bin/gdal2tiles.py -s EPSG:4326 -p mercator --srcnodata=0,0,0  -z \'9-16\'  eggstemp.vrt /home/salute/data/output/redlav/images/eggs_raster")
# system("python /usr/bin/gdal2tiles.py -s EPSG:4326 -p mercator --srcnodata=0,0,0  -z \'9-16\'  adutemp.vrt   /home/salute/data/output/redlav/images/adu_raster")

file.remove(Sys.glob("*.vrt"))

####################################################################

# system("python /usr/bin/gdal2tiles.py -h")

###########################################################################################################################
# References 

# http://stackoverflow.com/questions/6174439/include-small-table-in-legend-in-r-graphics




