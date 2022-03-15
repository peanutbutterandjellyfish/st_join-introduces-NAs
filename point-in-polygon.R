# Install and Load Packages
packages = c("tidyverse", "sp")

package.check <- lapply(
  packages,
  FUN = function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, dependencies = TRUE)
      library(x, character.only = TRUE)
    }
  }
)

# Clear Workspace
rm(list = ls())

# Set Workspace
path <- ""
setwd(path)

#years <- substr(dataFiles, start = 4, stop = 7)

# Import Files
shp_file <- readOGR( 
  dsn = path, 
  layer ="Geometrie_Wahlkreise_19DBT_geo",
  verbose=FALSE,
  use_iconv = TRUE, encoding = "UTF-8", 
  stringsAsFactors = FALSE
)

# Check CSR of Shapefile
st_crs(shp_file)
# Convert sp object to an sf object
shp_file_sf <- st_as_sf(shp_file)

# Subset df and Convert df a sf object
df <- read.csv("reviews.csv")

# Use coordinates to create the simple feature geometry (sfg)
lnd_point <- df %>% 
  rowwise() %>% 
  mutate(point = list(st_point(c(latitude, longitude))))
# Set CRS 
lnd_geom <- st_sfc(lnd_point$point, crs = 4326) 
lnd_attrib = data.frame(df[c('reviewID.x', 'review_day')])
df_sf <- st_sf(lnd_attrib, geometry = lnd_geom)

# Find Points within Polygons
pts_in_poly <- st_join(df_sf, shp_file_sf, join = st_within)

