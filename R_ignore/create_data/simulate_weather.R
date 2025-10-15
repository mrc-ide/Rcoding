# simulate_weather_raw.R
#
# Author: Bob Verity
# Date: 2025-10-02
#
# Outputs:
#   - weather_raw.csv   (daily weather for two UK cities, with minor quirks)
#
# Purpose:
#   Simulate daily weather covariates (mean temperature °C, rainfall mm)
#   for two cities over one calendar year, including mild data-quality
#   issues that students will fix:
#     * City names with leading/trailing whitespace on a subset of rows
#     * Inconsistent case for a few city names
#     * Date stored as ISO character (not Date) to encourage conversion
#
# ------------------------------------------------------------------

# If you prefer writing to a project subfolder, set an output directory here:
# out_dir <- "data_raw"  # uncomment and ensure this exists, e.g. in your project
# dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

set.seed(1)

## -----------------------
## Parameters
## -----------------------
year    <- 2024
cities  <- c("London", "Manchester")
ndays   <- ifelse(((year %% 4 == 0) & (year %% 100 != 0)) | (year %% 400 == 0), 366, 365)

dates   <- seq.Date(as.Date(paste0(year, "-01-01")),
                    as.Date(paste0(year, "-12-31")),
                    by = "day")
t_index <- seq_along(dates)

## -----------------------
## Seasonal generators
## -----------------------
# Temperature: city-specific baseline + annual sine wave + AR(1)-ish noise
temp_curve <- function(city, t) {
  # city baselines & amplitudes (°C)
  if (city == "London") {
    base <- 11.0; amp <- 8.0
  } else { # Manchester, slightly cooler/wetter on average
    base <- 10.0; amp <- 7.5
  }
  seas <- base + amp * sin(2 * pi * (t - 30) / 365)   # peak around late July
  # add a touch of autocorrelated noise
  eps  <- numeric(length(t)); eps[1] <- rnorm(1, 0, 1.5)
  for (i in 2:length(t)) eps[i] <- 0.6 * eps[i-1] + rnorm(1, 0, 1.0)
  pmax(seas + eps, -5) # cap at -5°C just to avoid extremes
}

# Rainfall: use a “wet day” probability with seasonality + positive amounts
rain_curve <- function(city, t) {
  # Probability of rain varies seasonally; north-west slightly wetter
  if (city == "London") {
    p_wet_base <- 0.28; p_wet_amp <- 0.10
    shape <- 2.0; scale_base <- 2.0
  } else { # Manchester
    p_wet_base <- 0.35; p_wet_amp <- 0.10
    shape <- 2.2; scale_base <- 2.4
  }
  p_wet <- pmin(pmax(p_wet_base + p_wet_amp * sin(2 * pi * (t + 20) / 365), 0.05), 0.8)
  is_wet <- rbinom(length(t), 1, p_wet) == 1
  # Amount on wet days ~ Gamma; slight seasonality in scale
  scale_t <- pmax(scale_base + 0.6 * sin(2 * pi * (t + 5) / 365), 0.1)
  amt <- ifelse(is_wet, rgamma(length(t), shape = shape, scale = scale_t), 0)
  round(amt, 1) # one decimal place
}

## -----------------------
## Simulate data by city
## -----------------------
make_city <- function(city) {
  data.frame(
    city      = rep(city, ndays),
    date      = format(dates, "%Y-%m-%d"),                 # keep as character on purpose
    t_mean_c  = temp_curve(city, t_index),
    rain_mm   = rain_curve(city, t_index),
    stringsAsFactors = FALSE
  )
}

df <- do.call(rbind, lapply(cities, make_city))

## -----------------------
## Inject mild data-quality issues
## -----------------------
# 1) Add leading/trailing whitespace for ~3% of rows
n_whitespace <- round(0.03 * nrow(df))
idx_ws <- sample(seq_len(nrow(df)), n_whitespace)
spaces <- sample(c(" ", "  ", "\t"), n_whitespace, replace = TRUE)

# randomly add to left or right
left_or_right <- sample(c("L","R"), n_whitespace, replace = TRUE)
df$city[idx_ws] <- ifelse(left_or_right == "L",
                          paste0(spaces, df$city[idx_ws]),
                          paste0(df$city[idx_ws], spaces))

# 2) Inconsistent case for ~2% of rows (e.g. "london", "MANCHESTER")
n_case <- round(0.02 * nrow(df))
idx_case <- sample(setdiff(seq_len(nrow(df)), idx_ws), n_case)
case_map <- sample(c("lower", "upper"), n_case, replace = TRUE)
df$city[idx_case] <- ifelse(case_map == "lower",
                            tolower(df$city[idx_case]),
                            toupper(df$city[idx_case]))

# Shuffle rows to avoid perfect city/date blocks
df <- df[sample(seq_len(nrow(df))), ]
row.names(df) <- NULL

## -----------------------
## Write CSV
## -----------------------
outfile <- "R_ignore/non_package_data/weather_raw.csv"

# If writing to a specific project folder, use:
# write.csv(df, file = file.path(out_dir, outfile), row.names = FALSE)
write.csv(df, file = outfile, row.names = FALSE)

