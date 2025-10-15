# 3A3_solution_clean_and_write.R
# ------------------------------------------------------------
# Purpose: Import hospital admissions, fix column types,
#          and save a cleaned version (CSV + RDS).
# Assumptions:
#   - You opened the .Rproj at the project root.
#   - The raw file lives in ./data_raw/hospital_admissions.csv
#   - You will create ./data_clean/ manually (as per worksheet).
# ------------------------------------------------------------

## 1) Import --------------------------------------------------
hospital <- read.csv("data_raw/hospital_admissions.csv")

# Quick look
str(hospital)
head(hospital)

## 2) Fix column types ----------------------------------------
# 2.1 age: replace "missing" with NA, then coerce to numeric
hospital$age[hospital$age == "missing"] <- NA
hospital$age <- as.numeric(hospital$age)

# 2.2 icu_flag: "Y"/"N" -> logical TRUE/FALSE via ifelse
hospital$icu_flag <- ifelse(hospital$icu_flag == "Y", TRUE, FALSE)

# 2.3 admit_date, discharge_date: character -> Date (ISO)
hospital$admit_date     <- as.Date(hospital$admit_date,     format = "%Y-%m-%d")
hospital$discharge_date <- as.Date(hospital$discharge_date, format = "%Y-%m-%d")

# 2.4 outcome: character -> factor
hospital$outcome <- as.factor(hospital$outcome)

# Optional: confirm structure now looks correct
str(hospital)
