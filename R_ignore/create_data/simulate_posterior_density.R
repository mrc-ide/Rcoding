# simulate_posterior_density.R
#
# Author: Bob Verity
# Date: 2025-10-06
#
# Inputs: (none)
#
# Outputs:
#   - R_ignore/non_package_data/posterior_density.rds
#
# Purpose:
#   Simulate posterior-like draws using a mixture of bivariate normal
#   components, compute a 2D KDE on a fixed regular grid (-5 to 5 in x/y),
#   and save as a list:
#     $x : numeric vector of x grid coordinates
#     $y : numeric vector of y grid coordinates
#     $z : numeric matrix of kernel densities (length(y) rows × length(x) cols)
#
# ------------------------------------------------------------------

set.seed(404)

library(MASS)
library(here)

## ---------------------------
## 1) Simulate mixture draws
## ---------------------------

# Mixture weights (sum to 1)
w <- c(0.45, 0.35, 0.20)

# Component means (2D)
mu1 <- c(0.0,  0.0)
mu2 <- c(2.0,  1.5)
mu3 <- c(-1.5, 2.5)

# Component covariance matrices
Sigma1 <- matrix(c(1.0,  0.6,
                   0.6,  1.2), nrow = 2, byrow = TRUE)
Sigma2 <- matrix(c(0.8, -0.3,
                   -0.3,  0.6), nrow = 2, byrow = TRUE)
Sigma3 <- matrix(c(0.5,  0.0,
                   0.0,  0.9), nrow = 2, byrow = TRUE)

# Number of total draws (posterior-like samples)
N <- 8000

# Allocate per component
n1 <- round(w[1] * N)
n2 <- round(w[2] * N)
n3 <- N - n1 - n2

# Draws
X1 <- MASS::mvrnorm(n = n1, mu = mu1, Sigma = Sigma1)
X2 <- MASS::mvrnorm(n = n2, mu = mu2, Sigma = Sigma2)
X3 <- MASS::mvrnorm(n = n3, mu = mu3, Sigma = Sigma3)

draws <- rbind(X1, X2, X3)
colnames(draws) <- c("x", "y")

## ---------------------------
## 2) KDE on a regular grid
## ---------------------------
# Fix limits from -5 to 5 in both x and y
xlim <- c(-5, 5)
ylim <- c(-5, 5)

# Grid resolution (n x n)
n_grid <- 150

# MASS::kde2d returns list(x, y, z)
kde <- MASS::kde2d(
  x = draws[, "x"],
  y = draws[, "y"],
  n = n_grid,
  lims = c(xlim, ylim)
)

# kde$x : vector of x grid values (length n_grid)
# kde$y : vector of y grid values (length n_grid)
# kde$z : matrix [length(y) rows, length(x) cols] of densities

## ---------------------------
## 3) Save as list (x, y, z)
## ---------------------------
kde_list <- list(
  mu = kde$x,
  sigma = kde$y,
  posterior_density = kde$z
)

## ---------------------------
## (Optional) quick visual check
## ---------------------------
image(kde_list$mu, kde_list$sigma, kde_list$posterior_density, col = topo.colors(200),
      xlab = "x", ylab = "y", main = "2D KDE (posterior-like)")

# save to file
saveRDS(kde_list, file = here::here("R_ignore", "non_package_data", "posterior_density.rds"))
