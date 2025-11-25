library(tmap)


# preparations:
source("code/preparation/load_libraries.R")                  # load libraries
source("code/preparation/load_genind_with_potentialKBAs.R")  # load data set
rm(list = setdiff(ls(), c("genetic_info", "potential_KBAs")))# keep only the data set in environment

# potential KBAs with genetic information available
potential_KBAs_with_genetic_info <- potential_KBAs[potential_KBAs$name %in% unique(as.character(genetic_info@pop)), ]

# potential KBAs including more than 10 individuals with genetic information
individual_counts <- table(genetic_info@pop)
names_potential_KBAs_over10 <- names(individual_counts[individual_counts > 10])
potential_KBAs_over10 <- potential_KBAs[potential_KBAs$name %in% names_potential_KBAs_over10 , ]

# create a named vector with number of individuals per KBA
ind_count <- as.data.frame(table(genetic_info@pop))
names(ind_count) <- c("name", "n_individuals")

# summarize the infomation in potential_KBAs
potential_KBAs <- potential_KBAs %>%
  left_join(ind_count, by = "name") %>%   # fügt n_individuals hinzu
  mutate(
    fill_color = case_when(
      name %in% potential_KBAs_over10$name ~ "over9individuals",
      name %in% potential_KBAs_with_genetic_info$name ~ "genetics_available",
      TRUE ~ "no_genetics"
    ),
    nummer = ifelse(fill_color %in% c("genetics_available", "over9individuals"),
                    n_individuals, NA)   # Zahl in die Karte
  )

# save
write_sf(potential_KBAs, "results/individuals_per_area.shp")

# create the map
tm_shape(potential_KBAs) +
  tm_polygons(
    col = "fill_color",
    palette = c(
      "genetics_available" = "grey",
      "over9individuals"   = "black",
      "no_genetics"        = "white"
    ),
    border.col = "grey60", 
    legend.show = FALSE
  ) +
  tm_shape(subset(potential_KBAs, !is.na(nummer))) +
  tm_symbols(
    size = 1.2,               
    shape = 21,              
    col = "white",            
    border.col = "grey",
    alpha = 1
  ) +
  tm_shape(subset(potential_KBAs, !is.na(nummer))) +
  tm_text(
    text = "nummer",
    size = 0.7,
    col = "black",
    fontface = "bold", 
    remove.overlap = TRUE,
    shadow = TRUE,
    auto.placement = TRUE 
  ) +
  tm_layout(
    inner.margins = c(0.02, 0.02, 0.02, 0.02)
  )
