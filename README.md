<h1 style="font-weight:normal">
  <a href="https://coleo.biodiversite-quebec.ca/apps/tableaulpi/">
    <img src=https://github.com/ReseauBiodiversiteQuebec/mapselector/blob/main/inst/app/www/coleo_test_small.png?raw=true alt="ReseauBiodiversiteQuebec" width=35>
  </a>
  &nbsp;Tableau LPI&nbsp;
  <a href="https://coleo.biodiversite-quebec.ca/apps/tableaulpi/"><img src=https://img.shields.io/badge/View-TableauLPI-brightgreen.svg?colorA=grey></a>
  <a href="https://opensource.org/licenses/MIT/"><img src=https://img.shields.io/badge/License-MIT-blue.svg?colorA=grey]></a>
</h1>

Un tableau de bord Shiny pour visualiser les tendances de populations animales au Québec avec l'Indice Planète Vivante.
<br> 

## Table of Contents
- [Features](#features)
- [Datasets](#datasets)
- [Get started](#get-started)
- [How it works](#how-it-works)
- [Credits](#credits)
- [Wishlist](#wishlist)
- [Links](#links)


## Features

* Map of population time series in Québec, used to calculate the index
* Visual presentation of the Living Planet Index and of raw data at the province, species group, and population scale
* Information panels and modals to describe the index, its calculation, and its interpretation


## Datasets 

All visualisations available in this dashboard are based on data from the following sources: 
* [Living Planet Database](https://livingplanetindex.org/data_portal)
* SurVol Benthos (soon)
* BioTIME (soon)


## Get started

This is a Shiny app built as an R package. The package can be installed using the R package `devtools`, like so:

```
devtools::install_github("ReseauBiodiversiteQuebec/tableaulpi")
```

To run the app locally within the tableaulpi directory, run the following:

```
library(tableaulpi)
run_app()
```

There may be some differences between this local version and the [published](https://coleo.biodiversite-quebec.ca/apps/tableaulpi/) version due to additional styling when the dashboard gets published onto the server. 


## How `tableaulpi` works

### Structure & styling

This dashboard was built using the [golem](https://thinkr-open.github.io/golem/) framework (more information on this [here](https://engineering-shiny.org/golem.html)).

Styling is done commonly to all dashboards in the RBDQ project via [ :star: :star: :star: `mapselector` :star: :star: :star: ](https://github.com/ReseauBiodiversiteQuebec/mapselector).

### Reactivity

`taxa` via radioGroup buttons on main page: filters the map of population coordinates

`clicked_population` selects a population ID from the map, and opens a modal to show the population time series and some summary information about the population.

`target_taxa` via radioGroup buttons on IPV plot module, in each tab. Filters the plot by taxonomic group selected by the user.

`target_years` via radioGroup buttons on IPV plot module, tab 'Tendances dans le temps'. Filters the plot by the range of years selected by the user.


### Modules

#### Specific to this app

##### `mod_lpi_time_series.R`

A shiny module to generate the user interface and server functions used to produce a time series plotly of the Living Planet Index for the selected taxonomic group. This plotly is generated using the function `make_indextrend()`. This plot appears when the `Afficher l'IPV` button is clicked on the current version of the dashboard.

##### `mod_trend_distribution.R`

A shiny module to generate the user interface and server functions used to produce a barplot (plotly) showing the proportion of populations that are declining, stable (between -5% and 5% mean annual change), or growing over a user-selected time period between 1950-2018. This plotly is generated using the function `make_trend_distribution()`. This plot appears when the `IPV par groupe` button is clicked on the current version of the dashboard.

##### `mod_trend_perpopulation.R`

A shiny module to generate the user interface and server functions used to produce a scatter plotly showing each population's growth rate over the entire period covered by the dashboard (currently set to 1990-2018). This plotly is generated using the function `make_trend_perpopulation()`. 


##### `mod_subset_plot_leafletproxy.R` 

A shiny module to filter the point map on the home screen of the dashboard according to the selected taxonomic group in the sidebar using `leaflet proxy`.


## Credits

This dashboard is an ever-evolving collaborative effort with the entire [Réseau Biodiversité Québec](https://github.com/ReseauBiodiversiteQuebec) team, with special thanks to [Andrew Macdonald](https://github.com/aammd) for code review, contributions, and the development of [:star: :star: :star: `mapselector` :star: :star: :star:](https://github.com/ReseauBiodiversiteQuebec/mapselector), [Vincent Bellavance](https://github.com/VincentBellavance) for ideas and help with conception and design, data, troubleshooting, and development, and [Guillaume Larocque](https://github.com/glaroc) for help with design, development, troubleshooting, and a superhuman reactivity to the ever-evolving beast that is this project.

## Wishlist

These are things that would enhance the dashboard, but are not necessary:
- [ ] Show the clicked population's position in the ridgeplot distribution?
- [ ] Show some rating of the certainty of the index, based on # of populations, # data points, etc.


## Links

* [Other RBDQ dashboards](https://coleo.biodiversite-quebec.ca/apps)
