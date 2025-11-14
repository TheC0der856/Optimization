
# preparations:
source("code/preparation/load_libraries.R")                  # load libraries
source("code/preparation/load_genind_with_potentialKBAs.R")  # load data set
rm(list = setdiff(ls(), "genetic_info"))                     # keep only the data set in environment
invisible(sapply(list.files("code/functions", pattern = "\\.R$", full.names = TRUE), source)) # load functions

# instead of for loop working with array
args <- commandArgs(trailingOnly = TRUE)
RUN_ID <- as.numeric(args[1])

# settings
n_bootstraps     <- 200
output_dir       <- "results/test_boots/200"

# calculate best KBA combinations
best_KBA_combinations <- minimize_KBAs(genetic_info      = genetic_info,
                                       ID_limit          = 10,
                                       n_bootstraps      = n_bootstraps,
                                       threshold_factor  = 0.9,
                                       n_cores           = 1)
# summarize results
summary <- summarize_minimized_KBAs(best_KBA_combinations)

# save
write.csv(best_KBA_combinations, file.path(output_dir, paste0(RUN_ID, "best_KBA_combinations.csv")), row.names = FALSE)
write.csv(summary,               file.path(output_dir, paste0(RUN_ID, "summary.csv")), row.names = FALSE)

