
library(raster)
library(ncdf)
library(rgdal)
library(maptools)

##########################################################################
# Indicare la directory di lavoro.


setwd("/home/alf/Scrivania/lav_proc_redlav/redlav_procedures/")

##########################################################################
# Load  3 raster merging matrixwise  the index of  WRF pixel and larvs and adult productivity's category

alpha_a=readRDS("rasters/alpha_a_cat.rds")
alpha_l=readRDS("rasters/alpha_l_cat.rds")


index_weather=raster("raster_oper/t_index_weather.tif")
redlav_indices=data.frame(index=values(index_weather),a_class=values(alpha_a),l_class=values(alpha_l))
saveRDS(redlav_indices,"indexes/redlav_indices.rds")



##########################################################################
# Reload for check

redlav_indices=readRDS("indexes/redlav_indices.rds")

##########################################################################
# Raster points that will be used for aedes simulations  ( N = 667) 


redlav_poly=readRDS("vectors/redlav_point_weather_poly.rds")
mask_r=readRDS("rasters/mask.rds")

##########################################################################
# Reload for check

index_list_raster=readRDS("rasters/index_list_raster.rds")

##########################################################################
# Table of category. To be update.

parameter_table=readRDS("population/parameter_table.rds")


#   a_class l_class a_cat l_cat p_class
# 1    0.005     1.6     1     1       1
# 2    0.003     1.6     2     1       2
# 3    0.001     1.6     3     1       3
# 4    0.005     1.2     1     2       4
# 5    0.003     1.2     2     2       5
# 6    0.001     1.2     3     2       6
# 7    0.005     1.0     1     3       7
# 8    0.003     1.0     2     3       8
# 9    0.001     1.0     3     3       9
# 10   0.005     0.8     1     4      10
# 11   0.003     0.8     2     4      11
# 12   0.001     0.8     3     4      12
# 13   0.005     0.6     1     5      13
# 14   0.003     0.6     2     5      14
# 15   0.001     0.6     3     5      15

##########################################################################
# Load vector layer that defines UMZ areas  ( N = 667) defined by UMZ2006. 


redlav_point_weather=readRDS("vectors/redlav_point_weather.rds")





########################################################################################################
# From  image raster matrix  define index image for all 15 joint productivit classes   ( by using R  intersect)

list_r_cat=list()

list_r_cat[[1]]=intersect(which(redlav_indices$l_class==1),which(redlav_indices$a_class==1))
list_r_cat[[2]]=intersect(which(redlav_indices$l_class==1),which(redlav_indices$a_class==2))
list_r_cat[[3]]=intersect(which(redlav_indices$l_class==1),which(redlav_indices$a_class==3))
list_r_cat[[4]]=intersect(which(redlav_indices$l_class==2),which(redlav_indices$a_class==1))
list_r_cat[[5]]=intersect(which(redlav_indices$l_class==2),which(redlav_indices$a_class==2))
list_r_cat[[6]]=intersect(which(redlav_indices$l_class==2),which(redlav_indices$a_class==3))
list_r_cat[[7]]=intersect(which(redlav_indices$l_class==3),which(redlav_indices$a_class==1))
list_r_cat[[8]]=intersect(which(redlav_indices$l_class==3),which(redlav_indices$a_class==2))
list_r_cat[[9]]=intersect(which(redlav_indices$l_class==3),which(redlav_indices$a_class==3))
list_r_cat[[10]]=intersect(which(redlav_indices$l_class==4),which(redlav_indices$a_class==1))
list_r_cat[[11]]=intersect(which(redlav_indices$l_class==4),which(redlav_indices$a_class==2))
list_r_cat[[12]]=intersect(which(redlav_indices$l_class==4),which(redlav_indices$a_class==3))
list_r_cat[[13]]=intersect(which(redlav_indices$l_class==5),which(redlav_indices$a_class==1))
list_r_cat[[14]]=intersect(which(redlav_indices$l_class==5),which(redlav_indices$a_class==2))
list_r_cat[[15]]=intersect(which(redlav_indices$l_class==5),which(redlav_indices$a_class==3))
               
saveRDS(list_r_cat,"simulation/list_r_cat.rds")

########################################################################################################
# Dalla matrice dell'immagine definisco una lista dove grazie agli indici riga 
# e ci informa quale è il indice pixel wrf.

              
list_w_cat=list()

              
list_w_cat[[1]]=redlav_indices$index[list_r_cat[[1]]]
list_w_cat[[2]]=redlav_indices$index[list_r_cat[[2]]]
list_w_cat[[3]]=redlav_indices$index[list_r_cat[[3]]]
list_w_cat[[4]]=redlav_indices$index[list_r_cat[[4]]]
list_w_cat[[5]]=redlav_indices$index[list_r_cat[[5]]]
list_w_cat[[6]]=redlav_indices$index[list_r_cat[[6]]]
list_w_cat[[7]]=redlav_indices$index[list_r_cat[[7]]]
list_w_cat[[8]]=redlav_indices$index[list_r_cat[[8]]]
list_w_cat[[9]]=redlav_indices$index[list_r_cat[[9]]]
list_w_cat[[10]]=redlav_indices$index[list_r_cat[[10]]]
list_w_cat[[11]]=redlav_indices$index[list_r_cat[[11]]]
list_w_cat[[12]]=redlav_indices$index[list_r_cat[[12]]]
list_w_cat[[13]]=redlav_indices$index[list_r_cat[[13]]]
list_w_cat[[14]]=redlav_indices$index[list_r_cat[[14]]]
list_w_cat[[15]]=redlav_indices$index[list_r_cat[[15]]]

