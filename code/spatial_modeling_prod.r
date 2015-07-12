library(raster)
library(ncdf)
library(rgdal)
library(akima)
library(maptools)
library(randomForest)
library(leaflet)
library(miscTools)
library(ggplot2)

setwd("/home/alf/Scrivania/lav_proc_redlav")

#########################################################################################
# Load vectorial layers

point_prod=readShapeSpatial("point_prod.shp")
geo_redlav=readRDS("geo_redlav.rds")
redlav_weather_spdf=readRDS("vector_oper_r/redlav_weather_spdf.rds")
redlav_weather_center_spdf=readRDS("vector_oper_r/redlav_weather_center_spdf.rds")


#########################################################################################
# Building stack predictors

setwd("/home/alf/Scrivania/lav_proc_redlav/redlav_procedures/raster_oper/")

files_pred=c("t_A_M_T.tif",
             "t_area_gen_g.tif", 
             "t_area_gen_u.tif",
             "t_cais_u.tif", 
             "t_cas_u.tif",
             "t_dc.tif",
             "t_fdi_gen_g.tif",
             "t_Isothermality.tif",
             "t_LST_day_est.tif",
             "t_LST_night_est.tif",
             "t_MaxT_Warmest.tif",
             "t_M_Diurnal_Range.tif",
             "t_Min_T_Coldest.tif",
             "t_M_T_Warmest_Q.tif",
             "t_M_T_Wettest_Q.tif",
             "t_nei_s_u.tif",
             "t_npg_g.tif",
             "t_npg_u.tif",
             "t_nps_g.tif",
             "t_nps_u.tif",
             "t_par_gen_g.tif",
             "t_par_gen_u.tif",
             "t_P_Driest.tif",
             "t_p_gen_g.tif",
             "t_pop_min.tif",
             "t_P_Wettest.tif",
             "t_rad_A.tif",
             "t_rd.tif",
             "t_A_P.tif",
             "t_cags_g.tif",
             "t_caig_u.tif",
             "t_dens_pop.tif",
             "t_nei_gtu.tif",
             "t_dem.tif")
       
raster_oper=sapply(files_pred,raster)

###############################################################################################
# preparing stacks for prediction and renaming to eliminate tif file's extension

redlav_stack=stack(raster_oper)
names(redlav_stack)<-gsub(".tif$","",names(redlav_stack))
saveRDS(redlav_stack,"redlav_stack.rds")

#####################################################################################à
# Prepare and extract data for training dataset from Selmi's maps

data=extract(stack(raster_oper),point_prod)
data=cbind(point_prod@data,data)


setwd("/home/alf/Scrivania/lav_proc_redlav")

names(data)<-gsub(".tif$","",names(data))

saveRDS(data,"matrix_prod_selmi.rds")

matrix_prod_selmi=readRDS("matrix_prod_selmi.rds")


################################################################################################
# Function to categorize productivity for larvs and adults

cat_prod_l=function(x) {
                        r=ifelse(x<=0.6,5,ifelse(x<=0.8,4,ifelse(x<=1,3,ifelse(x<=1.2,2,ifelse(x>1.2,1,NA)))))
                         return(r)
                      }

cat_prod_a=function(x) {
  r=ifelse(x<=0.001,3,ifelse(x<=0.002,2,ifelse(x>0.002,1,NA)))
  return(r)
}

cat_prod_l_a=function(x) {
  r=ifelse(x>=3,3,ifelse(x==2,2,x))
  return(r)
}
################################################################################################à
# Create original data training matrix, binding alpha a data and renaming variables

data=extract(redlav_pred,geo_redlav)

mat_redlav_a=cbind(geo_redlav@data["alpha_a"],data)
mat_redlav_l=cbind(geo_redlav@data["alpha_l"],data)

names(mat_redlav_a)<-gsub(".tif$","",names(mat_redlav_a))
names(mat_redlav_l)<-gsub(".tif$","",names(mat_redlav_l))

saveRDS(mat_redlav_a,"redlav_procedures/population/mat_redlav_a.rds")
saveRDS(mat_redlav_a,"redlav_procedures/population/mat_redlav_l.rds")


################################################################################################à
# reloading dataframes and categorize.

