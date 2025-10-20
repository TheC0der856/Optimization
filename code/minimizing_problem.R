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


start_time <- Sys.time()

# prepare cluster
n_cores <- 3
cl <- makeCluster(n_cores)
registerDoParallel(cl)

# parallelize EDplus calculation for all bootstraped data sets
all_EDplus_results <- foreach(boots_genind = bootstrapped_genind_list,
                              .packages = c("adegenet", "data.table", "vegan", "poppr")) %dopar% {
                                # split every bootstrapped data set for each potential KBA
                                KBAs <- levels(boots_genind@pop)
                                genind_list <- lapply(KBAs, function(p) boots_genind[boots_genind@pop == p])
                                names(genind_list) <- KBAs
                                
                                # create threshold
                                threshold <- sum(nAll(boots_genind)) * 0.9
                                
                                # calculate EDplus for each combination
                                EDplus_for_KBAcombinations(genind_list, threshold)
                              }

# stop cluster
stopCluster(cl)


head(all_EDplus_results[[10]], 10)

end_time <- Sys.time()
end_time - start_time
