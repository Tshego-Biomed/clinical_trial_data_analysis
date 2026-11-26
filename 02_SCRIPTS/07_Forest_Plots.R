library(survival)
library(forestplot)

cox_model2 <- readRDS(
  "03_OUTPUTS/tables/cox_model.rds"
)

model_summary <- summary(cox_model2)

hr <- exp(coef(cox_model2))
ci <- exp(confint(cox_model2))
p_values <- model_summary$coefficients[, "Pr(>|z|)"]

variable_labels <- c(
  "Levamisole vs observation",
  "Levamisole + 5-FU vs observation",
  "Age: per additional year",
  "Male vs female",
  "Positive nodes: per additional node"
)

label_text <- rbind(
  c("Variable", "HR (95% CI)", "P-value"),
  cbind(
    variable_labels,
    sprintf("%.2f (%.2f–%.2f)", hr, ci[, 1], ci[, 2]),
    format.pval(p_values, digits = 3, eps = 0.001)
  )
)

png(
  "03_OUTPUTS/figures/forest_plot.png",
  width = 2700,
  height = 1500,
  res = 300
)

forest_figure <- forestplot(
  labeltext = label_text,
  mean = c(NA, hr),
  lower = c(NA, ci[, 1]),
  upper = c(NA, ci[, 2]),
  is.summary = c(TRUE, rep(FALSE, length(hr))),
  zero = 1,
  xlog = TRUE,
  xlab = "Hazard ratio (log scale)",
  txt_gp = fpTxtGp(
    label = grid::gpar(cex = 0.8)
  )
)

print(forest_figure)

dev.off()
