
# Rcoding

**Rcoding** is a teaching package developed for the R Coding Support Sessions as part of the MSc in Epidemiology. Its purpose is to provide synthetic datasets that students can use to practice coding skills in R, from basic manipulation to more advanced workflows.

All datasets are **fictional** and generated purely for teaching purposes.  

---

## Installation

You can install the package directly from GitHub:

```r
# install.packages("remotes")
remotes::install_github("mrc-ide/Rcoding@v1.0.0")
```

When installing the package, remember to set the specific version number using the @ symbol, as shown above. This will ensure you're using the correct version for your teaching material.

## Available Data Objects

- **incidence_weekly_age**: weekly case counts by 5-year age bands over five years (matrix).
- **incidence_weekly**: total weekly case counts across all age groups (vector).
- **patient_records**: synthetic patient line-list with demographics, anthropometrics, and smoking status (data frame).
