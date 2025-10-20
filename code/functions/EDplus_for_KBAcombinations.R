EDplus_for_KBAcombinations <- function(genind_list, threshold) {
 
  results_list <- list()
  stop_loop <- FALSE
  
  for(number_combinations in 1:length(genind_list)) {
    if(stop_loop) break # stop calculations if there are results
    
    combinations <- combn(names(genind_list), number_combinations, simplify = FALSE) # calculate all possible combinations of potential KBAs
    temp_results <- list()
    
    temp_results <- lapply(combinations, function(area_number) { # faster than for
      # depending if there is only one KBA or several access to the fitting genind is different
      if (length(area_number) > 1) {
        genind_areaS <- do.call(repool, genind_list[area_number])
        number <- paste(area_number, collapse = "_")
      } else {
        genind_areaS <- genind_list[[area_number[1]]]
        number <- area_number[1]
      }
      # the number of alleles of the combination or single area
      n_alleles <- sum(colSums(genind_areaS@tab, na.rm = TRUE) > 0)
      
      # calculate EDplus if the number of alleles is more than the threshold
      if (n_alleles >= threshold) {
        EDplus <- calculate_EDplus(genind_areaS)
        temp_results[[length(temp_results) + 1]] <- data.table(  # save the results as dataframe in a temporary list
          areaS     = number,
          EDplus    = EDplus #,
          #n_alleles = n_alleles
        )
      } 
    })
    temp_results <- Filter(Negate(is.null), temp_results) # keep temporary results only if there are results
    
    # if there are results, save results and don't calculate more combinations
    if (length(temp_results) > 0) {
      results_list <- temp_results
      stop_loop <- TRUE
    }
  }
  
  # return results with the highest EDplus results at the top
  results_dataframe <- rbindlist(results_list)
  setorder(results_dataframe, -EDplus)
  return(results_dataframe)
}  