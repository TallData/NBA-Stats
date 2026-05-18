# Core packages used by the exploratory NBA analysis scripts.
packages <- c(
  "RCurl",
  "dplyr",
  "ggplot2",
  "gridExtra",
  "RMySQL",
  "randomForest",
  "scales",
  "shiny"
)

missing_packages <- packages[!packages %in% rownames(installed.packages())]

if (length(missing_packages) > 0) {
  install.packages(missing_packages)
}
