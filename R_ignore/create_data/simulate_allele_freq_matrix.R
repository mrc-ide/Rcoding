# simulate_allele_freq_matrix.R
#
# Author: Bob Verity
# Date: 2025-10-01
#
# Inputs: (none)
#
# Saved files:
#   - data/allele_freq_matrix.rda
#
# Purpose:
#   Simulate a loci x samples allele-frequency matrix for cleaning practice:
#     - 300 loci x 200 samples
#     - Per-locus base frequency ~ Beta
#     - Add Normal noise on the logit scale, then inverse-logit back to (0,1)
#     - Inject scattered normalisation artefacts producing values < 0
#     - Structured missingness (bad loci/samples) + background NAs
#
# ------------------------------------------------------------------

set.seed(1)

# Dimensions
n_loci    <- 300
n_samples <- 200

# Handy logit / inverse-logit
logit     <- function(p) log(p / (1 - p))
inv_logit <- function(x) 1 / (1 + exp(-x))

# --- Per-locus base frequency -----------------------------------------------
# e.g., some loci common, others rare
loc_base <- rbeta(n_loci, shape1 = 1, shape2 = 6)  # in (0,1)

# --- Add sample-level noise on the logit scale -------------------------------
# Convert per-locus base p to logit, add per-sample Normal noise, transform back
sample_noise <- rnorm(n_samples, mean = 0, sd = 0.25)

# Broadcast: for each locus i and sample j:
# logit(p_ij) = logit(loc_base[i]) + sample_noise[j]
allele_freq_matrix <- outer(logit(loc_base), sample_noise, `+`)
allele_freq_matrix <- inv_logit(allele_freq_matrix)  # back to (0,1)

# Name rows/cols for readability
rownames(allele_freq_matrix) <- paste0("locus_",  sprintf("%04d", seq_len(n_loci)))
colnames(allele_freq_matrix) <- paste0("sample_", sprintf("%03d", seq_len(n_samples)))

# --- Inject scattered normalisation artefacts (< 0) --------------------------
# A small proportion of sample–locus cells become negative due to background
# subtraction / calibration glitches
n_artifacts <- round(0.01 * n_loci * n_samples)  # ~1% cells affected
idx_art     <- cbind(
  sample(seq_len(n_loci),    size = n_artifacts, replace = TRUE),
  sample(seq_len(n_samples), size = n_artifacts, replace = TRUE)
)
allele_freq_matrix[idx_art] <- -runif(n_artifacts, 0.00, 0.10)  # values in (-0.10, 0)

# Quick checks
range(allele_freq_matrix)
image(allele_freq_matrix)

# --- Inject structured missingness (NAs) -------------------------------------
prop_bad_loci    <- 0.10   # 10% loci with high failure
prop_bad_samples <- 0.10   # 10% samples with high failure

bad_loci    <- sample(seq_len(n_loci),    size = round(prop_bad_loci    * n_loci),    replace = FALSE)
bad_samples <- sample(seq_len(n_samples), size = round(prop_bad_samples * n_samples), replace = FALSE)

p_na_bad_locus  <- 0.45    # within bad loci, 45% missing across samples
p_na_bad_sample <- 0.35    # within bad samples, 45% missing across loci
p_na_background <- 0.03    # background NAs everywhere

# Start with background missingness
is_na <- matrix(runif(n_loci * n_samples) < p_na_background,
                nrow = n_loci, ncol = n_samples)

# Add locus-driven missingness
if (length(bad_loci) > 0) {
  is_na[bad_loci, ] <- is_na[bad_loci, ] |
    (matrix(runif(length(bad_loci) * n_samples),
            nrow = length(bad_loci)) < p_na_bad_locus)
}

# Add sample-driven missingness
if (length(bad_samples) > 0) {
  is_na[, bad_samples] <- is_na[, bad_samples] |
    (matrix(runif(n_loci * length(bad_samples)),
            nrow = n_loci) < p_na_bad_sample)
}

# Apply missingness
allele_freq_matrix[is_na] <- NA_real_

# --- Optional quick checks ----------------------------------------------------
mean(allele_freq_matrix < 0, na.rm = TRUE)  # check negatives present
hist(rowSums(is.na(allele_freq_matrix)) / ncol(allele_freq_matrix))
hist(colSums(is.na(allele_freq_matrix)) / nrow(allele_freq_matrix))
image(t(allele_freq_matrix), xlab = "Sample", ylab = "Loci")

# --- Save to package data/ ----------------------------------------------------
save(allele_freq_matrix,
     file = here::here("data", "allele_freq_matrix.rda"),
     compress = "bzip2")
