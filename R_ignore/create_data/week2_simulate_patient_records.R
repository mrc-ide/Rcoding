# week2_simulate_patient_records.R
#
# Author: Bob Verity
# Date: 2025-09-29
#
# Inputs: (none)
#
# Saved files:
#   - data/patient_records.rda
#
# Purpose:
#   Generate a synthetic patient line list for teaching examples:
#     - 150 patients with unique alphanumeric IDs
#     - Demographics: age, sex, ethnicity
#     - Anthropometrics: height (cm), weight (kg)
#     - Behavioural/biological attributes: smoker status, marker positivity
#     - Values simulated from plausible probability distributions:
#         * Age skewed towards younger adults but includes elderly
#         * Height normally distributed by sex
#         * Weight correlated with height plus variation
#         * Ethnicity sampled with unequal probabilities
#         * Logical variables drawn from realistic prevalence rates
#
# ------------------------------------------------------------------

library(tidyverse)
library(here)

set.seed(123)  # for reproducibility

n <- 150  # number of patients

# IDs: alphanumeric strings
ids <- paste0("ID", sprintf("%04d", 1:n))

# Age: skewed distribution, more younger adults but include elderly
age <- round(rgamma(n, shape = 6, scale = 6))  # mean ~36
age[age > 90] <- sample(60:90, sum(age > 90), replace = TRUE)  # trim extreme

# Sex: binary
sex <- sample(c("Male", "Female"), size = n, replace = TRUE, prob = c(0.48, 0.52))

# Height (cm): normal distribution conditional on sex
ht_cm <- ifelse(sex == "Male",
                round(rnorm(n, mean = 175, sd = 7)),
                round(rnorm(n, mean = 162, sd = 6)))

# Simulate BMI: normal distribution, mean around 24, sd ~4
# (trim extremes to avoid implausible values)
BMI <- rnorm(n, mean = 24, sd = 4)
BMI[BMI < 15] <- 15
BMI[BMI > 40] <- 40

# Calculate weight (kg) from height (m) and BMI
wt_kg <- round(BMI * (ht_cm / 100) ^ 2)


# Ethnicity: categorical
ethnicity_levels <- c("White", "Asian", "Black_Caribbean",
                      "Black_African", "Mixed", "Other")
ethnicity <- sample(ethnicity_levels, size = n, replace = TRUE,
                    prob = c(0.6, 0.15, 0.07, 0.07, 0.06, 0.05))

# Logical attributes: smoker status (higher in middle-aged)
smoker <- rbinom(n, 1, prob = pmin(0.05 + 0.002 * age, 0.4)) == 1

# Build data frame
patient_records <- data.frame(
  ids = ids,
  age = age,
  sex = sex,
  ht_cm = ht_cm,
  wt_kg = wt_kg,
  ethnicity = ethnicity,
  smoker = smoker,
  stringsAsFactors = FALSE
) |>
  mutate(sex = factor(sex, levels = c("Male", "Female")))

# Preview
head(patient_records)

# Save into data/ folder of package using here()
save(patient_records, file = here("data", "patient_records.rda"))
