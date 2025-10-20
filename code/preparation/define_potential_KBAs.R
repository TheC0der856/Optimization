library(sf)
library(dplyr)
library(tmap)
library(lwgeom) # für st_split

#load range
range <- st_read("data/range/range.shp")
ranges <- st_cast(range, "POLYGON")
# add ids
ranges <- ranges %>%
  mutate(id = c("wHierro", 
                "eHierro", 
                "Gomera", 
                "Teno",
                "Lagunetas",
                "wAnaga",
                "eAnaga"))
# calculate area size
ranges <- ranges %>%
  mutate(area_km2 = as.numeric(st_area(geometry)) / 10^6)
print(ranges %>% select(area_km2))
# view areas
# tmap_mode("view")
# tm_shape(ranges) +
#   tm_polygons("area_km2", palette = "viridis", title = "Fläche (km²)")


# load protected areas
protected_area <- st_read("data/potential_KBAs/protected_areas/eennpp/eennpp.shp")
protected_areas <- st_cast(protected_area, "POLYGON")
# calculate area size 
protected_areas <- protected_areas %>%
  mutate(area_km2 = as.numeric(st_area(geometry)) / 10^6)
print(protected_areas %>% select(area_km2))
# view protected areas
# tmap_mode("view")
# tm_shape(protected_areas) +
#   tm_polygons("area_km2", palette = "viridis", title = "Fläche (km²)")

# load KBAs
KBA <- st_read("data/potential_KBAs/KBA_March2025/KBAsGlobal_2025_March_01/KBAsGlobal_2025_March_01_POL.shp")
KBAs <- st_cast(KBA, "POLYGON")
# equal CRS/ projection
KBAs <- st_transform(KBAs, st_crs(protected_areas))
# only interested in Canary Islands
KBAs_small <- st_crop(KBAs, st_bbox(protected_areas))
# # view KBAs
# tmap_mode("view")  
# tm_shape(KBAs_small) +
#   tm_polygons(col = "yellow",
#               fill_alpha = 0.4,
#               border.col = "orange",
#               fill.legend = tm_legend(title = "KBAs (cropped)"))



# Overlaps
overlap <- st_intersection(protected_areas, ranges)
# # view overlaps
# tmap_mode("view")
# tm_shape(protected_areas) + 
#   tm_polygons(col = "green", alpha = 0.4, border.col = "darkgreen", title = "Protected Areas") +
#   tm_shape(ranges) +
#   tm_polygons(col = "blue", alpha = 0.4, border.col = "darkblue", title = "Ranges") +
#   tm_shape(overlap) +
#   tm_polygons(col = "red", alpha = 0.6, border.col = "black", title = "Overlap")

# Collection points
# load collection point data
occ_data <-  read.csv("data/collection_data.csv", sep = ",")
# Extract and clean coordinates 
# only for rows which are not potential collection points and have exact coordinates
occ.std <- occ_data[!is.na(occ_data$Specimen_ID) & occ_data$Specimen_ID != "", c("WGS84_X", "WGS84_Y")]
# Remove duplicate coordinate pairs
occ.std <- occ.std[!duplicated(occ.std),]  
# Replace commas with dots and convert to numeric values
occ.std$WGS84_X <- as.numeric(sub(",", ".", occ.std$WGS84_X))
occ.std$WGS84_Y <- as.numeric(sub(",", ".", occ.std$WGS84_Y))
# Remove rows with missing values (NA)
occ.std <- occ.std[complete.cases(occ.std), ]
# adjust collection points to the same dimensions like the protected areas and the range
# transform to sf object
occ_points <- st_as_sf(occ.std, coords = c("WGS84_X", "WGS84_Y"), crs = 4326)
# equal CRS/ projection
occ_points <- st_transform(occ_points, st_crs(protected_areas))

# Show map including the collection points: 
# tmap_mode("view")
# tm_shape(protected_areas) + 
#   tm_polygons(col = "green", alpha = 0.4, border.col = "darkgreen", title = "Protected Areas") +
#   tm_shape(ranges) +
#   tm_polygons(col = "blue", alpha = 0.4, border.col = "darkblue", title = "Ranges") +
#   tm_shape(overlap) +
#   tm_polygons(col = "red", alpha = 0.6, border.col = "black", title = "Overlap") +
#   tm_shape(occ_points) +
#   tm_dots(col = "black", size = 0.6, title = "Occurrence Points") 

# Show map including KBAs
tmap_mode("view")

