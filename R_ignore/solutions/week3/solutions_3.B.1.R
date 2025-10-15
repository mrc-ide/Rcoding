# clean_data.R
# ------------------------------------------------------------
# Project: week3_weather
# Purpose: Read raw daily weather data, fix simple issues, and
#          write a cleaned version for downstream analysis.
#
# Inputs:
#   - data_raw/weather_raw.csv
#
# Cleaning steps performed:
#   1) Inspect structure; tabulate 'city' to spot issues
#   2) Remove leading/trailing whitespace in 'city'
#   3) Ensure a proper Date column:
#        - if 'date_chr' exists (ISO character), convert to Date
#        - else if 'date' exists and is character, convert in place
#
# Outputs (both formats written for this exercise):
#   - data_clean/weather_clean.csv
#   - data_clean/weather_clean.rds
#
# Notes:
#   In real projects you typically choose ONE storage format.
#   CSV is portable/human-readable; RDS is compact and preserves R classes.
# ------------------------------------------------------------

## Packages ---------------------------------------------------
# install.packages("here") # run once if not installed
library(here)

## 1) Read raw ------------------------------------------------
raw_path <- here("data_raw", "weather_raw.csv")
weather  <- read.csv(raw_path)

## 2) Inspect & spot issues ----------------------------------
str(weather)

table(weather$city)

## 3) Clean 'city': trim whitespace and force uppercase ------
weather$city <- toupper(trimws(weather$city))

table(weather$city)

## 4) Ensure a proper Date column -----------------------------
weather$date <- as.Date(weather$date, format = "%Y-%m-%d")

## 5) Post-clean checks ---------------------------------------
str(weather)

## 6) Write cleaned data (both formats for this exercise) -----
csv_out <- here("data_clean", "weather_clean.csv")
rds_out <- here("data_clean", "weather_clean.rds")

write.csv(weather, csv_out, row.names = FALSE)
saveRDS(weather, rds_out)

