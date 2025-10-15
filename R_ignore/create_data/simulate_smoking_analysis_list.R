# simulate_smoking_analysis_list.R
#
# Author: Bob Verity
# Date: 2025-09-29
#
# Inputs: (none)
#
# Saved files:
#   - data/smoking_analysis_list.rda
#
# Purpose:
#   Simulate a small dataset suitable for simple linear regression, fit an lm,
#   and package everything into a single list:
#     - data:           data.frame with x ~ y that is approximately linear but imperfect
#     - summary_stats:  simple numeric summaries (means/SDs) for key variables
#     - fit:            lm(y ~ x) object (used to show limitations/diagnostics)
#
# ------------------------------------------------------------------

library(tidyverse)
library(here)

set.seed(42)

## -----------------------
## Simulate "almost-linear" data
## -----------------------
n <- 110

# Explanatory variable (e.g., smoking prevalence, % of population)
x <- sort(runif(n, min = 5, max = 35))

# True signal with small deviations from linearity:
# - slight quadratic curvature
# - mild wavy component
true_mu <- 2 + 0.9 * x + 0.02 * x^2 + 1.2 * sin(2 * pi * x / 25)

# Heteroskedastic noise: variance increases with x
sd_eps <- 3 + 0.15 * x

# Observed response (e.g., lung cancer incidence per 100k)
y <- true_mu + rnorm(n, mean = 0, sd = sd_eps)

# Inject a couple of outliers to make the fit visibly imperfect
out_idx <- sample(seq_len(n), size = 2)
y[out_idx] <- y[out_idx] + c(25, 35)

# Keep values non-negative
y <- pmax(y, 0)

# Assemble data frame
data <- data.frame(
  smoking_prev = x,              # %
  lung_cancer_incidence = y      # per 100k (synthetic)
)

# quick exploratory plot (optional)
data |>
  ggplot(aes(x = smoking_prev, y = lung_cancer_incidence)) +
  geom_point(color = "steelblue") +
  labs(x = "Smoking prevalence (%)",
       y = "Lung cancer incidence (per 100k)",
       title = "Synthetic smoking vs cancer dataset") +
  theme_bw()

## -----------------------
## Summary stats (second element)
## -----------------------
summary_stats <- c(
  smoking_prev_mean           = mean(data$smoking_prev),
  smoking_prev_sd             = sd(data$smoking_prev),
  lung_cancer_incidence_mean  = mean(data$lung_cancer_incidence),
  lung_cancer_incidence_sd    = sd(data$lung_cancer_incidence)
)

## -----------------------
## Fit a simple linear model (third element)
## -----------------------
fit <- lm(lung_cancer_incidence ~ smoking_prev, data = data)

## -----------------------
## Bundle into a single list
## -----------------------
smoking_analysis_list <- list(
  data          = data,
  summary_stats = summary_stats,
  fit           = fit
)

## -----------------------
## Save to package data/
## -----------------------
save(smoking_analysis_list,
     file = here::here("data", "smoking_analysis_list.rda"),
     compress = "bzip2")
