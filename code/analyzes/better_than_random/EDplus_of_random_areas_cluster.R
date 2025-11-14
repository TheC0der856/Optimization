# load libraries
library(doParallel)
library(foreach)

# preparations:
source("code/preparation/load_libraries.R")                  # load libraries
source("code/preparation/load_genind_with_potentialKBAs.R")  # load data set
rm(list = setdiff(ls(), "genetic_info"))                     # keep only the data set in environment
invisible(sapply(list.files("code/functions", pattern = "\\.R$", full.names = TRUE), source)) # load functions

# bootstrap the data set, to avoid sampling bias
bootstrapped_genind_list <- bootstrap_genind(genetic_info,
                                             ID_limit     = 10,
                                             n_bootstraps = 1000)

# calculate EDplus values for random area combinations of the same size like the top combination
EDplus_list <- list()
set.seed(123) # reproducible

n_cores <- 8
cl <- makeCluster(n_cores)
registerDoParallel(cl)

EDplus_random_areas <- foreach(genind = bootstrapped_genind_list, .combine = c,
                               .packages = c("adegenet", "poppr", "vegan")) %dopar% {
                                 random_areas <- sample(levels(genind@pop), 4) # same size like top_EDplus combination
                                 genind_subset <- genind[genind@pop %in% random_areas, ]
                                 calculate_EDplus(genind_subset)
                               }

stopCluster(cl)

# save random EDplus values
saveRDS(EDplus_random_areas, "results/test_stable_top_combination/EDplus_random_areas.rds")
