split_genind_into_list <- function(genetic_info) {
  potential_KBAs <- pop(genetic_info)
  genind_list <- lapply(unique(potential_KBAs), function(kba_name) {
    inds <- which(potential_KBAs == kba_name)
    genetic_info[inds, ]
  })
  names(genind_list) <- unique(potential_KBAs)
  return(genind_list)
}