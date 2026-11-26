library(survival)
colon <- readRDS("01_RAW_DATA/colon_os.rds")

#Survival Object

surv_object<- Surv(time = colon$time, event = colon$status)

#KM curve
fit_overall<- survfit(surv_object ~ 1) 
summary(fit_overall) 

#median
fit_overall

#KM curve by treatment
fit_rx<- survfit(Surv(time, status) ~ rx, data= colon) 
summary(fit_rx) 

#median
fit_rx

#survival probabilities
three_yrs <- summary(fit_overall,times = 1095)
print(three_yrs)
five_yrs <- summary(fit_rx,times = 1825)
print(five_yrs) 


#results table
median_table<- summary(fit_rx)$table
print(median_table)

survival_results <- data.frame(
  Group = rownames(median_table),
  Median_Survival = median_table[, "median"],
  Lower_CI = median_table[, "0.95LCL"],
  Upper_CI = median_table[, "0.95UCL"]
)
print(survival_results)
survival_results$Median_Interpretation <- ifelse(
  is.na(survival_results$Median_Survival),
  "Not reached during observed follow-up",
  paste(
    round(survival_results$Median_Survival),
    "days"
  )
)
write.csv(survival_results,"03_OUTPUTS/tables/survival_results.csv", row.names= FALSE) 

