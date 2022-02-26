#'
#' @param number text icon color_class 
#'
#' @return
#' @export
# export
stats_card <- function(number, text, icon, color_class='main-1', size_class='col-md-12'){
  div(class=size_class, div(class='stati card-left',icon(icon,class=color_class), div(strong(number,class=color_class),span(text))))
}

#'
#' @param number text icon color_class 
#'
#' @return
#' @export
# export
photo_card <- function(url='https://coleo.biodiversite-quebec.ca/apps/shiny-src/pictograms/placeholder-image.jpg',name,text='',href='#'){
  div(class="photo-cards",style="flex:1",a(href=href,target='_blank',div(class="top_photos",style=paste0('background: url("',url,'")')),div(class="photo-card-body",h5(class="photo_species_name",name),div(class='photo_main_text',text))))
}