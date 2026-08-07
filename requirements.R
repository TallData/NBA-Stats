# Core packages used by the exploratory NBA analysis scripts.
packages <- c(
  "RCurl",
  "dplyr",
  "ggplot2",
  "gridExtra",
  "RMySQL",
  "randomForest",
  "readr",
  "remotes",
  "scales",
  "shiny",
  "tidyr"
)

missing_packages <- packages[!packages %in% rownames(installed.packages())]

if (length(missing_packages) > 0) {
  install.packages(missing_packages)
}

if (!requireNamespace("hoopR", quietly = TRUE) || packageVersion("hoopR") < "3.1.0") {
  remotes::install_github(
    "sportsdataverse/hoopR",
    ref = "2df91a31c12f39630ae3837f1295e345419f30b7",
    dependencies = c("Depends", "Imports", "LinkingTo"),
    upgrade = "never"
  )
}
