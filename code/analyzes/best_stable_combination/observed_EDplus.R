# load all summaries for the bootstrap number
files <- list.files("results/test_boots/175/", pattern = "summary", full.names = TRUE)
summaries <- list()
for (file in files) {
  name_is_the_number <- sub(".*?/([0-9]+)summary\\.csv", "\\1", file)
  df <- read.csv(file)
  summaries[[name_is_the_number]] <- df
}

best_cutoff5  <- "West Anaga 2_Icod_Frontera"
best_cutoff25 <- "West Anaga 2_Icod_Garajonay_Ventejís"

# collect all results for the relevant cutoffs (5%, 25%)
results_cutoff5 <- list()
results_cutoff25 <- list()
for (name in names(summaries)) {
  df <- summaries[[name]]
  
  row5 <- df[df$areaS == best_cutoff5, , drop = FALSE]   
  if (nrow(row5) > 0) row5$summary_id <- name
  results_cutoff5[[name]] <- row5  
  
  row25 <- df[df$areaS == best_cutoff25, , drop = FALSE]
  if (nrow(row25) > 0) row25$summary_id <- name
  results_cutoff25[[name]] <- row25
}
best5_df <- do.call(rbind, results_cutoff5)
best25_df <- do.call(rbind, results_cutoff25)

# calculate means
cols <- c("n_boot",         # only relevant to calculate how often the combination was found [%]: (best_cutoff_means$n_boot /175)*100
          "mean_EDplus",
          #"median_EDplus", # there is no big difference between mean and median here
          "sd_EDplus",
          #"max_EDplus",    # information included in CI
          "CI_lower25_5",
          "CI_upper97_5")
best_cutoff_means <- rbind(
  data.frame(KBA = best_cutoff5, t(colMeans(best5_df[cols], na.rm = TRUE))),
  data.frame(KBA = best_cutoff25, t(colMeans(best25_df[cols], na.rm = TRUE)))
)

write.csv(best_cutoff_means, "results/test_stable_top_combination/threshold_EDplus.csv")
