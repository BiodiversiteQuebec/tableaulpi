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
- [To-do list](#to-do-list)
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

[ information about how to install and run the app ]


## How it works

### Structure & styling

_quick overview + link to golem stuff_

Styling is done commonly to all dashboards in the RBDQ project _[ link to the styling code ]_.

### Reactivity

`taxachoice` via radio buttons 
Users of this dashboard can select the taxonomic group for which they want to see the LPI trend (...)

### Modules

#### Specific to this app

##### `mod_lpi_time_series.R`

A shiny module to generate the user interface and server functions used to produce a time series plotly of the Living Planet Index for the selected taxonomic group. This plotly is generated using the function `make_indextrend()`. This plot appears when the `Afficher l'IPV` button is clicked on the current version of the dashboard.

##### `mod_ridgeplot.R`

A shiny module to generate the user interface and server functions used to produce a plot showing the density of each taxonomic group's population growth rates over the entire period covered by the dashboard (currently set to 1990-2018). This plotly is generated using the function `make_ridgeplot()`. This plot appears when the `IPV par groupe` button is clicked on the current version of the dashboard.

##### `mod_population_bubbleplot.R`

A shiny module to generate the user interface and server functions used to produce a plotly showing each population's growth rate over the entire period covered by the dashboard (currently set to 1990-2018). This plotly is generated using the function `make_poptrend()`. This plot appears when the `IPV par population` button is clicked on the current version of the dashboard.


##### `mod_subset_plot_leafletproxy.R.R` from :star: :star: :star: `mapselector` :star: :star: :star: 

A shiny module to filter the point map on the home screen of the dashboard according to the selected taxonomic group in the sidebar using `leaflet proxy`.


## Credits

This dashboard is an ever-evolving collaborative effort with the entire [Réseau Biodiversité Québec](https://github.com/ReseauBiodiversiteQuebec) team, with special thanks to [Andrew Macdonald](https://github.com/aammd) for code review, contributions, and the development of [:star: :star: :star: `mapselector` :star: :star: :star:](https://github.com/ReseauBiodiversiteQuebec/mapselector), [Vincent Bellavance](https://github.com/VincentBellavance) for ideas and help with conception and design, data, troubleshooting, and development, and [Guillaume Larocque](https://github.com/glaroc) for help with design, development, troubleshooting, and a superhuman reactivity to the ever-evolving beast that is this project.



## To-do list

These are essential things that are left to do:
- [ ] Organise the figures (and their event buttons) in a way that makes sense in terms of information flow
- [ ] Add interpretation guide in the à propos 
- [ ] Add informative text in the tutorial and information modals
- [ ] Add selection option within the trendplot modal, the population one, and the ridgeplot/density plot
- [ ] Add information about time series length in map pop-ups (and in à propos)
- [ ] Add SurVol Benthos data in there.. and chiroptères?
- [ ] Centralize the palette used across the dashboard to avoid re-writing it in each plot function

## Wishlist

These are things that would enhance the dashboard, but are not necessary:
- [ ] Show the clicked population's position in the ridgeplot distribution?
- [ ] Think of a way to "score" population time series in terms of their length (vs. life histories???) to help with interpretation


## Links

* [Other RBDQ dashboards](https://coleo.biodiversite-quebec.ca/apps)
