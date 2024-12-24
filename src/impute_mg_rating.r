baseline <- read.csv("derived_data/baseline_data_clean.csv")

n <- length(baseline[baseline$iso2=="MG", ]$scale20)
baseline[baseline$iso2=="MG", ]$scale20 <- rep(NA, n)

country_names <- baseline$CountryName
iso2_list <- baseline$iso2
years_list <- baseline$Year
# Select model building variables
baseline <- dplyr::select(baseline, 
    scale20,
    S_NetGGdebtGDP,
    S_GGbalanceGDP,
    S_NarrownetextdebtCARs,
    S_CurrentaccountbalanceGDP,
    ln_S_GDPpercapitaUS_Z,
    S_RealGDPgrowth_Z)
# Convert to matrix as required
baseline_matrix <- data.matrix(baseline)

set.seed(77)
# Run imputation
imputation_forest <- missForest(baseline_matrix,
    maxiter=10,
    ntree=2000)
imputation_data <- data.frame(imputation_forest$ximp)
# Collect rating
# madagascar_imputed_rating <- round(imputation_data[734:739,1], 0)

# Change made as per comment in line 6
madagascar_imputed_rating <- round(tail(imputation_data, n)$scale20, 0)

# Rebuild baseline
baseline$CountryName <- country_names
baseline$iso2 <- iso2_list
baseline$Year <- years_list
# Add estimated rating
baseline[baseline$iso2=="MG", ]$scale20 <- madagascar_imputed_rating

write.csv(baseline, "derived_data/baseline_clean_w_mg.csv", row.names = FALSE)

