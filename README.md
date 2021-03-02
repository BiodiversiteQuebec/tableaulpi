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
A shiny module to generate the user interface and server functions used to produce a time series plotly of the Living Planet Index for the selected taxonomic group. This plotly is generated using the function `make_indextrend()` in `utils_indextrend.R`.

##### `mod_population_bubbleplot.R`

##### `mod_ridgeplot.R`

##### `mod_subset_plot_leafletproxy.R.R`

#### From :star: :star: :star: `mapselector` :star: :star: :star: 



## Credits

This dashboard is an ever-evolving collaborative effort with the entire [Réseau Biodiversité Québec](https://github.com/ReseauBiodiversiteQuebec) team, with special thanks to [Andrew Macdonald](https://github.com/aammd) for code review, contributions, and the development of [:star: :star: :star: `mapselector` :star: :star: :star:](https://github.com/ReseauBiodiversiteQuebec/mapselector), [Vincent Bellavance](https://github.com/VincentBellavance) for ideas and help with conception and design, data, troubleshooting, and development, and [Guillaume Larocque](https://github.com/glaroc) for help with design, development, troubleshooting, and a superhuman reactivity to the ever-evolving beast that is this project.



## To-do list

These are essential things that are left to do:
- [ ] Add interpretation guide in the à propos 
- [ ] Add informative text in the tutorial and information modals
- [ ] Add selection option within the trendplot modal, the population one, and the ridgeplot/density plot
- [ ] Have each density curve show up by selecting taxons of interest instead of a ridgeplot?
- [ ] Add information about time series length in map pop-ups (and in à propos)
- [ ] Add SurVol Benthos data in there.. and chiroptères?
- [ ] Think of a way to "score" population time series in terms of their length (vs. life histories???) to help with interpretation

## Wishlist

These are things that would enhance the dashboard, but are not necessary:
- [ ] Show the clicked population's position in the ridgeplot distribution?


## Links

* [Other RBDQ dashboards](https://coleo.biodiversite-quebec.ca/apps)
