# Colon Cancer Overall-Survival Analysis

## Project overview
This beginner R portfolio project reanalyses the colon cancer trial dataset distributed with the survival package. It compares overall survival between observation, levamisole, and levamisole plus fluorouracil (5-FU), and explores associations with age, sex and positive lymph-node count.
The project practises endpoint selection, descriptive summaries, Kaplan–Meier estimation, log-rank tests, Cox regression, model diagnostics and reporting. It is an educational reanalysis of an existing historical dataset, not a newly conducted clinical trial.

## Data source and endpoint
The input is survival::colon. Dataset documentation is available in R:
help("colon", package = "survival")
The original dataset has two records per patient: one for recurrence (etype = 1) and one for death (etype = 2). This project selects death records only, producing one record per patient for overall-survival analysis.
- Time is measured in days.
- Status 1 indicates death.
- Status 0 indicates censoring.
- Observation (Obs) is the treatment reference group.
- Sex is coded 0 for female and 1 for male.
- nodes is the number of positive lymph nodes.
The author did not collect the original data. Script 1 prepares the working data directly from the installed survival package; no separate data download is needed.

## Analysis population
Measure	Count
Overall-survival patients	929
Deaths	452
Censored observations	477
Observation group	315
Levamisole group	310
Levamisole + 5-FU group	304
Complete cases used in Cox models	911
Excluded from Cox models because of missing node counts	18

Kaplan–Meier estimates and the main treatment log-rank test use all 929 patients. The treatment-only and adjusted Cox models use the same 911 complete cases for model comparison.

## Methods
Descriptive summaries and Kaplan–Meier analysis
The workflow summarises patient counts, age and missing values. The median observed time in the inspection table is the median of recorded death or censoring times; it is not a Kaplan–Meier survival median or a formal estimate of median follow-up.
Kaplan–Meier curves are produced by treatment, sex and exploratory age groups (under 60 versus 60 or older). The treatment figure includes confidence intervals and a number-at-risk table. The analysis also prints overall three-year and treatment-specific five-year survival estimates.
A median reported as “not reached” means the estimated survival curve did not fall to 50% during observed follow-up. An unavailable confidence limit does not necessarily mean that the median itself is unavailable.

Log-rank comparisons
The project includes an overall treatment comparison, a sex comparison, and a treatment comparison stratified by sex. Treatment comparisons within each sex are exploratory.
A significant overall treatment test indicates that the survival curves differ somewhere across the three groups; it does not identify every pairwise difference. Different subgroup p-values do not establish a treatment-by-sex interaction. Exploratory comparisons are not adjusted for multiple testing.

Cox regression
The adjusted model is:
Surv(time, status) ~ rx + age + sex + nodes
Hazard ratios compare:
- Each treatment with observation.
- Male with female patients.
- Each additional year of age.
- Each additional positive lymph node.
Cox models use complete cases. Numerical estimates and p-values retain full precision in the exported CSV; rounding is used for presentation.

Model diagnostics
The proportional-hazards assumption is assessed using cox.zph(), with term-specific tests, a global test and diagnostic plots. These assess proportional hazards, not every aspect of model adequacy.

## Key results
Kaplan–Meier median survival
Treatment	Median survival
Observation	2,083 days
Levamisole	2,152 days
Levamisole + 5-FU	Not reached during observed follow-up
The overall treatment log-rank p-value is approximately 0.00290. The treatment comparison stratified by sex gives p approximately 0.00278.

Adjusted Cox model
Comparison	HR	95% CI	P-value
Levamisole vs observation	0.923	0.742–1.149	0.473
Levamisole + 5-FU vs observation	0.669	0.528–0.847	0.000840
Age: per additional year	1.005	0.997–1.013	0.187
Male vs female	0.972	0.806–1.173	0.768
Positive nodes: per additional node	1.097	1.078–1.116	<0.001
In the adjusted model, levamisole plus 5-FU was associated with a lower hazard of death than observation. Each additional positive node was associated with a higher hazard of death.
The levamisole-only, age and sex estimates have confidence intervals that include 1. This does not prove that these variables have no association.
A hazard ratio describes relative instantaneous event rates among those still at risk. HR 0.669 is not a 33% reduction in the probability of dying or a 33% increase in survival time.