saveRDS(list_w_cat,"simulation/list_w_cat.rds")

########################################################################################################
# Dalla matrice dell'immagine definisco una lista dove è indicato la classe di produttività ( 1-15) con la stessa
# estenzione dei pixel wrf e pixel immagine.
# Come si può notare sono create solo alcune delle 15 classi di popolazione perchè alcune risultavano nulle 

list_z_w=list()

list_z_w[[1]]=rep(1,length(list_w_cat[[1]]))
list_z_w[[2]]=rep(2,length(list_w_cat[[2]]))
list_z_w[[3]]=rep(3,length(list_w_cat[[3]]))
list_z_w[[4]]=rep(4,length(list_w_cat[[4]]))
list_z_w[[5]]=rep(5,length(list_w_cat[[5]]))
list_z_w[[6]]=rep(6,length(list_w_cat[[6]]))
list_z_w[[7]]=rep(7,length(list_w_cat[[7]]))
list_z_w[[8]]=rep(8,length(list_w_cat[[8]]))
list_z_w[[9]]=rep(9,length(list_w_cat[[9]]))
list_z_w[[10]]=rep(10,length(list_w_cat[[10]]))
list_z_w[[11]]=rep(11,length(list_w_cat[[11]]))
list_z_w[[12]]=rep(12,length(list_w_cat[[12]]))
list_z_w[[13]]=rep(13,length(list_w_cat[[13]]))
list_z_w[[14]]=rep(14,length(list_w_cat[[14]]))
list_z_w[[15]]=rep(15,length(list_w_cat[[15]]))


saveRDS(list_z_w,"simulation/list_z_w.rds")


########################################################################################################
# creo un vettore per il riempimento di un raster pari al numero degli elementi del raster.

data_mask=rep(NA,nrow(redlav_indices))

saveRDS(data_mask,"simulation/data_mask.rds")

#########################################################################################################

list_i_w=list()

list_i_w[[1]]=sapply(list_w_cat[[1]],function(x) which(x==redlav_point_weather$index))
list_i_w[[2]]=sapply(list_w_cat[[2]],function(x) which(x==redlav_point_weather$index))
list_i_w[[3]]=sapply(list_w_cat[[3]],function(x) which(x==redlav_point_weather$index))
list_i_w[[4]]=sapply(list_w_cat[[4]],function(x) which(x==redlav_point_weather$index))
list_i_w[[5]]=sapply(list_w_cat[[5]],function(x) which(x==redlav_point_weather$index))
list_i_w[[6]]=sapply(list_w_cat[[6]],function(x) which(x==redlav_point_weather$index))
list_i_w[[7]]=sapply(list_w_cat[[7]],function(x) which(x==redlav_point_weather$index))
list_i_w[[8]]=sapply(list_w_cat[[8]],function(x) which(x==redlav_point_weather$index))
list_i_w[[9]]=sapply(list_w_cat[[9]],function(x) which(x==redlav_point_weather$index))
list_i_w[[10]]=sapply(list_w_cat[[10]],function(x) which(x==redlav_point_weather$index))
list_i_w[[11]]=sapply(list_w_cat[[11]],function(x) which(x==redlav_point_weather$index))
list_i_w[[12]]=sapply(list_w_cat[[12]],function(x) which(x==redlav_point_weather$index))
list_i_w[[13]]=sapply(list_w_cat[[13]],function(x) which(x==redlav_point_weather$index))
list_i_w[[14]]=sapply(list_w_cat[[14]],function(x) which(x==redlav_point_weather$index))
list_i_w[[15]]=sapply(list_w_cat[[15]],function(x) which(x==redlav_point_weather$index))


saveRDS(list_i_w,"simulation/list_i_w.rds")
                                                      
########################################################################################################
# Salvo tutti gli indici immagini utili e li metto in un data frame per allinearli.

setwd("/home/alf/Scrivania/lav_proc_redlav/redlav_procedures/")

list_r_cat=readRDS("simulation/list_r_cat.rds") # indica gli indici  pixel immagine corrispondenti a prod_l_cat (1-5) e prod_a_cat ( 1-3) =15
list_w_cat=readRDS("simulation/list_w_cat.rds") # mi dice per i precedenti a quale pixel WRF corrisondono.
list_z_w=readRDS("simulation/list_z_w.rds") # indica quale la distribuzione delle classi combinate di produttività per i vari pixel wrf ( come sono distribuite le 15 classi) 
list_i_w=readRDS("simulation/list_i_w.rds") # associa l'indice immagine ad una classe di produttività e al pixel wrf.

# In sintesi vengono le 15 classi per ogni pixel WRF che poi andaranno ricollocati nell'immagine finale solo in quelle ricadenti in aree urbane che prende da index_list_raster.

index_image=data.frame(ind_pixel=as.numeric(unlist(list_r_cat)),  # indice immagine
                       ind_tigercat=as.numeric(unlist(list_z_w)), # categoria
                       ind_redpoint=as.numeric(unlist(list_i_w)), # è l'indice del pixel wrf delle aree urbanizzate definite da redlav_point_weather 
                       ind_wrf_pixel=as.numeric(unlist(list_w_cat))) # pixel wrf della categoria

saveRDS(index_image,"indexes/index_image.rds")
########################################################################################################
