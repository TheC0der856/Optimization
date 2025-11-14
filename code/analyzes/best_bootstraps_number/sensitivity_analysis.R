library(dplyr)

base_dir <- "results/test_boots/"
subfolders <- list.dirs(base_dir, full.names = TRUE, recursive = FALSE)
cutoff_perc <- c(0, 0.05, 0.10, 0.15, 0.20, 0.25)
all_summaries <- list()

for (sub in subfolders) {
  folder_name <- basename(sub)
  max_boot <- as.numeric(folder_name)
  
  
  # load all summaries of KBA combinations for the bootstrap number
  files <- list.files(sub, pattern = "summary", full.names = TRUE)
  summaries <- list()
  for (file in files) {
    name_is_the_number <- sub(".*?/([0-9]+)summary\\.csv", "\\1", file)
    df <- read.csv(file)
    summaries[[name_is_the_number]] <- df
  }


  # sensitivity analysis of the best combination
  all_cutoff_tables <- list()
  for (perc in cutoff_perc) {
    cutoff <- max_boot * perc
    summaries_cutoff <- lapply(summaries, function(df) {
      df[df$n_boot >= cutoff, , drop = FALSE]
    })
    # count the stability of the best combination
    non_empty <- summaries_cutoff[sapply(summaries_cutoff, nrow) > 0]
    best_combinations_cutoff <- bind_rows(lapply(names(non_empty), function(name) {
      first_row <- non_empty[[name]][1, , drop = FALSE]
      first_row$id <- name
      first_row
    }))
    all_cutoff_tables[[paste0(perc*100)]] <- table(best_combinations_cutoff$areaS)
  }
  
  # summarize results for this number of bootstraps
  cutoff_summary <- do.call(
    rbind,
    lapply(names(all_cutoff_tables), function(name) {
      tab <- all_cutoff_tables[[name]]
      max_idx <- which.max(tab)
      data.frame(
        boots_number = max_boot,
        cutoff = name,
        areaS = names(tab)[max_idx],
        #abundance = as.integer(tab[max_idx]), # 100 repeats? abundance = frequency!
        frequency = round(as.integer(tab[max_idx]) / length(summaries) * 100, 2),
        row.names = NULL
      )
    })
  )
  
  all_summaries[[folder_name]] <- cutoff_summary
}

boots_sensitivity <- bind_rows(all_summaries)
boots_sensitivity