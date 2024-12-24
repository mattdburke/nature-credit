required_packages <- c(
    "dplyr", 
    "ranger", 
    "PEIP", 
    "DALEX", 
    "stringr", 
    "countrycode", 
    "quantmod", 
    "missForest", 
    "ggplot2", 
    "reshape2", 
    "ggrepel", 
    "gridExtra", 
    "party", 
    "passport", 
    "wesanderson", 
    "docstring", 
    "patchwork", 
    "ggsci", 
    "caTools", 
    "tidyr")

load_or_install <- function(packages) {
  for (pkg in packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      install.packages(pkg, dependencies = TRUE)
    }
    library(pkg, character.only = TRUE)
  }
}

load_or_install(required_packages)

