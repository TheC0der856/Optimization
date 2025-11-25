# Coefficient of Variation (CV) is an indicator for the robustness/stability/consistency of EDplus values
# load libraries
library(dplyr)
library(ggplot2)

# load data
observedEDplus <- read.csv("results/test_stable_top_combination/threshold_EDplus.csv")
estimatedEDplus <- read.csv("results/test_stable_top_combination/no_threshold_EDplus.csv")

# calculate Coefficient of Variation (CV)
# CV = (SD/mean) *100
observedEDplus <- observedEDplus %>%
  mutate(Type = "Observed",
         Coefficient_of_Variation = (sd_EDplus / mean_EDplus) * 100)
estimatedEDplus <- estimatedEDplus %>%
  mutate(Type = "Estimated",
         Coefficient_of_Variation = (sd_EDplus / mean_EDplus) * 100)

# combine tables
CV_table <- bind_rows(observedEDplus, estimatedEDplus) %>%
  select(KBA, Type, mean_EDplus, sd_EDplus, Coefficient_of_Variation)

# plot results
ggplot(CV_table, aes(x = KBA, y = Coefficient_of_Variation)) +
  geom_col(data = subset(CV_table, Type == "Estimated"),
           aes(fill = Type), width = 0.6) +
  geom_col(data = subset(CV_table, Type == "Observed"),
           aes(fill = Type), width = 0.6) +
  scale_fill_manual(values = c("Estimated" = "grey70", "Observed" = "black")) +
  labs(
    x = "KBAs",
    y = "Coefficient of Variation [%]", 
    fill = NULL
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
    axis.ticks.length = unit(0.15, "cm"),
    legend.position = "none"
  )




