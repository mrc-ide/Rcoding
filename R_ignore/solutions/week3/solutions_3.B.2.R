# plot_results.R
#
# Author: Bob Verity
# Date: 2025-10-03
#
# Inputs:
#   - results/model_output.rds
#
# Outputs:
#   - figures/ts_observed_fitted.jpg
#   - figures/effect_curve_rainfall.png
#
# Purpose:
#   Load saved model output, generate two clear figures,
#   and save them as image files (demonstrating both .png and .pdf).
#
# ------------------------------------------------------------------

library(here)

# 1) Load model outputs ------------------------------------------------
mo <- readRDS(here("results", "model_output.rds"))
mo <- model_output

# Only pull out what we need
dat_model   <- mo$data
fitted_values         <- mo$fitted_values
pred_grid   <- mo$pred_grid

# 2) Plot: Observed time series with fitted line ----------------------
png(
  filename = here("figures", "observed_fitted.png"),
  width = 1200, height = 800, res = 150
)

plot(mo$data$t, mo$data$dengue_cases,
     type = "h", col = "grey40",
     ylim = c(0, 20),
     xlab = "Week", ylab = "Dengue cases",
     main = "Dengue time series with fitted mean (Poisson GLM)")

lines(dat_model$t, fitted(fit), col = "red", lwd = 2)

legend("topleft",
       legend = c("Observed cases", "Fitted mean"),
       col = c("grey40", "red"),
       lty = c(1,1), lwd = c(1,2), bty = "n")

dev.off()


# 3) Plot: Effect curve (rainfall -> dengue) --------------------------
pdf(
  file = here("figures", "effect_curve_rainfall.pdf"),
  width = 8, height = 6
)

plot(dat_model$rain_lag, dat_model$dengue_cases,
     xlab = "Lagged rainfall (mm)",
     ylab = "Dengue cases",
     main = "Effect of lagged rainfall on dengue (with GLM curve)")

lines(pred_grid$rain_lag, pred_grid$mu, col = "red", lwd = 2)

legend("topleft",
       legend = c("Observed pairs", "GLM mean"),
       col = c("black", "red"),
       pch = c(1, NA),
       lty = c(NA, 1),
       lwd = c(NA, 2))

dev.off()
