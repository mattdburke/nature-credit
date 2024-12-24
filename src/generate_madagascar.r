baseline <- read.csv("derived_data/clean_econ_data.csv", header=TRUE)

# Enter explanation for all the data and sources
mg_15 <- c("Madagascar", 2015, 1, 467.236, 3.132, NA, NA, NA, -2.259, "MG")
mg_16 <- c("Madagascar", 2016, 1, 475.956, 3.993, NA, NA, NA, 0.378, "MG")
mg_17 <- c("Madagascar", 2017, 1, 515.293, 3.993, NA, NA, NA, -0.229, "MG")
mg_18 <- c("Madagascar", 2018, 1, 518.401, 3.2, NA, NA, NA, 0.72, "MG")
mg_19 <- c("Madagascar", 2019, 1, 526.225, 4.4, NA, NA, NA, -2.329, "MG")
mg_20 <- c("Madagascar", 2020, 1, 495.49, -4.2, NA, NA, NA, NA, "MG")


madagascar_data <- data.frame(
    CountryName= factor(),
    Year = integer(),
    scale20 = integer(),
    S_GDPpercapitaUS = numeric(),
    S_RealGDPgrowth = numeric(),
	S_NetGGdebtGDP = numeric(),
	S_GGbalanceGDP= numeric(),
	S_NarrownetextdebtCARs = numeric(),
	S_CurrentaccountbalanceGDP = numeric(),
    iso2 = factor(),
	stringsAsFactors=FALSE)
levels(madagascar_data$CountryName) <- c(levels(madagascar_data$CountryName), "Madagascar")
levels(madagascar_data$iso2) <- c(levels(madagascar_data$iso2), "MG")

madagascar_data[1,] <- mg_15
madagascar_data[2,] <- mg_16
madagascar_data[3,] <- mg_17
madagascar_data[4,] <- mg_18
madagascar_data[5,] <- mg_19
madagascar_data[6,] <- mg_20

Baseline_x <- rbind(baseline, madagascar_data)

Baseline_x <- Baseline_x %>% dplyr::mutate(
    S_GDPpercapitaUS = as.numeric(S_GDPpercapitaUS),
    S_RealGDPgrowth = as.numeric(S_RealGDPgrowth),
    S_NetGGdebtGDP = as.numeric(S_NetGGdebtGDP),
    S_GGbalanceGDP = as.numeric(S_GGbalanceGDP),
    S_NarrownetextdebtCARs = as.numeric(S_NarrownetextdebtCARs),
    S_CurrentaccountbalanceGDP = as.numeric(S_CurrentaccountbalanceGDP),
    CountryName = as.factor(CountryName),
    iso2 = as.factor(iso2),
    Year = as.integer(Year)
    ) %>% dplyr::select(
        -scale20
    ) 

Baseline_x$ID <- Baseline_x %>% group_indices(CountryName)
Country_Identifiers <- Baseline_x %>% dplyr::select(CountryName, ID)
Country_Identifiers <- unique(Country_Identifiers)
Baseline_matrix <- data.matrix(Baseline_x)


set.seed(77)
imputation_forest <- missForest(
    Baseline_matrix, 
    maxiter=10, 
    ntree=2000
    )
imputation_data <- data.frame(imputation_forest$ximp)

mg_identifier <- Country_Identifiers[Country_Identifiers$CountryName=="Madagascar", ]$ID
mg <- dplyr::filter(imputation_data, ID==mg_identifier)

mg <- mg %>% dplyr::mutate(
    iso2 = rep("MG", times = 6),
    CountryName = rep("Madagascar", times = 6),
    scale20 = rep(1, times = 6)
    ) %>% dplyr::select(
        CountryName,
        Year,
        scale20,
        S_GDPpercapitaUS,
        S_RealGDPgrowth,
        S_NetGGdebtGDP,
        S_GGbalanceGDP,
        S_NarrownetextdebtCARs,
        S_CurrentaccountbalanceGDP,
        iso2     
    )

write.csv(mg, "derived_data/madagascar_data.csv", row.names=FALSE)






