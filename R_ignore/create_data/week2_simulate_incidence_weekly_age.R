# week2_simulate_incidence_weekly_age.R
#
# Author: Bob Verity
# Date: 2025-09-27
#
# Inputs: (none)
#
# Saved files:
#   - data/incidence_age_by_week.rda
#   - data/incidence_weekly.rda
#
# Purpose:
#   Generate a synthetic dataset of weekly case counts by age group for 5 years:
#     - 260 weeks (5 years × 52 weeks)
#     - 20 age groups (0–4, 5–9, …, 95–99)
#     - Counts simulated as Poisson draws around expectations that:
#         * follow a seasonal pattern with two peaks each year
#         * shift later in older age groups (age-specific delay)
#         * scale according to an exponential age distribution (fewer older people)
#
# ------------------------------------------------------------------

library(here)

set.seed(123)

## ---- Parameters -------------------------------------------------------
years          <- 5L
weeks_per_year <- 52L
n_weeks        <- years * weeks_per_year  # 260
age_breaks <- seq(0, 100, by = 5)         # 0,5,...,100 -> 20 bins
age_mids   <- head(age_breaks, -1) + 2.5
n_age      <- length(age_mids)            # 20

mean_total_cases <- 180  # average total per week

## Seasonality parameters
amp1 <- 0.60   # amplitude for main peak
amp2 <- 0.25   # amplitude for secondary peak
phi1 <- 0.6    # phase shift (radians) for main
phi2 <- 1.1    # phase shift (radians) for secondary

## Age-specific delays and amplitude scaling
max_delay_weeks <- 12
age_delay_weeks <- seq(0, max_delay_weeks, length.out = n_age)

z              <- exp(-age_mids / 80)
z_min          <- min(z)
z_max          <- max(z)
age_amp_scale  <- 0.7 + (z - z_min) * (1.0 - 0.7) / (z_max - z_min)

## ---- Age weights ------------------------------------------------------
age_weights_raw <- exp(-age_mids / 35)
age_weights     <- age_weights_raw / sum(age_weights_raw)

## ---- Time axis & seasonal function -----------------------------------
t <- seq_len(n_weeks)

season_with_delay <- function(t, delay_weeks, amp_scale = 1) {
  s1 <- amp1 * amp_scale * sin(2 * pi * (t - delay_weeks) / weeks_per_year - phi1)
  s2 <- amp2 * amp_scale * sin(4 * pi * (t - delay_weeks) / weeks_per_year - phi2)
  out <- 1 + s1 + s2
  pmax(out, 0.05)
}

season_mat <- matrix(NA_real_, nrow = n_age, ncol = n_weeks)
for (i in seq_len(n_age)) {
  season_mat[i, ] <- season_with_delay(
    t,
    delay_weeks = age_delay_weeks[i],
    amp_scale   = age_amp_scale[i]
  )
}

## ---- Expected counts & simulation ------------------------------------
lambda <- sweep(season_mat, 1, age_weights * mean_total_cases, `*`)
lambda <- pmax(lambda, 0.01)

incidence_weekly_age <- matrix(
  rpois(length(lambda), lambda),
  nrow = n_age, ncol = n_weeks, byrow = FALSE
)

age_labels  <- paste0(head(age_breaks, -1), "-", head(age_breaks, -1) + 4)
week_labels <- sprintf("Week_%03d", t)
rownames(incidence_weekly_age) <- age_labels
colnames(incidence_weekly_age) <- week_labels

incidence_weekly <- colSums(incidence_weekly_age)
names(incidence_weekly) <- NULL

## ---- Save to package data/ -------------------------------------------

save(incidence_weekly_age,
     file = here::here("data", "incidence_weekly_age.rda"),
     compress = "bzip2")

save(incidence_weekly,
     file = here::here("data", "incidence_weekly.rda"),
     compress = "bzip2")
