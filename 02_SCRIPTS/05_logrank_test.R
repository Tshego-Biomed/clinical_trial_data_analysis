library(survival) 
colon <- readRDS("01_RAW_DATA/colon_os.rds")

logrank_rx<- survdiff(Surv(time, status) ~ rx, data= colon) 
print(logrank_rx) 

p_val_rx <- pchisq(
  logrank_rx$chisq,
  df = nlevels(droplevels(colon$rx)) - 1,
  lower.tail = FALSE
)
cat("Treatment p-value:", p_val_rx, "\n") 

#log-rank test for sex
logrank_sex <- survdiff(Surv(time, status) ~ sex, data = colon)
print(logrank_sex)

p_value_sex <- pchisq(
  logrank_sex$chisq,
  df = length(unique(na.omit(colon$sex))) - 1,
  lower.tail = FALSE
)
cat("Sex p-value:", p_value_sex, "\n")

#Stratified Analysis by Sex
logrank_strat<- survdiff(Surv(time, status) ~ rx + strata(sex), data= colon) 
print(logrank_strat)

p_value_strat <- pchisq(
  logrank_strat$chisq,
  df = nlevels(droplevels(colon$rx)) - 1,
  lower.tail = FALSE
)
#Subgroup Analysis
subgroup_test<- function(data, sex_filter){
  sub_data<- data[data$sex == sex_filter,]
  survdiff(Surv(time, status) ~ rx, data= sub_data) 
}
cat("\nMale patients:\n")
print(subgroup_test(colon,1))

cat("\nFemale patients:\n")
print(subgroup_test(colon, 0)) 

logrank_results <- data.frame(
  Test = c(
    "Treatment",
    "Sex",
    "Treatment stratified by sex"
  ),
  Chi_Square = c(
    logrank_rx$chisq,
    logrank_sex$chisq,
    logrank_strat$chisq
  ),
  P_Value = c(
    p_val_rx,
    p_value_sex,
    p_value_strat
  )
)

write.csv(logrank_results, "03_OUTPUTS/tables/logrank_results.csv", row.names= FALSE) 