Proportional-hazards assessment
The global diagnostic p-value is approximately 0.595, and all term-specific diagnostic p-values exceed 0.05. The tests did not detect evidence of non-proportional hazards. This does not prove the assumption; interpret the tests alongside the diagnostic plots.

Limitations
This is a focused educational reanalysis of historical trial data. The results are not a guide to current clinical treatment.
Complete-case analysis excludes 18 patients and may introduce selection bias. The Cox model assumes linear effects of age and positive-node count on the log hazard; more flexible functional forms were not assessed. Independent censoring is also assumed.
Exploratory age groups and sex-specific comparisons should be interpreted cautiously. No formal treatment-by-sex interaction analysis or multiple-testing adjustment is included for these exploratory comparisons.

Project structure
Location	Contents
01_RAW_DATA/colon_data.rds	Original dataset with both endpoint types
01_RAW_DATA/colon_os.rds	Overall-survival dataset used for analysis
02_SCRIPTS/	Numbered R scripts
03_OUTPUTS/tables/	Summary tables, Cox model and text report
03_OUTPUTS/figures/	Kaplan–Meier, forest and PH diagnostic figures
clinical_trial_report.Rmd	Report source generated by script 8
README.md	Project description and instructions
DISCLAIMER.md	Educational purpose and data-use explanation
The existing Raw_data.R is an earlier preparation script and is not required by the current pipeline.

## How to run
Use R and, preferably, RStudio. Install the required packages once:
install.packages(
  c("survival", "survminer", "forestplot", "dplyr", "ggplot2")
)
Download or clone the project. If a project .Rproj file is included, open it in RStudio. Otherwise, use Session → Set Working Directory → Choose Directory and select the folder containing 02_SCRIPTS.
The current Git ignore rules exclude .Rproj files, so a fresh clone may not contain one.
Restart R and ensure no saved workspace objects are restored. Run:
source("02_SCRIPTS/08_Final_Report.R")
Script 8 runs scripts 1–7, regenerates the data and analysis outputs, and writes the text summary and R Markdown report. Packages are loaded by script 1; they are not installed automatically.
For step-by-step execution, run scripts 1–7 in order:
source("02_SCRIPTS/01_load_packages.R")
source("02_SCRIPTS/02_Data_Inspection.R")
source("02_SCRIPTS/03_Survival_Analysis.R")
source("02_SCRIPTS/04_kaplan_meier.R")
source("02_SCRIPTS/05_logrank_test.R")
source("02_SCRIPTS/06_Cox_Regression.R")
source("02_SCRIPTS/07_Forest_Plots.R")
Running script 8 afterwards repeats those scripts before generating the reports.
Optional HTML report
Install the reporting packages once:
install.packages(c("rmarkdown", "knitr"))
After the analysis finishes, render:
rmarkdown::render("clinical_trial_report.Rmd")
Rendering also requires Pandoc, normally supplied with RStudio. Open the resulting clinical_trial_report.html to inspect its tables and figures. Creating the R Markdown source alone does not render HTML.
Troubleshooting paths
If a file cannot be found, check:
getwd()
file.exists("02_SCRIPTS/08_Final_Report.R")
file.exists("01_RAW_DATA/colon_os.rds")
The first file should exist in the downloaded project. The second is created by script 1. Filenames and capitalisation in the instructions match the supplied scripts.

## Generated outputs
Figures in 03_OUTPUTS/figures/:
- km_by_treatment.png
- km_by_sex.png
- km_by_age.png
- forest_plot.png
- ph_diagnostics.png
Files in 03_OUTPUTS/tables/:
- summary_table.csv
- survival_results.csv
- logrank_results.csv
- cox_results.csv
- ph_assumption_results.csv
- cox_model.rds
- clinical_summary.txt
Script 8 also generates clinical_trial_report.Rmd in the project folder. The HTML report is generated only when the optional rendering command is run.

## Tools and skills practised
R, survival, survminer, forestplot, dplyr and ggplot2; optional reporting with rmarkdown and knitr.
Skills include endpoint selection, handling censoring and missing data, Kaplan–Meier estimation, log-rank testing, Cox regression, assumption checking, figure export and reproducible reporting.

## Author and acknowledgements
Tshegofatso Leope
BHSc Biomedical Sciences, University of the Witwatersrand
Initially developed in August 2026; refined in October 2026.
The original trial investigators and the survival package maintainers made this dataset available for analysis. This project was developed through self-study, reference materials and assistance with troubleshooting and refinement.