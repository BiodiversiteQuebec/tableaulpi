# Functions specific to the Living Planet Index dashboard

library(ggplot2)

# data import and manipulation =================================================

# Import sf object of points in the Living Planet Database
lpd_qc <- readRDS("data/lpd_qc_fake.rds")
# Import population growth rates
pop_trends <- readRDS("data/lpi_trend_populations.rds")

# point map of populations =====================================================



# plotly of index trend ========================================================

index_trend_plot <- function(taxa){
  
  # create colorblind-friendly palette
  pal <- c("black", "#56B4E9", "#D55E00", "#E69F00", "#0072B2", "#009E73")
  names(pal) <- c("tous", "amphibiens", "mammifères", "oiseaux", "poissons", "reptiles")
  # create ggplot theme options to apply to all figures
  plot_theme <- theme_classic() +
    theme(axis.text = element_text(size = 13),
          axis.title = element_text(size = 15))

  # Import LPI results per taxa group
  lpi_df <- readRDS("data/lpi_index_taxa.rds")
  # filter for subset of values according to user's choice of taxa
  lpi_df <- lpi_df[which(lpi_df$taxa == taxa),]
  
  # plot the LPI trend
  p <- ggplot(data = lpi_df, aes(x = year)) +
    scale_fill_manual(values = pal) +
    geom_ribbon(aes(ymin = lpi_cilo, 
                    ymax = lpi_cihi),
                fill = unname(pal[taxa]), 
                alpha = .7) +
    geom_line(aes(y = lpi), 
              col = "white", 
              lwd = .5) +
    # baseline reference
    geom_hline(yintercept = 1, 
               lty = 2, 
               col = "black", 
               lwd = .5) +
    labs(y = "Indice Planète Vivante", x = "") +
    # set limits
    coord_cartesian(ylim = c(-2, 4)) +
    plot_theme
  # generate as plotly object
  plotly::ggplotly(p)
}

# plotly of population-level trends ============================================



# text for "about" section =====================================================

# to update! ====
about_text <- "Developed by Loh et al. (2005), the World Wildlife Fund (WWF), and the Zoological Society of London, the Living Planet Index (LPI) measures the overall global trend in vertebrate abundances since 1970, including terrestrial, freshwater, and marine systems. The LPI has served as a popular indicator of global biodiversity change since the first Living Planet Report appeared in 1998, representing two decades of monitoring population-level trends (WWF 2018). This popularity is largely attributable to the LPI’s intuitive association with biodiversity targets, which makes it a powerful tool to communicate the status of biodiversity to decision-makers tasked with the management of biodiversity (Collen et al. 2009). The index is also used to present biodiversity trends to the general public in an accessible way, which incites public engagement in biodiversity issues (Collen et al. 2009). Importantly, the Convention on Biological Diversity (CBD) selected the LPI to monitor progress towards the 2020 Aichi Biodiversity Targets for population abundance trends (CBD 2016). The LPI was also selected as an Essential Biodiversity Variable, solidifying the index as an essential tool for the harmonized study, reporting, and management of biodiversity change worldwide (Pereira et al. 2013)."
