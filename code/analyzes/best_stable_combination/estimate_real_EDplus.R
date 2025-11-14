# preparations
source("code/preparation/load_libraries.R")                  # load libraries
source("code/preparation/load_genind_with_potentialKBAs.R")  # load data set
rm(list = setdiff(ls(), "genetic_info"))                     # keep only the data set in environment
invisible(sapply(list.files("code/functions", pattern = "\\.R$", full.names = TRUE), source)) # load functions

# calculate Delta+ for the two top combinations without threshold
stable_top_combination1 <- c("West Anaga 2", "Icod", "Frontera")
stable_top_combination2  <- c("West Anaga 2", "Icod", "Garajonay","Ventejís")

# bootstrap the data set
bootstrapped_genind_list <- bootstrap_genind(genetic_info, 
                                             ID_limit     = 10, 
                                             n_bootstraps = 175) 


# calculate EDplus for both top combinations
EDplus_list1 <- lapply(bootstrapped_genind_list, function(gen) {
  potential_KBA <- pop(gen)
  gen_stable_top_combination <- gen[which(potential_KBA %in% stable_top_combination1), ]
  calculate_EDplus(gen_stable_top_combination)
})
EDplus1 <- unlist(EDplus_list1)

EDplus_list2 <- lapply(bootstrapped_genind_list, function(gen) {
  potential_KBA <- pop(gen)
  gen_stable_top_combination <- gen[which(potential_KBA %in% stable_top_combination2), ]
  calculate_EDplus(gen_stable_top_combination)
})
EDplus2 <- unlist(EDplus_list2)

# summarize results:
EDplus_summary <- data.frame(
  KBAs = c(paste(stable_top_combination1, collapse = "_"),
          paste(stable_top_combination2, collapse = "_")),
  mean_EDplus = c(mean(EDplus1, na.rm = TRUE),
                  mean(EDplus2, na.rm = TRUE)),
  sd_EDplus = c(sd(EDplus1, na.rm = TRUE),
                sd(EDplus2, na.rm = TRUE)),
  CI_lower25_5 = c(quantile(EDplus1, 0.025, na.rm = TRUE),
                   quantile(EDplus2, 0.025, na.rm = TRUE)),
  CI_upper97_5 = c(quantile(EDplus1, 0.975, na.rm = TRUE),
                   quantile(EDplus2, 0.975, na.rm = TRUE))
)

write.csv(EDplus_summary, "results/test_stable_top_combination/no_threshold_EDplus.csv")