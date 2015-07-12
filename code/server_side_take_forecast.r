#! /usr/bin/Rscript
########################################################################################

library(raster)
library(rts)
library(ncdf)
library(RColorBrewer)

########################################################################################

setwd("")

########################################################################################

dayforecast=Sys.glob("day_d01_*.nc")
date_forecast=gsub("day_d01_","",dayforecast)
date_forecast=gsub(".nc","",date_forecast)
date_forecast_actual=date_forecast[63:lenday]

lenday=length(dayforecast)

for ( i in 63:lenday)
{
  
  system(paste0("cdo -selvar,ta2m,urel -daymean -seltimestep,1  ",dayforecast[i]," outx_mean_",dayforecast[i]))
  system(paste0("cdo -chname,ta2m,tmed"," outx_mean_",dayforecast[i]," out_mean_",dayforecast[i]))
  
  system(paste0("cdo -selvar,ta2m  -daymax -seltimestep,1 ",dayforecast[i]," outx_max_",dayforecast[i]))
  system(paste0("cdo -chname,ta2m,tmax"," outx_max_",dayforecast[i]," out_max_",dayforecast[i]))
  
  system(paste0("cdo -selvar,ta2m -daymin -seltimestep,1 ",dayforecast[i]," outx_min_",dayforecast[i]))
  system(paste0("cdo -chname,ta2m,tmin"," outx_min_",dayforecast[i]," out_min_",dayforecast[i]))
  
  system(paste0("cdo -selvar,prec -daysum -seltimestep,1 ",dayforecast[i]," out_sum_",dayforecast[i]))
  
  file.remove(Sys.glob("outx_*.nc"))
  system(paste0("cdo merge out_*.nc ",gsub("day_d01_","day_redlav_",dayforecast[i])))
  
  file.remove(Sys.glob("out_*.nc"))
}

system(paste0("cdo cat day_redlav_*.nc redlav_forecast_full.nc"))
file.remove(Sys.glob("day_redlav_*.nc"))


