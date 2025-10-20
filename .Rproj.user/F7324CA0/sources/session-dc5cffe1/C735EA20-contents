library(sf)
library(adegenet) #genind, etc.

# load data:
# potential KBAs
potential_KBAs <- st_read("data/potential_KBAs/potential_KBAs.shp")

# copy .structure file and change file ending into .stru
# delete the first row
# load genetic data
genetic_info <- read.structure(
  file = "data/SNPs.stru",
  n.ind = 345,           # Anzahl Individuen
  n.loc = 5237,          # Anzahl Loci
  onerowperind = FALSE,  # 1 Zeile pro Individuum (oft TRUE)
  col.lab = 1,           # Spalte mit den Individuennamen
  col.pop = 2,           # Spalte mit der Populationszuordnung
  ask = FALSE            # wichtig: keine interaktive Abfrage
)

# add coordinates
# load data:
individual <- indNames(genetic_info) 
coordinates <- read.csv("data/collection_data.csv")
# organize coordinates:
coordinates$WGS84_X <- as.numeric(gsub(",", ".", coordinates$WGS84_X))
coordinates$WGS84_Y <- as.numeric(gsub(",", ".", coordinates$WGS84_Y))
coordinates_filtered <- coordinates[coordinates$Specimen_ID %in% individual, ] # removes rows without a matching individual
coordinates_ordered <- coordinates_filtered[match(individual, coordinates_filtered$Specimen_ID), ] # same order like in individual
coordinates_clean <- coordinates_ordered[!is.na(coordinates_ordered$WGS84_X) & !is.na(coordinates_ordered$WGS84_Y), ] # avoid mistake because NA
coordinates_sf <- st_as_sf(coordinates_clean, coords = c("WGS84_X", "WGS84_Y"), crs = 4326) 
coordinates_matching_coordinatesystem <- st_transform(coordinates_sf, crs = st_crs(potential_KBAs))
tidy_coordinates <- coordinates_matching_coordinatesystem %>%
  dplyr::select(Specimen_ID, geometry)

# which individuals are in an area?
individual_area <- st_join(tidy_coordinates, potential_KBAs , join = st_within)
#table(individual_area$area_ID)
# add the area information to genind object
population <- individual_area$name
pop(genetic_info) <- as.factor(population)
