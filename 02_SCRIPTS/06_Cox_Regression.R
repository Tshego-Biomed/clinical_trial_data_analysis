library(survival)

colon <- readRDS("01_RAW_DATA/colon_os.rds")

model_variables <- c(
  "time", "status", "rx", "age", "sex", "nodes"
)

colon_complete <- colon[
  complete.cases(colon[, model_variables]),
]

cat("Overall-survival patients:", nrow(colon), "\n")
cat("Complete-case patients:", nrow(colon_complete), "\n")
cat("Excluded for missing values:",
    nrow(colon) - nrow(colon_complete), "\n")

# Fit both models to the same patients.
cox_model1 <- coxph(
  Surv(time, status) ~ rx,
  data = colon_complete
)

cox_model2 <- coxph(
  Surv(time, status) ~ rx + age + sex + nodes,
  data = colon_complete
)

print(summary(cox_model1))
print(summary(cox_model2))

print(
  anova(
    cox_model1,
    cox_model2,
    test = "Chisq"
  )
)

# Proportional-hazards diagnostics.
ph_test <- cox.zph(cox_model2)
print(ph_test)

ph_results <- data.frame(
  Term = rownames(ph_test$table),
  ph_test$table,
  row.names = NULL
)

write.csv(
  ph_results,
  "03_OUTPUTS/tables/ph_assumption_results.csv",
  row.names = FALSE
)

png(
  "03_OUTPUTS/figures/ph_diagnostics.png",
  width = 2400,
  height = 1800,
  res = 300
)

par(mfrow = c(2, 2))
plot(ph_test)

dev.off()

# Export full numerical precision.
model_summary <- summary(cox_model2)
confidence_intervals <- exp(confint(cox_model2))

cox_results <- data.frame(
  Variable = names(coef(cox_model2)),
  HR = exp(coef(cox_model2)),
  Lower_CI = confidence_intervals[, 1],
  Upper_CI = confidence_intervals[, 2],
  P_Value = model_summary$coefficients[, "Pr(>|z|)"],
  row.names = NULL
)

write.csv(
  cox_results,
  "03_OUTPUTS/tables/cox_results.csv",
  row.names = FALSE
)

saveRDS(
  cox_model2,
  "03_OUTPUTS/tables/cox_model.rds"
)