tm_shape(protected_areas) + 
  tm_polygons(col = "green", fill_alpha = 0.4, border.col = "darkgreen",
              fill.legend = tm_legend(title = "Protected Areas")) +
  tm_shape(ranges) +
  tm_polygons(col = "blue", fill_alpha = 0.4, border.col = "darkblue",
              fill.legend = tm_legend(title = "Ranges")) +
  tm_shape(overlap) +
  tm_polygons(col = "red", fill_alpha = 0.6, border.col = "black",
              fill.legend = tm_legend(title = "Overlap")) +
  tm_shape(occ_points) +
  tm_dots(col = "black", size = 0.6,
          col.legend = tm_legend(title = "Occurrence Points")) +
  tm_shape(KBAs_small) +
  tm_polygons(col = "yellow", fill_alpha = 0.4, border.col = "orange",
              fill.legend = tm_legend(title = "KBAs"))



# potential KBAs
# empty sf object
potential_KBAs <- st_sf(
  name = character(),
  geometry = st_sfc(crs = st_crs(protected_areas))
)


################# Extract areas: ################
#################################################

################# Tenerife ######################
####### Anaga
# east Anaga: extracted area from range
east_anaga <- ranges %>%
  filter(id == "eAnaga") %>%
  mutate(name = "eAnaga") %>%
  select(name, geometry)
# west Anaga: extracted area from range
west_anaga <- ranges %>%
  filter(id == "wAnaga") %>%
  mutate(name = "wAnaga") %>%
  select(name, geometry)
# create two areas of the approx. same size
west_anaga_split <- st_split(
  west_anaga,
 st_sfc(st_linestring(matrix(
   c(mean(c(st_bbox(west_anaga)[c("xmin","xmax")])) - 100,
      st_bbox(west_anaga)["ymin"],
      mean(c(st_bbox(west_anaga)[c("xmin","xmax")])) - 100,
      st_bbox(west_anaga)["ymax"]),
    ncol = 2, byrow = TRUE
  )), crs = st_crs(west_anaga))
) %>%
  st_collection_extract("POLYGON") %>%
  st_sf() %>%
  mutate(area = st_area(geometry)) %>%
 arrange(area) %>%
  summarise(geometry = c(st_union(geometry[1:2]), geometry[3]))
# safe both areas under separate ids
west_anaga1 <- west_anaga_split[1, ] %>%
  mutate(name = "West Anaga 1")
west_anaga2 <- west_anaga_split[2, ] %>%
  mutate(name = "West Anaga 2")


####### Lagunetas
# range including las Lagunetas 
range_lagunetas <- ranges %>%
  filter(id == "Lagunetas") %>%
  mutate(name = "Lagunetas") %>%
  select(name, geometry)
# protected area "La Resbala" in the range
protected_area_lagunetas <- protected_areas %>%
  filter(nombre == "La Resbala") %>%
  mutate(name = "La Resbala") %>%
  select(geometry)
# isolate la Resbala and everything westwards of la Resbala
inside <- st_intersection(range_lagunetas, protected_area_lagunetas)
outside <- st_difference(range_lagunetas, protected_area_lagunetas)
outside_smallest <- st_sf(geometry = st_cast(outside, "POLYGON")) %>% filter(st_area(geometry) == min(st_area(geometry)))
aguamansa <- st_union(outside_smallest, inside) %>%
  mutate(name = "Aguamansa") 
# devide the rest of the range in two:
outside_biggest <- st_sf(geometry = st_cast(outside, "POLYGON")) %>% filter(st_area(geometry) == max(st_area(geometry)))

bbox <- st_bbox(outside_biggest)
lagunetas_split <- st_split(
  outside_biggest,
  st_sfc(st_linestring(matrix(c(
    bbox["xmin"] , bbox["ymax"] - 1000,
    bbox["xmax"] , bbox["ymin"] - 1000
  ), ncol = 2, byrow = TRUE)), crs = st_crs(outside_biggest))
  ) %>% st_collection_extract("POLYGON") %>% st_sf()
lagunetas1 <- lagunetas_split[2, ] %>%
  mutate(name = "Lagunetas 1")
lagunetas2 <- lagunetas_split[1, ] %>%
  mutate(name = "Lagunetas 2")


####### Teno
# range called "Teno"
range_westTenerife <- ranges %>%
  filter(id == "Teno") %>%
  mutate(name = "Teno") %>%
  select(name, geometry)
# protected area called "Teno" 
protected_area_teno <- protected_areas %>%
  filter(nombre == "Teno") %>%
  select(geometry)
# devide in icod and teno
icod <- st_difference(range_westTenerife, protected_area_teno ) %>%
  mutate(name = "Icod")
teno <- st_intersection(range_westTenerife, protected_area_teno) %>%
  mutate(name = "Teno")




################# La Gomera ######################
# Garajonay, use the KBA already proposed
garajonay <- KBAs_small %>%
  filter(IntName == "Garajonay National Park") %>%
  mutate(name = "Garajonay") %>%
  select(name, geometry)


