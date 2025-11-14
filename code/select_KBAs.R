library(dplyr)
library(sf)

# load potential KBAs
potential_KBAs <- st_read("data/potential_KBAs/potential_KBAs.shp")

# which areas?
best_combination  <- c("West Anaga 2", "Icod", "Garajonay","Ventejís")

# create KBAs sf- object
KBAs <- potential_KBAs %>%
  filter(name %in% best_combination)

# save
st_write(KBAs, "KBAs.shp")