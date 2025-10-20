# Function to create bootstrapped subsamples from a genind object

bootstrap_genind <- function(genind_obj, ID_limit = 10, n_bootstraps = 1) {

  potential_KBAs <- levels(genind_obj@pop)
  KBAs_enough_IDs <- potential_KBAs[table(genind_obj@pop) >= ID_limit]
  subsamples_list <- vector("list", n_bootstraps)
  
  # Generate bootstrapped subsamples
  for(i in 1:n_bootstraps){
    # For each population, randomly sample exactly ID_limit individuals
    sampled_inds <- unlist(
      lapply(KBAs_enough_IDs, function(KBA) {
        IDs <- which(genind_obj@pop == KBA)   # Get indices of individuals in KBA
        sample(IDs, ID_limit)                 # Randomly sample ID_limit individuals
      })
    )
    #save
    subsamples_list[[i]] <- genind_obj[sampled_inds]
  }
  return(subsamples_list)
}
