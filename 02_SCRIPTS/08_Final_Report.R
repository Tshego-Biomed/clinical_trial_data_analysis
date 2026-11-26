# Run the complete analysis pipeline.
source("02_SCRIPTS/01_load_packages.R")
source("02_SCRIPTS/02_Data_Inspection.R")
source("02_SCRIPTS/03_Survival_Analysis.R")
source("02_SCRIPTS/04_kaplan_meier.R")
source("02_SCRIPTS/05_logrank_test.R")
source("02_SCRIPTS/06_Cox_Regression.R")
source("02_SCRIPTS/07_Forest_Plots.R")

# Load the analysis data and saved results.
colon <- readRDS("01_RAW_DATA/colon_os.rds")

cox_model2 <- readRDS(
  "03_OUTPUTS/tables/cox_model.rds"
)

survival_results <- read.csv(
  "03_OUTPUTS/tables/survival_results.csv"
)

logrank_results <- read.csv(
  "03_OUTPUTS/tables/logrank_results.csv"
)

ph_results <- read.csv(
  "03_OUTPUTS/tables/ph_assumption_results.csv"
)

# Patient summary.
total_pts <- nrow(colon)
deaths <- sum(colon$status == 1)
censored <- sum(colon$status == 0)
median_age <- median(colon$age)
age_range <- paste(range(colon$age), collapse = "-")

complete_pts <- cox_model2$n
excluded_pts <- total_pts - complete_pts

# Readable Kaplan-Meier medians.
median_display <- ifelse(
  is.na(survival_results$Median_Survival),
  "Not reached during observed follow-up",
  paste(
    round(survival_results$Median_Survival),
    "days"
  )
)

names(median_display) <- survival_results$Group

# Treatment estimate from the saved adjusted model.
model_summary <- summary(cox_model2)

hr_rx <- exp(coef(cox_model2)["rxLev+5FU"])

ci_rx <- exp(
  confint(cox_model2)
)["rxLev+5FU", ]

p_rx <- model_summary$coefficients[
  "rxLev+5FU",
  "Pr(>|z|)"
]

# Log-rank and PH diagnostic p-values.
p_logrank <- logrank_results$P_Value[
  logrank_results$Test == "Treatment"
]

p_stratified <- logrank_results$P_Value[
  logrank_results$Test == "Treatment stratified by sex"
]

p_global <- ph_results$p[
  ph_results$Term == "GLOBAL"
]

# Format only for display; retain full numerical precision above.
p_rx_text <- format.pval(
  p_rx,
  digits = 3,
  eps = 0.0001
)

p_logrank_text <- format.pval(
  p_logrank,
  digits = 3,
  eps = 0.0001
)

p_stratified_text <- format.pval(
  p_stratified,
  digits = 3,
  eps = 0.0001
)

ph_note <- if (p_global < 0.05) {
  paste(
    "The global diagnostic suggests possible non-proportional hazards.",
    "Interpret the constant hazard ratios cautiously and review",
    "the term-specific tests and diagnostic plots."
  )
} else {
  paste(
    "The global diagnostic did not detect evidence of",
    "non-proportional hazards.",
    "This does not prove that the assumption holds;",
    "term-specific tests and plots should also be reviewed."
  )
}

# Generate the text summary from the current results.
summary_text <- sprintf(
  "COLON CANCER OVERALL-SURVIVAL ANALYSIS

1. Dataset
   Overall survival uses death records only (etype = 2).
   Patients: %d
   Deaths: %d
   Censored observations: %d
   Median age: %.0f years (range %s)

2. Kaplan-Meier median survival
   Observation: %s
   Levamisole: %s
   Levamisole + 5-FU: %s

3. Log-rank comparisons
   Overall treatment comparison p-value: %s
   Treatment comparison stratified by sex p-value: %s

4. Adjusted Cox model
   Complete-case patients: %d
   Excluded for missing model variables: %d
   Covariates: treatment, age, sex and positive-node count.

   Levamisole + 5-FU versus observation:
   HR %.2f (95%% CI %.2f-%.2f)
   P-value: %s

   The HR compares the hazard of death, not the probability of dying.
   Values below 1 indicate a lower estimated hazard than observation.

5. Proportional-hazards assessment
   Global diagnostic p-value: %.3f
   %s
   See ph_assumption_results.csv and ph_diagnostics.png.

6. Interpretation and limitations
   Interpret the treatment estimate together with its confidence interval,
   p-value and model diagnostics. This educational reanalysis uses an
   existing historical trial dataset.

   The model assumes linear effects of age and positive-node count on
   the log hazard. Complete-case analysis may introduce selection bias.
   Exploratory subgroup comparisons do not establish treatment-by-sex
   interaction and have not been adjusted for multiple testing.
",
  total_pts,
  deaths,
  censored,
  median_age,
  age_range,
  median_display["rx=Obs"],
  median_display["rx=Lev"],
  median_display["rx=Lev+5FU"],
  p_logrank_text,
  p_stratified_text,
  complete_pts,
  excluded_pts,
  hr_rx,
  ci_rx[1],
  ci_rx[2],
  p_rx_text,
  p_global,
  ph_note
)

writeLines(
  summary_text,
  "03_OUTPUTS/tables/clinical_summary.txt"
)

# R Markdown report.
rmd_content <- c(
  "---",
  'title: "Colon Cancer Overall-Survival Analysis"',
  'author: "Tshegofatso Leope"',
  'output: html_document',
  "---",
  "",
  "## Overview",
  "",
  paste(
    "This beginner portfolio project reanalyses the colon dataset",
    "from the R survival package. Overall survival is analysed",
    "using death records only (etype = 2)."
  ),
  "",
  "## Methods",
  "",
  paste(
    "The workflow uses Kaplan-Meier estimation, log-rank tests",
    "and Cox proportional hazards regression.",
    "The adjusted model includes treatment, age, sex and",
    "the number of positive lymph nodes."
  ),
  "",
  "## Results and interpretation",
  "",
  "```{r summary-text, echo=FALSE}",
  'summary_lines <- readLines("03_OUTPUTS/tables/clinical_summary.txt")',
  'cat(paste(summary_lines, collapse = "\\n"), sep = "\\n")',
  "```",
  "",
  "## Overall survival by treatment",
  "",
  "```{r treatment-figure, echo=FALSE, out.width='100%'}",
  'knitr::include_graphics("03_OUTPUTS/figures/km_by_treatment.png")',
  "```",
  "",
  "## Adjusted Cox estimates",
  "",
  "```{r cox-table, echo=FALSE}",
  'cox_table <- read.csv("03_OUTPUTS/tables/cox_results.csv")',
  'cox_table$P_Value <- format.pval(cox_table$P_Value, digits = 3, eps = 0.0001)',
  'knitr::kable(cox_table, digits = 4)',
  "```",
  "",
  "```{r forest-figure, echo=FALSE, out.width='100%'}",
  'knitr::include_graphics("03_OUTPUTS/figures/forest_plot.png")',
  "```",
  "",
  "## Proportional-hazards diagnostics",
  "",
  "```{r ph-table, echo=FALSE}",
  'ph_table <- read.csv("03_OUTPUTS/tables/ph_assumption_results.csv")',
  'knitr::kable(ph_table, digits = 4)',
  "```",
  "",
  "```{r ph-figure, echo=FALSE, out.width='100%'}",
  'knitr::include_graphics("03_OUTPUTS/figures/ph_diagnostics.png")',
  "```"
)

writeLines(
  rmd_content,
  "clinical_trial_report.Rmd"
)

