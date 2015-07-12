library(raster)
library(ncdf)
library(rgdal)
library(maptools)
library(rAedesSim)

###########################################################################################
# Setto la directory di lavoro

setwd("")

###########################################################################################
# Prendo il rissunto del meteo file giornalieri grazie  take_forecast.r

list_meteo_full=readRDS("list_meteo_full.rds")

###########################################################################################


redlav_point_weather=readRDS("../vectors/redlav_point_weather.rds")
population_ini=readRDS("../vectors/population_ini.rds")
parameters_ini=readRDS("../vectors/parameters_ini.rds")
parameter_table=readRDS("../population/parameter_table.rds")

###########################################################################################
# Carico i water models dal packages rAedesSim


data(trappola_wmodel)
data(tombino_wmodel)

###########################################################################################
# Creo gli oggetti per il loop di simulazione

list_obj_meteo=list()
list_obj_meteodata=list()
list_obj_biocontainer=list()
list_obj_biometeo=list()
list_obj_biopopulation=list()
list_obj_simulazione=list()

names_points=names(list_meteo_full$tmax)

#######################################################################################
# Cerco le date dal time del modello WRF

date_meteo=as.Date(as.numeric(rownames(list_meteo_full$tmax)),origin="1970-01-01")

#############################################################################################
# Setto la timezone su UTC - 0 

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

saveRDS(list_obj_meteo,"list_meteo_obj.rds")
saveRDS(res_list_simulation,"res_list_simulation.rds")

#############################################################################################

                
