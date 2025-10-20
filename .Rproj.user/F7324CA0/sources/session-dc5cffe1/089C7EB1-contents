# functions
calculate_EDplus <- function(genind_obj) {
  allele_frequencies <- tab(genind_obj, freq = TRUE)
  dist_matrix <- bitwise.dist(genind_obj)
  mod <- taxondive(t(allele_frequencies), dist_matrix)
  return(mod$EDplus)
}
