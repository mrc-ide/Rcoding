# simulate_dengue_rainfall.R
#
# Simulate weekly rainfall and dengue cases with a true lag
# suitable for cross-correlation analysis and modelling.
#
# - Time: 3 years of weekly data (156 weeks)
# - Rainfall: seasonal + random variation
# - Dengue cases: NegBin with log-mean depending on lagged rainfall
# - True lag: 3 weeks (adjustable via true_lag)
#
# Output: data.frame with columns:
#   year, week, t (week index), rainfall_mm, dengue_cases
#
# Write to CSV at the end.

library(here)

set.seed(20251004)

## ---------------------------
## Parameters (tweak as needed)
## ---------------------------
n_years   <- 3
weeks_per <- 52
n_weeks   <- n_years * weeks_per

true_lag  <- 3        # weeks: biologically plausible rainfall -> mosquito -> dengue
beta0     <- -0.2     # intercept on log-scale
beta1     <- 0.045    # effect of lagged rainfall on log mean cases
theta     <- 12       # NegBin size (higher = less overdispersion)

# Seasonal rainfall parameters
rain_base <- 20       # baseline mm/week
rain_amp  <- 18       # amplitude of seasonal cycle
rain_sd   <- 10       # random weekly noise (mm)

## ---------------------------
## Construct weekly time index
## ---------------------------
t     <- seq_len(n_weeks)
week  <- (t - 1) %% weeks_per + 1
year0 <- 2022
year  <- year0 + (t - 1) %/% weeks_per

## ---------------------------
## Simulate rainfall (mm/week)
## ---------------------------
# Smooth annual cycle + noise; ensure non-negative
rain_seasonal <- rain_base +
  rain_amp * sin(2 * pi * (t - 10) / weeks_per)  # peak around mid-year
rain_noise    <- rnorm(n_weeks, mean = 0, sd = rain_sd)

rainfall_mm   <- pmax(rain_seasonal + rain_noise, 0)

## ---------------------------
## Build lagged rainfall driver
## ---------------------------
# Use a single discrete lag (true_lag). For t <= true_lag, set driver small.
rain_lagged <- c(rep(0, true_lag), rainfall_mm[1:(n_weeks - true_lag)])

## ---------------------------
## Generate dengue cases
## ---------------------------
# Mean cases via log-link:
#   log(mu_t) = beta0 + beta1 * rain_lagged_t
mu <- exp(beta0 + beta1 * rain_lagged)

# Negative binomial draws with mean mu and size theta
# Parameterisation: variance = mu + mu^2/theta
dengue_cases <- rnbinom(n_weeks, size = theta, mu = mu)

## ---------------------------
## Bundle into a data frame
## ---------------------------
dengue_df <- data.frame(
  year         = year,
  week         = week,
  t            = t,
  rainfall_mm  = round(rainfall_mm, 1),
  dengue_cases = dengue_cases
)

## ---------------------------
## (Optional) quick sanity plots
## ---------------------------
# Uncomment to eyeball the series
oldpar <- par(mfrow = c(2,1), mar = c(3,4,2,1))
plot(t, rainfall_mm, type = "l", xlab = "Week", ylab = "Rainfall (mm)",
     main = "Weekly Rainfall")
plot(t, dengue_cases, type = "h", xlab = "Week", ylab = "Dengue cases",
     main = paste0("Dengue Cases (true lag = ", true_lag, " weeks)"))
par(oldpar)

## ---------------------------
## Write to CSV
## ---------------------------
write.csv(
  dengue_df,
  file = here("R_ignore", "non_package_data", "rainfall_dengue.csv"),
  row.names = FALSE
)

