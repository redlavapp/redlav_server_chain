#! /usr/bin/Rscript
########################################################################################


library(raster)
library(ncdf)
library(rgdal)
library(maptools)
library(rAedesSim)


setwd("/home/XXXXX/procedure")

###########################################################################################
# Meteo & Geo

list_meteo_full=readRDS("simulation/list_meteo_last.rds")
redlav_point_weather=readRDS("vectors/redlav_point_weather.rds")
population_ini=readRDS("vectors/population_ini.rds")
parameters_ini=readRDS("vectors/parameters_ini.rds")
parameter_table=readRDS("vectors/parameter_table.rds")

###########################################################################################
# Water Models


data(trappola_wmodel)

###########################################################################################
# Water Models

list_obj_meteo=list()
list_obj_meteodata=list()
list_obj_biocontainer=list()
list_obj_biometeo=list()
list_obj_biopopulation=list()
list_obj_simulazione=list()

names_points=names(list_meteo_full$tmax)
date_meteo=as.Date(as.numeric(rownames(list_meteo_full$tmax)),origin="1970-01-01")

#############################################################################################

if( is.na(Sys.timezone())) {Sys.setenv(TZ='GMT') }

#############################################################################################

    
for (i in 1:length(names_points))
   { 
  
    list_obj_meteo[[i]]=data.frame(dates=date_meteo,
                                 tmed=list_meteo_full$tmed[,i],
                                 tmax=list_meteo_full$tmax[,i],
                                 tmin=list_meteo_full$tmin[,i],
                                 rhum=list_meteo_full$urel[,i],
                                 prec=list_meteo_full$prec[,i]*1000
                                 );
    
    list_obj_meteodata[[i]]=meteodata(station_name=names_points[i],
                                      network="WRF_model",
                                      data_type="Simulation",
                                      standard="rAedesSim",
                                      data_provider="IBIMET CNR-LaMMA",	
                                      data_maintainer="",
                                      data_licence="",
                                      date_format="YMD",
                                      lat=coordinates(redlav_point_weather)[i,2],	
                                      lon=coordinates(redlav_point_weather)[i,1],
                                      elevation=redlav_point_weather$topo_w[i],
                                      timeformat="daily",
                                      sourcedata=list_obj_meteo[[i]]
                                      )

    list_obj_biocontainer[[i]]=biocontainer(nrecipients=50,
                                            watermodel=trappola_wmodel,
                                            model_type="lin",
                                            lat=coordinates(redlav_point_weather)[i,2],	
                                            lon=coordinates(redlav_point_weather)[i,1],
                                            elevation=redlav_point_weather$topo_w[i]
                                            )
    
    list_obj_biometeo[[i]]=biometeo(list_obj_meteodata[[i]],
                                    list_obj_biocontainer[[i]]
                                    )
    
    list_obj_biopopulation[[i]]=biopopulation(eggs=100,larvae=0,pupae=0,adults=0,eggs_diap=10)

}

#############################################################################################
res_list_simulation=list()

for (i in 1:length(names_points))
{ res_list_sim=list()
  for (j in 1:15) {
    
  list_obj_simulazione[[i]]=biomodel(list_obj_biometeo[[i]],
                                       list_obj_biocontainer[[i]],
                                       list_obj_biopopulation[[i]],
                                       bioparameters(alfa_l=parameters_ini@data[i,j*2+1],
                                                                      alfa_a=parameters_ini@data[i,j*2],
                                                                      l_density=40)
                                       )
  res_list_sim[[j]]=apply.weekly(list_obj_simulazione[[i]]$ts_population,mean)
  }
 res_list_simulation[[i]]=res_list_sim;
}


saveRDS(list_obj_meteo,"simulation/list_meteo_obj_last.rds")
saveRDS(res_list_simulation,"simulation/res_list_simulation_last.rds")

saveRDS(list_obj_meteo,paste0("simulation/list_meteo_obj_",Sys.Date(),".rds"))
saveRDS(res_list_simulation,paste0("simulation/res_list_simulation_",Sys.Date(),".rds"))

#############################################################################################

                
