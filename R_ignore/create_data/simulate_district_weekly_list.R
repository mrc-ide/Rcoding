# simulate_district_weekly_list.R
#
# Author: Bob Verity
# Date: 2025-09-30
#
# Inputs: (none)
#
# Saved files:
#   - data/district_weekly_list.rda
#
# Purpose:
#   Generate synthetic weekly outbreak surveillance data for two districts:
#     - Each district has cases and tests recorded weekly
#     - Data include numeric year and ISO week only (no full Date)
#     - Districts share a seasonal pattern but differ in sample size and baseline
#     - Column names are district-specific so merges automatically use
#       year and week as keys
#
# ------------------------------------------------------------------

library(here)
library(dplyr)

set.seed(321)

## Helper to simulate one district (generic columns)
simulate_district <- function(start_year, n_years, mean_tested, baseline) {
  n_weeks <- n_years * 52
  years <- rep(start_year:(start_year + n_years - 1), each = 52)
  weeks <- rep(1:52, times = n_years)

  # Seasonal prevalence pattern with a strong and weak peak
  t <- seq_len(n_weeks)
  prevalence <- baseline +
    0.05 * sin(2 * pi * t / 52) +
    0.03 * sin(4 * pi * t / 52)

  tested <- rpois(n_weeks, lambda = mean_tested)
  cases <- rbinom(n_weeks, size = tested, prob = pmin(pmax(prevalence, 0), 1))

  data.frame(
    year = years,
    week = weeks,
    tested = tested,
    cases = cases
  )
}

# District A: 5 years, larger sample size
district_A <- simulate_district(start_year = 2015, n_years = 5,
                                mean_tested = 500, baseline = 0.08) %>%
  rename(tested_A = tested, cases_A = cases)

# District B: 4 years, smaller sample size
district_B <- simulate_district(start_year = 2016, n_years = 4,
                                mean_tested = 300, baseline = 0.05) %>%
  rename(tested_B = tested, cases_B = cases)

# Bundle into a list
district_weekly_list <- list(A = district_A, B = district_B)

# Quick check plot (optional)
plot(district_A$week + (district_A$year - 2015) * 52,
     district_A$cases_A / district_A$tested_A, type = "l", col = "blue",
     ylab = "Prevalence", xlab = "Week index")
lines(district_B$week + (district_B$year - 2015) * 52,
      district_B$cases_B / district_B$tested_B, col = "red")

# Save
save(district_weekly_list,
     file = here("data", "district_weekly_list.rda"),
     compress = "bzip2")
