# simulate_import_data.R
#
# Author: Bob Verity
# Date: 2025-10-02
#
# Outputs (written via here() to R_ignore/non_package_data/):
#   - weekly_cases.rds            (RDS: single data.frame)
#   - weekly_tests.txt            (tab-delimited TXT)
#   - hospital_admissions.csv     (CSV with one "missing" string in age)
#   - misc_objects.RData          (RData with multiple objects)

library(here)
set.seed(1)

# ------------------------------------------------------------
# 1) Weekly cases (RDS): weekly_cases.rds
# ------------------------------------------------------------
years <- 2024:2025
weeks <- 1:52
wk_grid <- expand.grid(year = years, week = weeks)
wk_grid <- wk_grid[order(wk_grid$year, wk_grid$week), ]
n <- nrow(wk_grid)

baseline <- 20
amp1     <- 10
seasonal <- baseline + amp1 * sin(2 * pi * (wk_grid$week) / 52)
cases    <- rpois(n, lambda = pmax(seasonal, 0.1))

weekly_cases <- data.frame(
  year  = wk_grid$year,
  week  = wk_grid$week,
  cases = cases
)

saveRDS(
  weekly_cases,
  file = here("R_ignore", "non_package_data", "weekly_cases.rds")
)

# ------------------------------------------------------------
# 2) Weekly tests (tab-delimited): weekly_tests.txt
#    Ensure tested >= cases
# ------------------------------------------------------------
baseline_tested <- 400
amp_tested      <- 80
seasonal_tested <- baseline_tested + amp_tested * sin(2 * pi * wk_grid$week / 52)
tested_raw      <- rpois(n, lambda = pmax(seasonal_tested, 50))
tested          <- pmax(tested_raw, weekly_cases$cases)

weekly_tests <- data.frame(
  year   = wk_grid$year,
  week   = wk_grid$week,
  tested = tested
)

write.table(
  weekly_tests,
  file = here("R_ignore", "non_package_data", "weekly_tests.txt"),
  sep = "\t", quote = FALSE, row.names = FALSE
)

# ------------------------------------------------------------
# 3) Hospital admissions (CSV): hospital_admissions.csv
#    Mild pitfalls for auto-typing:
#      - patient_id alphanumeric with leading zeros (e.g. "P0001")
#      - admit/discharge dates as ISO character strings (student converts via as.Date)
#      - ONE "missing" string deliberately injected into the age column
#      - icu_flag stored as "Y"/"N" instead of TRUE/FALSE
#    NEW: LOS ~ lognormal with different means for ICU vs non-ICU
# ------------------------------------------------------------
set.seed(300301)  # (or reuse your project seed above)
n_pat <- 250

patient_id <- sprintf("P%04d", seq_len(n_pat))   # "P0001", "P0002", ...

hospitals  <- c("North General", "South Central", "East Wing")
hospital   <- sample(hospitals, size = n_pat, replace = TRUE,
                     prob = c(0.45, 0.35, 0.20))

# ICU flag first (so we can draw LOS conditional on ICU status)
icu_flag <- sample(c("Y", "N"), size = n_pat, replace = TRUE, prob = c(0.12, 0.88))

# Admit dates (as character ISO strings)
adm_start  <- as.Date("2025-01-01")
adm_end    <- as.Date("2025-12-31")
admit_date <- as.Date(runif(n_pat, adm_start, adm_end), origin = "1970-01-01")
admit_date_chr <- format(admit_date, "%Y-%m-%d")

# ------------------------------------------------------------
# Length of stay (days): log-normal–like, different by ICU status
#   For X ~ LogNormal(meanlog=mu, sdlog=sigma):
#     E[X] = exp(mu + sigma^2 / 2)
#   We choose (mu, sigma) to get plausible means and spread.
#   Non-ICU: mean ~ 5 days
#   ICU:     mean ~ 12 days
# ------------------------------------------------------------
# Non-ICU parameters (tweakable)
mu_ward    <- log(5)      # ~ mean ≈ 5 when sdlog moderate
sigma_ward <- 0.5

# ICU parameters (tweakable)
mu_icu     <- log(12)     # ~ mean ≈ 12
sigma_icu  <- 0.6

# Draw LOS by group, round to whole days, and force minimum 1 day
los_days <- numeric(n_pat)
los_days[icu_flag == "Y"] <- pmax(1, round(rlnorm(sum(icu_flag == "Y"),
                                                  meanlog = mu_icu,  sdlog = sigma_icu)))
los_days[icu_flag == "N"] <- pmax(1, round(rlnorm(sum(icu_flag == "N"),
                                                  meanlog = mu_ward, sdlog = sigma_ward)))

# Discharge dates = admit + LOS
discharge_date <- admit_date + los_days
discharge_date_chr <- format(discharge_date, "%Y-%m-%d")

# Age: numeric, but inject EXACTLY one "missing" string (forces char on import)
age_num <- pmin(pmax(round(rnorm(n_pat, mean = 45, sd = 18)), 0), 95)
age_chr <- as.character(age_num)
inj_row <- sample.int(n_pat, size = 1)
age_chr[inj_row] <- "missing"

# Outcome (left as you had it)
outcome  <- sample(c("recovered", "ICU", "died"), n_pat, replace = TRUE,
                   prob = c(0.85, 0.10, 0.05))

hospital_admissions_csv <- data.frame(
  patient_id     = patient_id,       # alphanumeric; Excel-safe
  hospital       = hospital,         # character
  admit_date     = admit_date_chr,   # character ISO; students convert with as.Date
  discharge_date = discharge_date_chr,
  age            = age_chr,          # character because of one "missing"
  icu_flag       = icu_flag,         # "Y"/"N"; students convert manually
  outcome        = outcome,          # character; students may factor
  stringsAsFactors = FALSE
)

write.csv(
  hospital_admissions_csv,
  file = here::here("R_ignore", "non_package_data", "hospital_admissions.csv"),
  row.names = FALSE
)

# ------------------------------------------------------------
# 4) RData with multiple objects: misc_objects.RData
# ------------------------------------------------------------
surveillance_regions <- c("North", "South", "East", "West")

lab_turnaround <- data.frame(
  lab_id      = paste0("LAB", 1:6),
  median_days = sample(1:5, size = 6, replace = TRUE),
  urgent_pct  = round(runif(6, 0.05, 0.30), 2),
  stringsAsFactors = FALSE
)

metadata <- list(
  source        = "Synthetic data for teaching (Week 3)",
  contact       = "teaching-team@example.org",
  created_utc   = format(Sys.time(), tz = "UTC")
)

save(
  surveillance_regions, lab_turnaround, metadata,
  file = here("R_ignore", "non_package_data", "misc_objects.RData")
)

