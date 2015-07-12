#! /usr/bin/Rscript
########################################################################################


###############################################################################
# Caricamento delle librerie

library(raster)
library(ncdf)
library(rgdal)
library(maptools)

###############################################################################
# Caricamento dei vettoriali e dei layer di utilita'

setwd("/home/redlav/procedure/")


redlav_point_weather=readRDS("vectors/redlav_point_weather.rds")


npoints=667


###############################################################################
# definizione del nome e path dello stack netcdf delle previsioni 

file_meteo=paste0("/home/salute/data/output/spool/redlav_forecast_full.nc");

##############################################################################

tmax_redlav_full=brick(file_meteo,varname=c("tmax"))

dates=as.Date(as.POSIXct(tmax_redlav_full@z$hours*3600, origin="1992-01-01"))

names_w=paste0("W_",c(1:npoints))

tmin_redlav_full=brick(file_meteo,varname=c("tmin"))
tmed_redlav_full=brick(file_meteo,varname=c("tmed"))
urel_redlav_full=brick(file_meteo,varname=c("urel"))
prec_redlav_full=brick(file_meteo,varname=c("prec"))


tmax=t(extract(tmin_redlav_full,redlav_point_weather))
names(tmax)=names_w
rownames(tmax)=dates

tmin=t(extract(tmin_redlav_full,redlav_point_weather))
names(tmin)=names_w
rownames(tmin)=dates

tmed=t(extract(tmed_redlav_full,redlav_point_weather))
names(tmed)=names_w
rownames(tmed)=dates

urel=t(extract(urel_redlav_full,redlav_point_weather))
names(urel)=names_w
rownames(urel)=dates


prec=t(extract(prec_redlav_full,redlav_point_weather))
names(prec)=names_w
rownames(prec)=dates

##############################################################################

list_meteo_full=list(tmax=as.data.frame(tmax),
                     tmin=as.data.frame(tmin),
                     tmed=as.data.frame(tmed),
                     urel=as.data.frame(urel),
                     prec=as.data.frame(prec))
                     
saveRDS(list_meteo_full,"/home/redlav/procedure/simulation/list_meteo_last.rds")
saveRDS(list_meteo_full,paste0("/home/redlav/procedure/simulation/list_meteo_",Sys.Date(),".rds"))

##############################################################################





