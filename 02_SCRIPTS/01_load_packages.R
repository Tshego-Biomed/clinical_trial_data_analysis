library(survival)
library(survminer)
library(forestplot)
library(dplyr)
library(ggplot2)

dir.create("01_RAW_DATA", showWarnings = FALSE)

dir.create(
  "03_OUTPUTS/tables",
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  "03_OUTPUTS/figures",
  recursive = TRUE,
  showWarnings = FALSE
)

# Load the original dataset supplied with survival.
colon_raw <- survival::colon

# Preserve the full dataset.
saveRDS(
  colon_raw,
  "01_RAW_DATA/colon_data.rds"
)

# Select death records for overall-survival analysis.
colon_os <- colon_raw %>%
  filter(etype == 2)

# Confirm one record per patient.
stopifnot(
  !anyDuplicated(colon_os$id),
  all(colon_os$status %in% c(0, 1))
)

# Make the treatment reference explicit.
colon_os$rx <- factor(
  colon_os$rx,
  levels = c("Obs", "Lev", "Lev+5FU")
)

saveRDS(
  colon_os,
  "01_RAW_DATA/colon_os.rds"
)

cat("Overall-survival patients:", nrow(colon_os), "\n")
cat("Deaths:", sum(colon_os$status == 1), "\n")
cat("Censored:", sum(colon_os$status == 0), "\n")
