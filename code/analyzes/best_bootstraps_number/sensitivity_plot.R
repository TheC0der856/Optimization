library(ggplot2)
library(dplyr)
library(RColorBrewer)

boots_sensitivity2 <- boots_sensitivity %>%
  mutate(
    boots_number = as.factor(boots_number),
    cutoff = factor(cutoff, levels = c("0", "5", "10", "15", "20", "25"))
  )

ggplot(boots_sensitivity2, aes(x = cutoff, y = frequency, color =  boots_number, group =  boots_number)) +
  geom_line(size = 1.2) +
  geom_point(size = 2) +
  geom_hline(yintercept = 95, linetype = "dashed", color = "black", linewidth = 0.5) +
  scale_color_brewer(palette = "Set2") +    # Dark2 dunkel und kontrastreich
  labs(
    #title = "Sensitivitätsanalyse der besten Kombination",
    #subtitle = "Frequenz der stabilsten Kombination bei verschiedenen Cutoffs",
    x = "Cutoff [%]",
    y = "Frequency of the best KBA combination [%]",
    color = "bootstrap number"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = "bottom", 
    panel.grid.major = element_blank(),   
    panel.grid.minor = element_blank(),
    axis.line = element_line(color = "black", linewidth = 0.5),
    axis.ticks = element_line(color = "black", linewidth = 0.5),
    axis.ticks.length = unit(0.15, "cm") 
  )