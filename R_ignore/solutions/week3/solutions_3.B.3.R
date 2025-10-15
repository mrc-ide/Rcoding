# solutions_3.B.3.R
# ------------------------------------------------------------
# Purpose:
# Solution to problem set 3.B.3 "Modular Workflow with Spatial Data"
#
# Demonstrates changes required to the various sub-scripts (all combined below).
#
# ------------------------------------------------------------------
# UPDATED run_pipeline.R

# Options:
#   ARG = Argentina
#   BOL = Bolivia
#   BRA = Brazil
#   PRY = Paraguay
#   URY = Uruguay

country_code <- "URY"

# (followed by sourcing scripts)

# ------------------------------------------------------------------
# UPDATED load_shapefile.R

# Define the path to the shapefile (.shp)
shp_path <- here("data", "shapefiles",
                 sprintf("gadm41_%s_shp", country_code),
                 sprintf("gadm41_%s_1.shp", country_code))

# Read the shapefile
shape <- sf::st_read(shp_path)

# Simplify the geometry
shape_simple <- rmapshaper::ms_simplify(shape, keep = 0.05, keep_shapes = TRUE)

# ------------------------------------------------------------------
# UPDATED load_facilities.R

# Define path to CSV
fac_path <- here("data", "facilities", sprintf("%s_facilities.csv", country_code))

# Read facilities CSV
fac_df  <- read.csv(fac_path)

# Convert to sf
# CSV has lon/lat columns in WGS84 (EPSG:4326)
facilities_sf <- st_as_sf(x = fac_df, coords = c("lon", "lat"), crs = 4326)

# ------------------------------------------------------------------
# UPDATED plot_map.R

# Plot map using ggplot
ggplot() +
  geom_sf(data = shape_simple, fill = "#d9f0d3", color = "#1b7837", linewidth = 0.4) +
  geom_sf(data = facilities_sf, color = "firebrick", size = 1.5, alpha = 0.9) +
  ggtitle("Map of Health Facilities") +
  theme_minimal()

