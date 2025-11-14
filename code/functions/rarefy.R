rarefy <- function(genind_obj, nrep) {
  allele_matrix <- tab(genind_obj) # rows = individuals, columns = loci, values = number of alleles
  n_ind <- nInd(genind_obj)        # number of individuals
  # calculate mean number of observed alleles
  values <- sapply(1:n_ind, function(n) {
    replicate(nrep, {
      inds <- sample(1:n_ind, n)
      sum(colSums(allele_matrix[inds, , drop=FALSE]) > 0)
    }) %>% mean()
  })
  # save data
  data.frame(
    number_of_individuals    = 1:n_ind,
    mean_of_observed_alleles = values,
    potential_KBA            = pop(genind_obj)[1]
  )
}