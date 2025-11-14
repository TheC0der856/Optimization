minimize_KBAs <- function(genetic_info,
                          ID_limit,
                          n_bootstraps,
                          threshold_factor,
                          n_cores) {
  
  # bootstrap the data set, to avoid sampling bias
  bootstrapped_genind_list <- bootstrap_genind(genetic_info, 
                                               ID_limit     = ID_limit, 
                                               n_bootstraps = n_bootstraps)
  
  
  
  # calculate EDplus for all bootstrapped genetic data
  all_EDplus_results <- EDplus_after_bootstrapping(bootstrapped_genind_list, 
                                                   threshold_factor = threshold_factor,
                                                   n_cores          = n_cores)
  
  
  # return results as a single table:
  combined_all_EDplus_results <- rbindlist(lapply(all_EDplus_results, as.data.table), use.names = TRUE, fill = TRUE)
  return(combined_all_EDplus_results)
}