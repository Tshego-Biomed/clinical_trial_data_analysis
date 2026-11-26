# Load data
colon <- readRDS("01_RAW_DATA/colon_os.rds") 

cat("dimensions:", dim(colon), "\n")
cat("Varibales:", colnames(colon), "\n") 

#First 10 rows
head(colon, 10) 

summary(colon) 

#missing values
colSums(is.na(colon))

summary_table <- data.frame(
  Metric = c(
    "Total Patients",
    "Deaths",
    "Censored",
    "Median Observed Time (days)",
    "Age Range"
  ),
  Value = c(
    nrow(colon),
    sum(colon$status == 1),
    sum(colon$status == 0),
    median(colon$time),
    paste(range(colon$age), collapse = "-")
  )
)

print(summary_table)

write.csv(
  summary_table,
  "03_OUTPUTS/tables/summary_table.csv",
  row.names = FALSE
)
