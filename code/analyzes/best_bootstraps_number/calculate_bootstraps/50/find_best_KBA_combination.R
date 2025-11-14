
# preparations:
source("code/preparation/load_libraries.R")                  # load libraries
source("code/preparation/load_genind_with_potentialKBAs.R")  # load data set
rm(list = setdiff(ls(), "genetic_info"))                     # keep only the data set in environment
invisible(sapply(list.files("code/functions", pattern = "\\.R$", full.names = TRUE), source)) # load functions

# settings
n_cores          <- 16
n_bootstraps     <- 50
output_dir       <- "results/test_boots/50"
n_runs           <- 100
ID_limit         <- 10
threshold_factor <- 0.9

# repeatedly calculate the best KBA combinations:
for (i in seq_len(n_runs)) {


 # calculate best KBA combinations
 best_KBA_combinations <- minimize_KBAs(genetic_info      = genetic_info,
                                        ID_limit          = ID_limit,
                                        n_bootstraps      = n_bootstraps,
                                        threshold_factor  = threshold_factor,
                                        n_cores           = n_cores)
 # summarize results
 summary <- summarize_minimized_KBAs(best_KBA_combinations)

 # save
 write.csv(best_KBA_combinations, file.path(output_dir, paste0(i, "best_KBA_combinations.csv")), row.names = FALSE)
 write.csv(summary,               file.path(output_dir, paste0(i, "summary.csv")), row.names = FALSE)
}
