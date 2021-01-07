#' Function to crop data form LPI datasets to keep data from Quebec only
#' The dataset provided must contain the longitude and latitude on two separate columns
#'
#' @param filename: name of the file containing the raw data
#' @param dir: directory path containing the raw data file
#' @param save: wether or not the final dataframe will to be saved. If TRUE, the funtion will save the dataframe in the dir_path_clean. If FALSE, the function will return the dataframe.
#' @param lat: name of the latitude column in the dataset
#' @param lon: name of the longitude column in the dataset
#' @param sep: separator used in the csv file
#' @param dec: decimal used in the csv file

lpdCropQc <- function(filename, dir, sep = ",", dec = ".") {

  if(exists("filename") == FALSE) {
    stop("Error: the path to the dataset is not provided")
  } else if(exists("dir") == FALSE) {
    stop("Error: the path of the directory containing raw data is not provided")
  } else if(exists("sep") == FALSE) {
    stop("Error: separator is not provided")
  } else if(exists("dec") == FALSE) {
    stop("Error: decimal is not provided")
  } 
  
  if(length(grep("\\.tar\\.xy", filename)) > 0) {
    tempd <- tempdir()
    tempf <- untar(tarfile = paste0(dir, filename), exdir = tempd)
    csvfile <- paste0(tempd,"/",list.files(tempd)[grep("\\.csv", list.files(tempd))])
  } else {
    csvfile <- paste0(dir, filename)
  }
  if (file.exists(csvfile) == FALSE) {
    stop("Error: dataset does not exist")
  }

  # Create a spatialPointsDataframe
  ## Read csv file
  data_global <- read.csv(csvfile, header = FALSE, sep = sep, dec = dec, stringsAsFactors = FALSE)

  if(length(grep("\\.tar\\.xy", filename)) == 0) {
    colnames(data_global) <- data_global[1,]
    data_global <- data_global[-1,]
  }
  
  # Find lat and lon col names
  lat <- colnames(data_global)[grep("Latitude|latitude|LATITUDE", colnames(data_global))]
  lon <- colnames(data_global)[grep("Longitude|longitude|LONGITUDE", colnames(data_global))]

  if(!lat %in% colnames(data_global)) {
    stop("Error: latitude's name is not in the dataset's column names")
  } else if(!lon %in% colnames(data_global)) {
    stop("Error: longitude's name is not in the dataset's column names")
  }

  ## create vector of points
  pts <- lapply(1:nrow(data_global), 
    function(x) sf::st_point(as.numeric(data_global[x, c(lon, lat)]))
    )

  ## create simple feature geometry list column
  ## EPSG 3857 (google map)
  pts_sfc <- sf::st_sfc(pts, crs = 4326)

  ## create spatialPointsDataframe
  pts_df <- sf::st_sf(data_global, pts_sfc)

  
  # remove data outside the province of Quebec
  ## download
  new_dir <- dir
  # new_dir <- gsub("[a-z]+\\/$", "", dir)
  # if(!file.exists(paste0(new_dir,"shp_qc")) == TRUE) {
  #   download.file("ftp://transfert.mern.gouv.qc.ca/public/diffusion/RGQ/Vectoriel/Theme/Local/SDA_20k/SHP/SHP.zip", 
  #     method = "wget", f <- tempfile(), quiet = TRUE)
  #   unzip(f, exdir = new_dir)
  #   rm(f) # remove temporary file 
  #   system(paste0("mv ",new_dir,"SHP ",new_dir,"shp_qc"))
  # }

  ## read shapefile
  shp_qc <- sf::st_read(paste0(new_dir,"shp_qc/regio_l.shp"), quiet = TRUE)
  shp_qc <- sf::st_transform(shp_qc, 4326)

  ## convert from multiple linestrings to single polygon
  shp_qc <- sf::st_union(shp_qc) # Merge all regions together
  shp_qc <- sf::st_polygonize(shp_qc) # Convert multilines to a single polygon
  shp_qc <- sf::st_sf(shp_qc) # Convert from sfc object to sf object

  ## which points is within the shapefile
  crop <- suppressMessages(sf::st_covered_by(pts_df, shp_qc, sparse = FALSE)) # vector of TRUE/FALSE
  pts_qc <- pts_df[crop %in% TRUE, ]
  rm(crop)

  # return dataframe
  pts_qc <- as.data.frame(pts_qc[, -which(colnames(pts_qc) %in% "pts_sfc")])
  return(pts_qc)

}