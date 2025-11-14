summarize_minimized_KBAs <- function(combined_all_EDplus_results) {
  
  # all information the summary contains
  summary_all_EDplus_results <- combined_all_EDplus_results[, .(
    n_boot         = .N,
    mean_EDplus    = mean(EDplus, na.rm = TRUE),
    median_EDplus  = median(EDplus, na.rm = TRUE),
    sd_EDplus      = sd(EDplus, na.rm = TRUE),
    max_EDplus     = max(EDplus, na.rm = TRUE),
    CI_lower25_5   = quantile(EDplus, 0.025, na.rm = TRUE),
    CI_upper97_5   = quantile(EDplus, 0.975, na.rm = TRUE)
  ), by = areaS]
  
  # sort
  summary_all_EDplus_results <- summary_all_EDplus_results[order(-mean_EDplus, -n_boot)]
  
  return(summary_all_EDplus_results)
}