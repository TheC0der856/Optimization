# How much better is the observed EDplus value of the top combination (25% cutoff)
# in comparison to a random combination of the same size?

# load the mean EDplus value of the top combination
top_EDplus_table  <- read.csv("results/test_stable_top_combination/threshold_EDplus.csv")
top_EDplus        <- top_EDplus_table$mean_EDplus[2]

# load random EDplus values
EDplus_random_areas <- readRDS("results/test_stable_top_combination/EDplus_random_areas.rds")

# calculate z-score
# z_score > 2 → above average
# z_score > 3 → extraordinary
mean_EDplus <- mean(EDplus_random_areas)
mean_sd     <- sd(EDplus_random_areas)
z_score <- (top_EDplus - mean_EDplus)/ mean_sd
z_score

# to calculate the p value from the z-score we need to know if the data is normally distributed
#shapiro.test(EDplus_random_areas)
#hist(EDplus_random_areas)
# data is not normally distributed

p_value_empirical <- mean(EDplus_random_areas >= top_EDplus)
p_value_empirical