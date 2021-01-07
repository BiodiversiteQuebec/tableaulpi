# Function to make needle plots like the NYT election needle plots
# to be used to show trend for each taxon

library(tidyverse)

# make dummy dataset
df <- data.frame(
  "taxa" = c("mammifère", "oiseaux", "reptiles"),
  "dt" = c(1.2, 1.0, -0.7),
  "cilo" = c(1.1, 0.9, -0.8),
  "cihi" = c(1.3, 1.1, -0.6)
)

df_base <- data.frame(
  "status" = c("decline", "stable", "growing"),
  "dt" = c(-2, 0.5, 2)
  )

ggplot() +
  geom_bar(data = df_base, aes(y = dt, x= "", fill = status), 
           stat = "identity", 
           position = "stack", width = 1,
           alpha = 0.5) + 
  coord_polar("y", start = -3.15) +
  theme_void() +
  theme()


  geom_bar(aes(y = dt, fill = taxa), position = "dodge") +
  coord_polar()

ggplot(data, aes(x="", y=value, fill=group)) +
  geom_bar(stat="identity", width=1) +
  coord_polar("y", start=0)