mat_redlav_a=readRDS("redlav_procedures/population/mat_redlav_a.rds")
mat_redlav_l=readRDS("redlav_procedures/population/mat_redlav_l.rds")

mat_redlav_l$prod_l=sapply(mat_redlav_l$alpha_l,FUN=cat_prod_l)
mat_redlav_a$prod_a=sapply(mat_redlav_a$alpha_a,FUN=cat_prod_a)


##################################################################################################################################################################
# Used parameters from raster's stack


# [1] "alpha_a"           "t_A_M_T"           "t_area_gen_g"      "t_area_gen_u"      "t_cais_u"         
# [6] "t_cas_u"           "t_dc"              "t_fdi_gen_g"       "t_Isothermality"   "t_LST_day_est"    
# [11] "t_LST_night_est"   "t_MaxT_Warmest"    "t_M_Diurnal_Range" "t_Min_T_Coldest"   "t_M_T_Warmest_Q"  
# [16] "t_M_T_Wettest_Q"   "t_nei_s_u"         "t_npg_g"           "t_npg_u"           "t_nps_g"          
# [21] "t_nps_u"           "t_par_gen_g"       "t_par_gen_u"       "t_P_Driest"        "t_p_gen_g"        
# [26] "t_pop_min"         "t_P_Wettest"       "t_rad_A"           "t_rd"              "t_A_P"            
# [31] "t_cags_g"          "t_caig_u"          "t_dens_pop"        "t_nei_gtu"         "t_dem" 

##################################################################################################################################################################
# Modeling productivity

##########################
# Larvs by random forest modeling


rf_model_alpha_l <- randomForest(factor(prod) ~ ., data= matrix_prod_selmi, ntree=200, importance=TRUE, na.action="na.exclude")
varImpPlot(rf_model_alpha_l)
saveRDS(rf_model_alpha_l,"rf_model_alpha_l.rds")
alpha_l<- predict(redlav_stack, rf_model_alpha_a_f, type= "response", na.action="na.pass")



##########################
# Adults by regression 

full_model_a=lm(alpha_a ~.  -1, data=mat_redlav_a)
summary(full_model_a)
sel_model_a=MASS::stepAIC(full_model_a)
summary(sel_model_a)
saveRDS(sel_model_a,"model_a.rds")

r2 <- rSquared(as.numeric(mat_redlav_a$alpha_a), as.numeric(mat_redlav_a$alpha_a - as.numeric(predict(sel_model_a))))
p <- ggplot(aes(x=actual, y=pred),data=data.frame(actual=mat_redlav_a$alpha_a, pred=as.numeric(predict(sel_model_a))))
p + geom_point() + geom_abline(color="red") +ggtitle(paste("Selected Linear Regression in R r^2=", r2, sep=""))


alpha_a=predict(redlav_stack,sel_model_a)

############################################################################################à
# correct local zoning

pixelmapindices=1:length(values(alpha_a_cat))
index_pixel=alpha_a_cat
values(index_pixel)=pixelmapindices
index_pix=extract(index_pixel,point_prod)


table(point_prod$prod, values(alpha_l)[index_pix])

############################
# cross table

#     1   2   3   4   5
# 1  10   3   0   0   0
# 2   8 330  16   8   1
# 3   4  45 134  13  17
# 4   0  20  23 104  21
# 5   0   2  13   0  52

############################

values(alpha_l)[index_pix]=point_prod$prod

alpha_a_cat <- reclassify(alpha_a, c(-Inf,0.002,3,0.0021,0.01,2,0.0012,Inf,1))

values(alpha_a_cat)[index_pix]=cat_prod_l_a(point_prod$prod)

BS <- reclassify(alpha_a, c(-Inf,0.002,100,0.0021,0.01,75,0.0012,Inf,50))


#################################################################################
# Write outputs

writeRaster(BS, filename="BS.tif",format="GTiff",overwrite=TRUE)
writeRaster(alpha_a_cat, filename="alpha_a.tif",format="GTiff",overwrite=TRUE)
writeRaster(alpha_l, filename="alpha_l.tif",format="GTiff",overwrite=TRUE)

saveRDS(alpha_l,"alpha_l.rds")
saveRDS(alpha_a_cat,"alpha_a.rds")
saveRDS(BS,"BS.rds")
#################################################################################







