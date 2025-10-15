# ------------------------------------------------------------------
#' Weekly cases by age group (matrix)
#'
#' Synthetic weekly case counts by 5-year age bands over five years.
#' Rows represent age groups \code{"0-4"}, \code{"5-9"}, …, \code{"95-99"}.
#' Columns represent weeks \code{"Week_001"} … \code{"Week_260"}.
#'
#' @format An integer matrix with 20 rows (age groups) and 260 columns (weeks).
#' Row names are age bands; column names are week labels.
#'
#' @source Simulated for the Rcoding package (teaching example).
#'
#' @examples
#' dim(incidence_weekly_age)
#' rownames(incidence_weekly_age)[1:5]
#' colSums(incidence_weekly_age)[1:6]  # weekly totals
"incidence_weekly_age"

# ------------------------------------------------------------------
#' Weekly total case counts (vector)
#'
#' Synthetic weekly total case counts across all age groups for five years
#' (260 weeks). Values correspond to the column sums of
#' \code{incidence_weekly_age}.
#'
#' @format An integer vector of length 260 (one value per week).
#'
#' @source Simulated for the Rcoding package (teaching example).
#'
#' @examples
#' length(incidence_weekly)
#' all.equal(incidence_weekly, colSums(incidence_weekly_age))
"incidence_weekly"

# ------------------------------------------------------------------
#' Patient records
#'
#' A synthetic patient-level dataset containing demographic, anthropometric, and
#' lifestyle information for 150 individuals. This dataset is designed for
#' practising data.frame manipulation, plotting, and simple epidemiological
#' calculations. Column names are deliberately messy.
#'
#' @format A data frame with 150 rows (patients) and 7 variables:
#' \describe{
#'   \item{ids}{Patient ID, character string (e.g. \code{"ID0001"}).}
#'   \item{age}{Age in years, integer.}
#'   \item{sex}{Sex, factor with levels \code{"Male"} and \code{"Female"}.}
#'   \item{ht_cm}{Height in centimetres, integer.}
#'   \item{wt_kg}{Weight in kilograms, integer.}
#'   \item{ethnicity}{Self-reported ethnicity, character string.}
#'   \item{smoker}{Logical, \code{TRUE} if the patient is a current smoker.}
#' }
#'
#' @source Simulated for the Rcoding package (teaching example).
#'
#' @examples
#' head(patient_records)
#' table(patient_records$sex)
#' mean(patient_records$wt_kg / (patient_records$ht_cm / 100)^2)  # mean BMI
"patient_records"

# ------------------------------------------------------------------
#' Smoking analysis list
#'
#' A bundled list object containing a synthetic dataset of smoking prevalence
#' and lung cancer incidence, summary statistics, and the result of fitting a
#' simple linear regression. This object is designed to practise working with
#' lists, nested objects, and model outputs.
#'
#' @format A list with three elements:
#' \describe{
#'   \item{data}{A data frame with 110 rows and 2 variables:
#'     \code{smoking_prev} (smoking prevalence, %) and
#'     \code{lung_cancer_incidence} (incidence per 100k).}
#'   \item{summary_stats}{A named numeric vector giving mean, standard deviation,
#'     minimum, and maximum of each variable.}
#'   \item{fit}{An \code{lm} object from fitting
#'     \code{lung_cancer_incidence ~ smoking_prev}.}
#' }
#'
#' @source Simulated for the Rcoding package (teaching example).
#'
#' @examples
#' names(smoking_analysis_list)
#' head(smoking_analysis_list$data)
#' coef(smoking_analysis_list$fit)
#' plot(smoking_analysis_list$data$smoking_prev,
#'      smoking_analysis_list$data$lung_cancer_incidence)
#' abline(smoking_analysis_list$fit, col = 2, lty = 2)
"smoking_analysis_list"

# ------------------------------------------------------------------
#' Weekly prevalence data for two districts
#'
#' A synthetic dataset of weekly outbreak surveillance data from two districts.
#' Each district has its own sample size, baseline prevalence, and coverage
#' period, but both share an underlying seasonal pattern. Dates are represented
#' only by year and ISO week (no calendar dates).
#'
#' @format A list with two elements, \code{A} and \code{B}, each a data frame with:
#' \describe{
#'   \item{year}{Calendar year (integer).}
#'   \item{week}{ISO week number (1–52, integer).}
#'   \item{tested_X}{Number of individuals tested (integer), where \code{X} is
#'   \code{"A"} or \code{"B"} depending on the district.}
#'   \item{cases_X}{Number of positive cases (integer), where \code{X} is
#'   \code{"A"} or \code{"B"} depending on the district.}
#' }
#'
#' @source Simulated for the Rcoding package (teaching example).
#'
#' @examples
#' names(district_weekly_list)
#' head(district_weekly_list$A)
#' head(district_weekly_list$B)
#' mean(district_weekly_list$A$cases_A / district_weekly_list$A$tested_A, na.rm = TRUE)
"district_weekly_list"

# ------------------------------------------------------------------
#' Allele frequency matrix (loci × samples)
#'
#' A synthetic dataset of allele frequency estimates across multiple loci and
#' samples. Values are simulated from per-locus base frequencies with added
#' sample-level noise, then perturbed by artefacts and structured missingness to
#' mimic realistic genetic data challenges.
#'
#' Rows correspond to loci (\code{"locus_0001"}, \code{"locus_0002"}, …);
#' columns correspond to samples (\code{"sample_001"}, \code{"sample_002"}, …).
#'
#' Features include:
#' \itemize{
#'   \item True allele frequencies in the range (0,1), with variation across loci and samples.
#'   \item Occasional negative values (< 0) introduced to represent artefacts from
#'         lab-based normalisation/calibration errors.
#'   \item Structured missingness: some loci fail across many samples, and some
#'         samples fail across many loci, in addition to random background NAs.
#' }
#'
#' @format A numeric matrix with 300 rows (loci) and 200 columns (samples).
#' Row names are locus IDs; column names are sample IDs.
#'
#' @source Simulated for the \emph{Rcoding} package (teaching example).
#'
#' @examples
#' dim(allele_freq_matrix)
#' allele_freq_matrix[1:5, 1:5]
#' sum(is.na(allele_freq_matrix))       # total missing values
#' sum(allele_freq_matrix < 0, na.rm=TRUE)  # count of artefacts
"allele_freq_matrix"
