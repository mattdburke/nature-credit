econ_data <- read.csv("data/econ_data.csv", header=TRUE)
econ_data <- dplyr::filter(econ_data, CountryName!="Madagascar")

# Select relevant econ data
econ_data <- as.data.frame(econ_data %>% dplyr::select(
	CountryName,
	Year,
	scale20,
	S_GDPpercapitaUS,
	S_RealGDPgrowth,
	S_NetGGdebtGDP,
	S_GGbalanceGDP,
	S_NarrownetextdebtCARs,
	S_CurrentaccountbalanceGDP, 
))

econ_data$iso2 <- parse_country(econ_data$CountryName, to="iso2c")
# levels(econ_data$CountryName) <- c(levels(econ_data$CountryName), "Madagascar")
levels(econ_data$CountryName) <- c(levels(econ_data$CountryName), "Ethiopia")

et_15 <- c("Ethiopia", 2015, 6, 738.82, 10.4, 21.03, -2.32, 161.07, -13.53)
et_16 <- c("Ethiopia", 2016, 6, 806.26, 8, 22.79, -1.87, 169.93, -10.95)
et_17 <- c("Ethiopia", 2017, 6, 866.89, 10.1, 25.45, -3.28, 192.19, -9.85)
et_18 <- c("Ethiopia", 2018, 6, 870.80, 7.7, 28.28, -3.03, 190.81, -7.86)
et_19 <- c("Ethiopia", 2019, 6, 973.49, 9, 26.52, -2.53, 200.61, -7.39)
et_20 <- c("Ethiopia", 2020, 5, 1072.29, 6.1, 27.85, -2.76, 232.21, -5.54)
ethiopia_data <- data.frame(
	CountryName= character(),
	Year= integer(),
	scale20= numeric(),
	S_GDPpercapitaUS= numeric(),
	S_RealGDPgrowth= numeric(),
	S_NetGGdebtGDP= numeric(),
	S_GGbalanceGDP= numeric(),
	S_NarrownetextdebtCARs= numeric(),
	S_CurrentaccountbalanceGDP= numeric(),
	stringsAsFactors=FALSE)
levels(ethiopia_data$CountryName) <- c(levels(ethiopia_data$CountryName), "Ethiopia") # Add Ethiopia to levels
# Add Ethiopia years to rows on dataframe
ethiopia_data[1,] <-et_15
ethiopia_data[2,] <-et_16
ethiopia_data[3,] <-et_17
ethiopia_data[4,] <-et_18
ethiopia_data[5,] <-et_19
ethiopia_data[6,] <-et_20
ethiopia_data$iso2 <- countrycode(ethiopia_data$CountryName, origin="country.name", destination="iso2c")
# econ_data <- rbind(econ_data, ethiopia_data)

econ_data <- econ_data %>%
  mutate(across(everything(), as.character))
ethiopia_data <- ethiopia_data %>%
  mutate(across(everything(), as.character))

econ_data <- bind_rows(list(econ_data, ethiopia_data))

# Sort the complete cases bit out
write.csv(econ_data[complete.cases(econ_data), ], "derived_data/clean_econ_data.csv", row.names=FALSE)

