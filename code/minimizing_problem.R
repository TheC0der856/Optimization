#load libraries
library(dplyr)
library(vegan)    #Delta+
library(poppr)    #bitwise.dist()
library(foreach)
library(doParallel)


# load genind with KBAs in popualtions
source("code/preparation/load_genind_with_potentialKBAs.R")
rm(list = setdiff(ls(), "genetic_info")) # keep only the genind object in the environment

# load functions
invisible(sapply(list.files("code/functions", pattern = "\\.R$", full.names = TRUE), source))


subsamples_list <- bootstrap_genind(genetic_info, ID_limit = 10, n_bootstraps = 10)



all_EDplus_results <- vector("list", length(subsamples_list))


start_time <- Sys.time()
for(b in seq_along(subsamples_list)) {
  
  genind_sub <- subsamples_list[[b]]
  
  # Create genind_list: one element per population
  pops <- levels(genind_sub@pop)
  genind_list <- lapply(pops, function(p) genind_sub[genind_sub@pop == p])
  names(genind_list) <- pops
  
  # Total alleles threshold
  total_alleles <- sum(nAll(genind_sub))
  threshold <- total_alleles * 0.9
  
  # Setup parallel backend
  num_cores <- parallel::detectCores() - 1
  cl <- makeCluster(num_cores)
  registerDoParallel(cl)
  
  stop_loop <- FALSE
  EDplus_df <- data.frame()
  
  for(n_combinations in 1:length(genind_list)) {
    if(stop_loop) break
    
    combinations <- combn(names(genind_list), n_combinations, simplify = FALSE)
    
    results <- foreach(area_names = combinations, .combine = rbind,
                       .packages = c("adegenet","poppr","vegan")) %dopar% {
                         if(length(area_names) > 1){
                           genind_areaS <- do.call(repool, genind_list[area_names])
                           name <- paste(area_names, collapse = "_")
                         } else {
                           genind_areaS <- genind_list[[area_names[1]]]
                           name <- area_names[1]
                         }
                         
                         n_alleles <- sum(colSums(genind_areaS@tab) > 0)
                         if(n_alleles >= threshold){
                           EDplus <- if(nInd(genind_areaS) < 2) NA else calculate_EDplus(genind_areaS)
                           data.frame(areaS = name, EDplus = EDplus, n_alleles = n_alleles)
                         } else {
                           NULL
                         }
                       }
    
    if(!is.null(results) && nrow(results) > 0){
      EDplus_df <- rbind(EDplus_df, results)
      stop_loop <- TRUE
    }
  }
  
  stopCluster(cl)
  
  # Sort by EDplus decreasing
  EDplus_df <- EDplus_df[order(EDplus_df$EDplus, decreasing = TRUE), ]
  
  all_EDplus_results[[b]] <- EDplus_df
}


head(all_EDplus_results[[10]], 10)

end_time <- Sys.time()
end_time - start_time
