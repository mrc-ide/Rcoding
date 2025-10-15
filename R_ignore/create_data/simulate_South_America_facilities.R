# simulate_South_America_facilities.R
#
# Author: Bob Verity
# Date: 2025-10-06
#
# Inputs:
#   - data/shapefiles/gadm41_<ISO>_shp/gadm41_<ISO>_1.shp  (plus supporting files)
#
# Outputs:
#   - data/facilities/<ISO>_facilities.csv
#
# Purpose:
#   Load the national boundary shapefile for a given country, simplify geometry,
#   randomly generate synthetic health facility locations inside the boundary,
#   attach simple attributes (zero-padded ID, catchment size), and save to CSV.
#
# NOTE - this script should be run from within the project associated with problem set 3.B.3, as it makes use of shapefiles etc. associated with that project

# ------------------------------------------------------------------

library(here)
library(sf)
library(rmapshaper)

# -----------------------
# 0) Define country code
# -----------------------
# Options:
#   ARG = Argentina
#   BOL = Bolivia
#   BRA = Brazil
#   PRY = Paraguay
#   URY = Uruguay
country_code <- "URY"

# -----------------------
# 1) Load shapefile
# -----------------------
shp_path <- here(
  "data", "shapefiles",
  sprintf("gadm41_%s_shp", country_code),
  sprintf("gadm41_%s_1.shp", country_code)
)

# .shp is the entry point; companion files (.dbf, .shx, .prj, .cpg) must sit alongside it
shape <- sf::st_read(shp_path, quiet = TRUE)

# Simplify geometry for faster plotting/analysis (keep ~5% of detail)
shape_simple <- rmapshaper::ms_simplify(shape, keep = 0.05, keep_shapes = TRUE)

# -----------------------
# 2) Simulate facility points
# -----------------------
set.seed(1)
n_facilities <- 50

# Ensure valid, unified polygon then plot it
shp_union <- sf::st_union(sf::st_make_valid(shape_simple))
plot(shp_union, col = "gray95", border = "gray40",
     main = sprintf("Synthetic facilities — %s", country_code))

# Sample random points INSIDE polygon
pts_sfc <- sf::st_sample(shp_union, size = n_facilities, type = "random")
facilities_sf <- sf::st_as_sf(pts_sfc)
sf::st_crs(facilities_sf) <- sf::st_crs(shape_simple)

# --- overlay points on the map (simple)
plot(sf::st_geometry(facilities_sf), add = TRUE, pch = 19, col = "firebrick", cex = 0.7)

# -----------------------
# 3) Add attributes
# -----------------------
# Zero-padded IDs like BOL_001, BOL_002, ...
facilities_sf$facility_id <- sprintf("%s_%03d", country_code, seq_len(n_facilities))

# Simpler catchment sizes (e.g., 5k–80k), uniformly sampled then rounded
facilities_sf$catchment_size <- round(runif(n_facilities, min = 5000, max = 80000))

# Also extract lon/lat (WGS84) for CSV export
fac_ll <- sf::st_transform(facilities_sf, 4326)
coords <- sf::st_coordinates(fac_ll)
fac_ll$lon <- coords[, 1]
fac_ll$lat <- coords[, 2]

# -----------------------
# 4) Save CSV
# -----------------------
csv_path <- here::here("data", "facilities", sprintf("%s_facilities.csv", country_code))

write.csv(
  data.frame(
    facility_id    = fac_ll$facility_id,
    lon            = fac_ll$lon,
    lat            = fac_ll$lat,
    catchment_size = fac_ll$catchment_size
  ),
  file = csv_path,
  row.names = FALSE
)
