library(survival) 
library(survminer) 

colon <- readRDS("01_RAW_DATA/colon_os.rds")

#KM plot by treatment
fit_rx <- survfit(
  Surv(time, status) ~ rx,
  data = colon
)

km_rx <- ggsurvplot(
  fit_rx,
  data = colon,
  pval = TRUE,
  conf.int = TRUE,
  risk.table = TRUE,
  title = "Overall Survival by Treatment Group",
  xlab = "Time (days)",
  ylab = "Overall survival probability",
  palette = c("#333333", "#0072B2", "#D55E00")
)

png(
  "03_OUTPUTS/figures/km_by_treatment.png",
  width = 2400,
  height = 2100,
  res = 300
)

print(km_rx)

dev.off()

#KM plot by sex
colon$sex_label <- factor(
  colon$sex,
  levels = c(0, 1),
  labels = c("Female", "Male")
)

fit_sex <- survfit(
  Surv(time, status) ~ sex_label,
  data = colon
)

km_sex <- ggsurvplot(
  fit_sex,
  data = colon,
  pval = TRUE,
  title = "Overall Survival by Sex",
  xlab = "Time (days)",
  ylab = "Overall survival probability"
)

ggsave(
  "03_OUTPUTS/figures/km_by_sex.png",
  plot = km_sex$plot,
  width = 8,
  height = 6,
  dpi = 300
)

#KM plot by age
colon$age_group <- factor(
  ifelse(colon$age >= 60, "Age >= 60", "Age < 60"),
  levels = c("Age < 60", "Age >= 60")
)

fit_age <- survfit(
  Surv(time, status) ~ age_group,
  data = colon
)

km_age <- ggsurvplot(
  fit_age,
  data = colon,
  pval = TRUE,
  title = "Overall Survival by Age Group",
  xlab = "Time (days)",
  ylab = "Overall survival probability"
)

ggsave(
  "03_OUTPUTS/figures/km_by_age.png",
  plot = km_age$plot,
  width = 8,
  height = 6,
  dpi = 300
)
