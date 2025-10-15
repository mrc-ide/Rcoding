
# Rcoding

**Rcoding** is a teaching package developed for the R Coding Support Sessions as part of the MSc in Epidemiology. Its purpose is to provide synthetic datasets that students can use to practice coding skills in R, from basic manipulation to more advanced workflows.

All datasets are **fictional** and generated purely for teaching purposes.  

---

## Installation

You can install the package directly from GitHub:

```r
# install.packages("remotes")
remotes::install_github("mrc-ide/Rcoding@")
```

## Available Data Objects

- **incidence_weekly_age**: weekly case counts by 5-year age bands over five years (matrix).
- **incidence_weekly**: total weekly case counts across all age groups (vector).
- **patient_records**: synthetic patient line-list with demographics, anthropometrics, and smoking status (data frame).

- **incidence_weekly_age** — Weekly case counts by 5-year age bands over five years (matrix).
- **incidence_weekly** — Total weekly case counts across all age groups (vector).
- **patient_records** — Synthetic patient-level dataset with demographic, anthropometric, and lifestyle information for 150 individuals (data frame).
- **smoking_analysis_list** — Bundled list containing synthetic data on smoking prevalence and lung cancer incidence, summary statistics, and a fitted linear model (list).
- **district_weekly_list** — Weekly outbreak surveillance data from two districts, each with distinct sample sizes and coverage periods, sharing a seasonal pattern (list of data frames).
- **allele_freq_matrix** — Synthetic allele-frequency dataset with 300 loci and 200 samples, including artefacts and structured missingness to mimic real genetic data (numeric matrix).
