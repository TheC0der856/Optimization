EDplus_after_bootstrapping <- function(bootstrapped_genind_list, threshold_factor = 0.9, n_cores = 3) {

  # Cluster vorbereiten
  cl <- makeCluster(n_cores)
  registerDoParallel(cl)
  
  # parallelize EDplus calculation for all bootstraped data sets
  all_EDplus_results <- foreach(boots_genind = bootstrapped_genind_list,
                                .packages = c("adegenet", "data.table", "vegan", "poppr"), 
                                .export = c("EDplus_for_KBAcombinations",
                                            "calculate_EDplus")) %dopar% {
                                  # split every bootstrapped data set for each potential KBA
                                  KBAs <- levels(boots_genind@pop)
                                  genind_list <- lapply(KBAs, function(p) boots_genind[boots_genind@pop == p])
                                  names(genind_list) <- KBAs
                                  
                                  # create threshold
                                  threshold <- sum(nAll(boots_genind)) * threshold_factor
                                  
                                  # calculate EDplus for each combination
                                  EDplus_for_KBAcombinations(genind_list, threshold)
                                }
  
  # Cluster stoppen
  stopCluster(cl)

  return(all_EDplus_results)
}