# Lomo del Balo
range_gomera <- ranges %>%
  filter(id == "Gomera") %>%
  mutate(name = "Gomera") %>%
  select(name, geometry)
orone <- protected_areas %>%
  filter(nombre == "Orone") %>%
  mutate(name = "Orone") %>%
  select(name, geometry)
carreton <- protected_areas %>%
  filter(nombre == "Lomo del Carretón") %>%
  mutate(name = "Carreton") %>%
  select(name, geometry)
# range gomera minus garajonay, orone, carreton
gomera_shortend <- range_gomera %>%
  st_difference(
    st_union(
      bind_rows(garajonay, orone, carreton)
    )
  ) %>%
  st_cast("POLYGON") %>%                 
  mutate(name = "Gomera_minus_some_protected_areas")
# the area between garajonay, orone and carreton is lomo_balo
lomo_balo <- gomera_shortend[6, ] %>%
  mutate(name = "Lomo Balo")


# Tazo-Caserio de Cubaba, Arguamul
cubaba <- gomera_shortend[2, ] %>%
  mutate(name = "Cubaba")
# carreton_in_range <- st_intersection(carreton, range_gomera)
# cubaba_carreton_geom <- st_union(
#   cubaba$geometry,
#   carreton_in_range$geometry
# )
# cubaba_carreton <- st_sf(
#   name = "Cubaba_Carreton",
#   geometry = cubaba_carreton_geom
# )

# Vallehermoso and more
hermigua_y_agulo <- KBAs_small %>%
  filter(IntName == "Step rocks of Hermigua and Agulo") %>%
  mutate(name = "Hermigua_y_Agulo") %>%
  select(name, geometry)
gomera_shortend2 <- st_difference(gomera_shortend, hermigua_y_agulo) %>%
  st_cast("POLYGON")
vallehermoso <- gomera_shortend2[3, ] %>%
  mutate(name = "Vallehermoso")

# Majona
majona <- protected_areas %>%
  filter(nombre == "Majona") %>%
  mutate(name = "Majona") %>%
  select(name, geometry)

# range: Hermigua and Agulo
# my name: El Cedro
gomera_shortend3 <- gomera_shortend %>%
  st_difference(
    st_union(
      bind_rows(majona, vallehermoso)
    )
  ) %>%
  st_cast("POLYGON") %>% 
  mutate(id = row_number())
cedro <- gomera_shortend3[3, ] %>%
  mutate(name = "Cedro")

# Vegaipala
benchijigua <- protected_areas %>%
  filter(nombre == "Benchijigua") %>%
  mutate(name = "Benchijigua") %>%
  select(name, geometry)
gomera_shortend4 <- range_gomera %>%
  st_difference(
    st_union(
      bind_rows(garajonay, majona, benchijigua)
    )
  ) %>%
  st_cast("POLYGON") %>% 
  mutate(id = row_number())
vegaipala <- gomera_shortend4[6,] %>%
  mutate(name = "vegaipala")

# Imada
gomera_shortend5 <- range_gomera %>%
  st_difference(
    st_union(
      bind_rows(garajonay, vegaipala, lomo_balo)
    )
  ) %>%
  st_cast("POLYGON") %>% 
  mutate(id = row_number())
imada <- gomera_shortend5[3,] %>%
  mutate(name = "imada") 

################# El Hierro ######################

# range around Ventejís
# extracted area from ranges
ventejis <- ranges %>%
  filter(id == "eHierro") %>%
  mutate(name = "Ventejís") %>%
  select(name, geometry)

# Frontera
# range west Hierro
frontera <- ranges %>%
  filter(id == "wHierro") %>%
  mutate(name = "Frontera") %>%
  select(name, geometry)


####################################################
################# combine ##########################


# sf to combine
sf_list <- list(
  east_anaga, west_anaga1, west_anaga2, lagunetas1, lagunetas2, aguamansa, icod, teno,
  garajonay, lomo_balo, cubaba, carreton, vallehermoso, cedro, majona, vegaipala, imada,
  ventejis, frontera
)

# only name and geometry
sf_list_simple <- lapply(sf_list, function(x) {
  x %>% select(name, geometry)
})

# combine
potential_KBAs <- bind_rows(sf_list_simple)


# view potential_KBAs
tmap_mode("view")
tm_shape(potential_KBAs) +
  tm_polygons(
    col = "purple",       # Füllfarbe
    alpha = 0.5,          # Transparenz
    border.col = "black", # Polygonränder
    title = "Potential KBAs"
  ) +
tm_shape(occ_points) +
  tm_dots(col = "black", size = 0.6,
          col.legend = tm_legend(title = "Occurrence Points")) 


##### save!!
st_write(potential_KBAs, "data/potential_KBAs/potential_KBAs.shp", append = FALSE)
