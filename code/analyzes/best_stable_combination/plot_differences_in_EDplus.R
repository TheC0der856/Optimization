# load library
library(ggplot2)

# load data
observedEDplus <- read.csv("results/test_stable_top_combination/threshold_EDplus.csv")
estimatedEDplus <- read.csv("results/test_stable_top_combination/no_threshold_EDplus.csv")

# plot
ggplot() +
  # estimated
  geom_point(data = estimatedEDplus,
             aes(x = KBA, y = mean_EDplus),
             size = 4, color = "grey") + 
  geom_errorbar(data = estimatedEDplus,
                aes(x = KBA, ymin = CI_lower25_5, ymax = CI_upper97_5),
                width = 0.1, color = "grey", size = 1, linetype = "dashed") +
  # observed
  geom_point(data = observedEDplus,
             aes(x = KBA, y = mean_EDplus),
             size = 4, color = "black") +
  geom_errorbar(data = observedEDplus,
                aes(x = KBA, ymin = CI_lower25_5, ymax = CI_upper97_5),
                width = 0.1, color = "black", size = 1) +
  labs(
    x = "KBAs",
    y = bquote("Mean " * Delta^"+")
  ) +
  scale_x_discrete(
    labels = c(
      "West Anaga 2_Icod_Frontera" = "5% Cutoff",
      "West Anaga 2_Icod_Garajonay_Ventejís" = "25% Cutoff"
    )
  ) +
  theme_minimal(base_size = 14) +
  theme(
    axis.text.x = element_text(hjust = 0.5),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(color = "black", linewidth = 0.5),
    axis.ticks = element_line(color = "black", linewidth = 0.5),
    axis.ticks.length = unit(0.15, "cm")
  )