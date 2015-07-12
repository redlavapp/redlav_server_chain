
alpha_a_lin=readRDS("alpha_a.rds")
alpha_b_lin=readRDS("alpha_l.rds")
geo_redlav=readRDS("vector_r/geo_redlav.rds")

stat_cat_a=tapply(geo_redlav@data$alpha_a, geo_redlav@data$alpha_a_q, mean)
stat_cat_l=tapply(geo_redlav$alpha_l, ha_a, as.factor(geo_redlav@data$alpha_l_q), mean)


alpha_a_cat <- reclassify(alpha_a_lin, c(-Inf,0.05,3,0.051,0.15,2,0.16,Inf,1))
alpha_l_cat <- reclassify(alpha_l_lin, c(-Inf,0.3,5,
                                         0.31,0.61,4,
                                         0.62,1.0,3,
                                         1.1,1.6,2,
                                         1.7,Inf,1))


writeRaster(alpha_a_cat, filename="redlav_alpha_a_classi.tif", format="GTiff",overwrite=TRUE)
writeRaster(alpha_l_cat, filename="redlav_alpha_l_classi.tif", format="GTiff",overwrite=TRUE)

saveRDS(alpha_a_cat,"alpha_a_cat.rds")
saveRDS(alpha_l_cat,"alpha_l_cat.rds")

index_w=raster("t_index_weather.tif")
redlavs_indices=data.frame(index=values(index_w),a_class=alpha_a_cat@data@values,l_class=alpha_l_cat@data@values)

saveRDS(redlavs_indices,"redlavs_indices.rds")
