#load libraries
library(dplyr)
library(vegan)    #Delta+
library(poppr)    #bitwise.dist()
library(foreach)
library(doParallel)
library(data.table) # at EDplus_for_KBAcombinations



# load genind with KBAs in popualtions
source("code/preparation/load_genind_with_potentialKBAs.R")
rm(list = setdiff(ls(), "genetic_info")) # keep only the genind object in the environment

# load functions
invisible(sapply(list.files("code/functions", pattern = "\\.R$", full.names = TRUE), source))

# bootstrap the data set, to avoid sampling bias
bootstrapped_genind_list <- bootstrap_genind(genetic_info, ID_limit = 10, n_bootstraps = 10)

start_time <- Sys.time() # to measure the time, when not on cluster

# calculate EDplus for all bootstrapped genetic data
all_EDplus_results <- EDplus_after_bootstrapping(bootstrapped_genind_list, 
                                                 threshold_factor = 0.9,
                                                 n_cores = 3)

end_time <- Sys.time()
end_time - start_time

# analyse results:

all_EDplus_results <- lapply(all_EDplus_results, as.data.table)
combined <- rbindlist(all_EDplus_results, use.names = TRUE, fill = TRUE)

summary_EDplus <- combined[, .(
  n_boot = .N,
  mean_EDplus = mean(EDplus, na.rm = TRUE),
  median_EDplus = median(EDplus, na.rm = TRUE),
  sd_EDplus = sd(EDplus, na.rm = TRUE),
  max_EDplus = max(EDplus, na.rm = TRUE),
  CI_lower = quantile(EDplus, 0.025),   
  CI_upper = quantile(EDplus, 0.975)
), by = areaS]

summary_EDplus <- summary_EDplus[order( -n_boot, -mean_EDplus)]

write.csv(summary_EDplus, "results/summary_EDplus20boot.csv")

