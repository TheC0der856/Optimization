library(ggplot2)


# load genetic data:
source("code/preparation/load_libraries.R")                  # load libraries
source("code/preparation/load_genind_with_potentialKBAs.R")  # load data set
rm(list = setdiff(ls(), "genetic_info"))                     # keep only the data set in environment
invisible(sapply(list.files("code/functions", pattern = "\\.R$", full.names = TRUE), source)) # load functions

# We need the allele counts per location
genind_list <- split_genind_into_list(genetic_info)

# calculate rarefaction values for the number of individuals in each potential KBA
rarefied <- do.call(rbind, lapply(genind_list, function(x) rarefy(x, nrep = 1000)))


# Plot
ggplot(rarefied, aes(
  x = number_of_individuals,
  y = mean_of_observed_alleles,
  group = potential_KBA
)) +
  geom_line(size = 1.2, linetype = "solid", color = "grey40") +
  labs(
    x = "Number of individuals",
    y = "Mean number of alleles"
  ) +
  scale_x_continuous(breaks = seq(0, max(rarefied$number_of_individuals), by = 10)) +
  theme_minimal(base_size = 14) +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.title.x = element_text(face = "bold", size = 16, margin = margin(t = 20)), # Abstand oben für x-Achse
    axis.title.y = element_text(face = "bold", size = 16, margin = margin(r = 20)), # Abstand rechts für y-Achse
    axis.text = element_text(color = "black", size = 12),
    axis.line = element_line(color = "black", size = 0.4),
    plot.margin = margin(t = 20, r = 20, b = 20, l = 20)
  )
