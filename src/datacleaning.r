# Nature scenario data production
# Matt Burke


# Load raw data
# madagascar_data <- read.csv("data/Madagascar_data_mod.csv")
econ_data <- read.csv("data/new_data.csv", header=TRUE)
nature_losses_data <- read.csv("data/EC.csv", header=TRUE) 
bau_losses_data <- read.csv("data/BAU.csv", header=TRUE) 
SP_data <- read.csv("data/T3.csv", header=TRUE)

econ_data <- dplyr::filter(econ_data, CountryName!="Madagascar")

MAX_GDP_CHANGE <- 0.0089
MIN_GDP_CHANGE <- -0.175

colnames(nature_losses_data) <- c("country", "nature_loss_2030")
colnames(bau_losses_data) <- c("country", "nature_loss_2030")

# Adjust spelling of Morocco. Incorrect in raw for some reason.
levels(nature_losses_data$country) <- c(levels(nature_losses_data$country), "Morocco") 
nature_losses_data$country[nature_losses_data$country == 'Morroco'] <- 'Morocco'
levels(bau_losses_data$country) <- c(levels(bau_losses_data$country), "Morocco") 
bau_losses_data$country[bau_losses_data$country == 'Morroco'] <- 'Morocco'

# add to country code
nature_losses_data$iso2 <- parse_country(nature_losses_data$country, to="iso2c") 
bau_losses_data$iso2 <- parse_country(bau_losses_data$country, to="iso2c") 
# scale losses
# nature_losses_data$nature_loss_2030 <- (nature_losses_data$nature_loss_2030*-1/100) 
nature_losses_data$nature_loss_2030 <- (nature_losses_data$nature_loss_2030/100) 
bau_losses_data$nature_loss_2030 <- (bau_losses_data$nature_loss_2030/100) 

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
levels(econ_data$CountryName) <- c(levels(econ_data$CountryName), "Madagascar")
levels(econ_data$CountryName) <- c(levels(econ_data$CountryName), "Ethiopia")

ETH_15 <- c("Ethiopia", 2015, 6, 738.82, 10.4, 21.03, -2.32, 161.07, -13.53)
ETH_16 <- c("Ethiopia", 2016, 6, 806.26, 8, 22.79, -1.87, 169.93, -10.95)
ETH_17 <- c("Ethiopia", 2017, 6, 866.89, 10.1, 25.45, -3.28, 192.19, -9.85)
ETH_18 <- c("Ethiopia", 2018, 6, 870.80, 7.7, 28.28, -3.03, 190.81, -7.86)
ETH_19 <- c("Ethiopia", 2019, 6, 973.49, 9, 26.52, -2.53, 200.61, -7.39)
ETH_20 <- c("Ethiopia", 2020, 5, 1072.29, 6.1, 27.85, -2.76, 232.21, -5.54)
Ethiopia_Data <- data.frame(
	CountryName= factor(),
	Year= integer(),
	scale20= numeric(),
	S_GDPpercapitaUS= numeric(),
	S_RealGDPgrowth= numeric(),
	S_NetGGdebtGDP= numeric(),
	S_GGbalanceGDP= numeric(),
	S_NarrownetextdebtCARs= numeric(),
	S_CurrentaccountbalanceGDP= numeric(),
	stringsAsFactors=FALSE)
levels(Ethiopia_Data$CountryName) <- c(levels(Ethiopia_Data$CountryName), "Ethiopia") # Add Ethiopia to levels
# Add Ethiopia years to rows on dataframe
Ethiopia_Data[1,] <-ETH_15
Ethiopia_Data[2,] <-ETH_16
Ethiopia_Data[3,] <-ETH_17
Ethiopia_Data[4,] <-ETH_18
Ethiopia_Data[5,] <-ETH_19
Ethiopia_Data[6,] <-ETH_20
Ethiopia_Data$iso2 <- countrycode(Ethiopia_Data$CountryName, origin="country.name", destination="iso2c")
econ_data <- rbind(econ_data, Ethiopia_Data)




econ_data <- dplyr::filter(econ_data, CountryName!="Madagascar")


write.csv(econ_data[complete.cases(econ_data), ], "derived_data/clean_econ_data.csv")


# Combine Ethiopia data 
# econ_data <- rbind(econ_data, ethiopia_data)
# econ_data <- rbind(econ_data, madagascar_data)

convert_to_numeric <- function(var){
    econ_data[[var]] <- as.numeric(econ_data[[var]])
}

convert_to_numeric("S_GDPpercapitaUS")
convert_to_numeric("Year")
convert_to_numeric("scale20")
convert_to_numeric("S_RealGDPgrowth")
convert_to_numeric("S_NetGGdebtGDP")
convert_to_numeric("S_GGbalanceGDP")
convert_to_numeric("S_NarrownetextdebtCARs")
convert_to_numeric("S_CurrentaccountbalanceGDP")

baseline <- as.data.frame(econ_data %>%
	dplyr::select(
		CountryName,
		iso2,
		Year,
		scale20,
		S_GDPpercapitaUS,
		S_RealGDPgrowth,
		S_NetGGdebtGDP,
		S_GGbalanceGDP,
		S_NarrownetextdebtCARs,
		S_CurrentaccountbalanceGDP) %>%
	dplyr::mutate(
		ln_S_GDPpercapitaUS = log(S_GDPpercapitaUS)) %>%
	dplyr::group_by(iso2) %>%
	dplyr::mutate(
		S_RealGDPgrowth = Delt(S_GDPpercapitaUS)*100) %>%
	dplyr::ungroup() %>%
	dplyr::group_by(Year) %>%
	dplyr::mutate(
			# ln_S_GDPpercapitaUS_Z = scale(ln_S_GDPpercapitaUS),
			ln_S_GDPpercapitaUS_Z = ln_S_GDPpercapitaUS,
			# S_RealGDPgrowth_Z = scale(S_RealGDPgrowth)) %>%
			S_RealGDPgrowth_Z = S_RealGDPgrowth) %>%
	dplyr::filter(Year > 2014))
baseline <- baseline[complete.cases(baseline),]

econ_data <- dplyr::filter(econ_data, Year==2020)

split_AO_from_CD <- function(loss_data){
	loss_data <- as.data.frame(loss_data %>%
	add_row(country = "Democratic Republic of Congo",
	nature_loss_2030 = loss_data[loss_data$iso2=="AO",]$nature_loss_2030[1],
	iso2 = "CD"))}
	
nature_losses_data <- nature_losses_data[complete.cases(nature_losses_data),]
bau_losses_data <- bau_losses_data[complete.cases(bau_losses_data),]

nature_losses_data <- split_AO_from_CD(nature_losses_data)
bau_losses_data <- split_AO_from_CD(bau_losses_data)

nature_losses_data <- dplyr::select(nature_losses_data, c(!(country)))
bau_losses_data <- dplyr::select(bau_losses_data, c(!(country)))



df1 <- cbind(nature_losses_data, bau_losses_data)
colnames(df1) <- c("TP_loss_as_pc", "iso2", "BAU_loss_as_pc", "X")
df1$country <- countrycode(df1$iso2, "iso2c", "country.name")
df1[df1$country=="Congo - Kinshasa", ]$country <- "Democratic Republic of the Congo"
df1 <- dplyr::select(df1, iso2, country, BAU_loss_as_pc, TP_loss_as_pc) 
df1$BAU_loss_as_pc <- df1$BAU_loss_as_pc*100
df1$TP_loss_as_pc <- df1$TP_loss_as_pc*100
write.csv(df1, "outputs/gdp_losses_clean.csv", row.names=FALSE)


# nature_losses_data <- nature_losses_data[complete.cases(nature_losses_data),]
# bau_losses_data <- bau_losses_data[complete.cases(bau_losses_data),]

combined_dataset <- inner_join(econ_data, nature_losses_data, by=c("iso2"))
combined_dataset <- inner_join(combined_dataset, bau_losses_data, by=c("iso2"))

combined_dataset <- dplyr::rename(combined_dataset, tipping_point = nature_loss_2030.x,  business_as_usual = nature_loss_2030.y)

gdp_losses <- SP_data$GDP_per_capita/100
NGGD <- log(SP_data$NGGD)
fit_NGGD <- lm(NGGD ~ poly(gdp_losses, 3, raw=TRUE))
GGB <- SP_data$GGB
sub_data <- data.frame(gdp_losses, GGB)
sub_data <- dplyr::filter(sub_data, GGB<0)
GGB <- sub_data$GGB
gdp_losses_GGB <- sub_data$gdp_losses
GGB <- log((GGB)*-1)
fit_GGB <- lm(GGB ~ poly(gdp_losses_GGB, 3, raw=TRUE))
NNED <- SP_data$NNED
sub_data <- data.frame(gdp_losses, NNED)
sub_data <- dplyr::filter(sub_data, NNED>0)
NNED <- sub_data$NNED
gdp_losses_NNED <- sub_data$gdp_losses
NNED <- log(NNED)
fit_NNED <- lm(NNED ~ poly(gdp_losses_NNED, 3, raw=TRUE))
CAB <- log(SP_data$CAB*-1)
fit_CAB <- lm(CAB ~ poly(gdp_losses, 3, raw=TRUE))

GPI_scores <- function(dataframe, year = 2030, scenario){
	# This function takes the defined relationships above and applies
	# them to the various scenarios we have. 
	equa <- function(A, x1,x2,x3,x4){
	x1 + A*x2 + (A^2)*x3 + (A^3)*x4
	}
	loss_series <- paste0(scenario)
	names(loss_series) <- loss_series
	temp_dataframe <- dplyr::select(dataframe, 
		iso2,
		Year,
		S_NetGGdebtGDP,
		S_GGbalanceGDP,
		S_NarrownetextdebtCARs,
		S_CurrentaccountbalanceGDP
		)
	loss_series_vector <- dataframe[[loss_series]]	
	maxV <- MAX_GDP_CHANGE
	minV <- MIN_GDP_CHANGE
	loss_series_vector <- sapply(loss_series_vector, function(y) max(min(y, maxV),minV))
	Kahn_climate_NGGD <- equa(loss_series_vector,
		fit_NGGD$coefficients[1],
		fit_NGGD$coefficients[2],
		fit_NGGD$coefficients[3],
		fit_NGGD$coefficients[4])
	Kahn_climate_NGGD <- exp(Kahn_climate_NGGD)
	Kahn_climate_GGB <- equa(loss_series_vector,
		fit_GGB$coefficients[1],
		fit_GGB$coefficients[2],
		fit_GGB$coefficients[3],
		fit_GGB$coefficients[4])
	Kahn_climate_GGB <- exp(Kahn_climate_GGB)
	Kahn_climate_GGB <- Kahn_climate_GGB*-1
	Kahn_climate_NNED <- equa(loss_series_vector,
		fit_NNED$coefficients[1],
		fit_NNED$coefficients[2],
		fit_NNED$coefficients[3],
		fit_NNED$coefficients[4])
	Kahn_climate_NNED <- exp(Kahn_climate_NNED)
	Kahn_climate_CAB <- equa(loss_series_vector,
		fit_CAB$coefficients[1],
		fit_CAB$coefficients[2],
		fit_CAB$coefficients[3],
		fit_CAB$coefficients[4])
	Kahn_climate_CAB <- exp(Kahn_climate_CAB)
	Kahn_climate_CAB <- Kahn_climate_CAB*-1
	temp_dataframe$S_NetGGdebtGDP <- temp_dataframe$S_NetGGdebtGDP + Kahn_climate_NGGD
	temp_dataframe$S_GGbalanceGDP <- temp_dataframe$S_GGbalanceGDP + Kahn_climate_GGB
	temp_dataframe$S_NarrownetextdebtCARs <- temp_dataframe$S_NarrownetextdebtCARs + Kahn_climate_NNED
	temp_dataframe$S_CurrentaccountbalanceGDP <- temp_dataframe$S_CurrentaccountbalanceGDP + Kahn_climate_CAB

	NGGD <- paste0("NGGD_", as.character(year), "_", scenario)
	GGB <- paste0("GGB_", as.character(year), "_", scenario)
	NNED <- paste0("NNED_", as.character(year), "_", scenario)
	CAB <- paste0("CAB_", as.character(year), "_", scenario)
	colnames(temp_dataframe) <- c("iso2", "Year", NGGD, GGB, NNED, CAB)
	dataframe <- inner_join(dataframe, temp_dataframe, by=c("iso2", "Year"))
	return(dataframe)}

combined_dataset <- GPI_scores(dataframe = combined_dataset,  scenario = "tipping_point")
combined_dataset <- GPI_scores(dataframe = combined_dataset,  scenario = "business_as_usual")

# Madagascar loses more than 100% of its economy in the tipping point scenario. We cap this at 99%
# to facilitate modelling. Although recognising that under this scenario MG would not have a rating.
combined_dataset$tipping_point[combined_dataset$tipping_point < -1] <- -0.99

filterFrames <- function(dataframe, year = 2030, scenario){
	# This code extracts the relevant climate data for the 
	# specificed scenario. See inputs, year and scenario.
	
	# Defining strings for selection later on.
	#year_delta <- year-2020
	year <- as.character(year)
	#year_delta <- as.character(year_delta)
	#scenario <- as.character(scenario)
	G <- paste0(scenario)
	nggd <- paste0("NGGD_",year,"_",scenario)
	ggb <- paste0("GGB_",year,"_",scenario)
	nned <- paste0("NNED_",year,"_",scenario)
	cab <- paste0("CAB_",year,"_",scenario)

	new_frame <- as.data.frame(dataframe %>%
		mutate(
			S_GDPpercapitaUS_nature = S_GDPpercapitaUS * (1+!!as.name(G)),
			growth = (!!as.name(scenario)*100/10),
		) %>%
		dplyr::select(
			CountryName,
			iso2,
			Year,
			scale20,
			S_GDPpercapitaUS = S_GDPpercapitaUS_nature,
			S_RealGDPgrowth = growth,
			S_NetGGdebtGDP = !!as.name(nggd),
			S_GGbalanceGDP = !!as.name(ggb),
			S_NarrownetextdebtCARs = !!as.name(nned),
			S_CurrentaccountbalanceGDP = !!as.name(cab)) %>%
		dplyr::mutate(
			ln_S_GDPpercapitaUS = log(S_GDPpercapitaUS)))
	new_frame <- as.data.frame(new_frame %>% 
		dplyr::mutate(
			# ln_S_GDPpercapitaUS_Z = scale(ln_S_GDPpercapitaUS),
			ln_S_GDPpercapitaUS_Z = ln_S_GDPpercapitaUS,
			# S_RealGDPgrowth_Z = scale(S_RealGDPgrowth)))
			S_RealGDPgrowth_Z = S_RealGDPgrowth))
	new_frame <- new_frame[complete.cases(new_frame),]
	return (new_frame)}

TP_2030 <- filterFrames(dataframe = combined_dataset, scenario = "tipping_point")
BAU_2030 <- filterFrames(dataframe = combined_dataset, scenario = "business_as_usual")

# This is more than in Klusak et al because we dont restrict to 
# the countries in the climate data for model building purposes.
write.csv(baseline, file = "derived_data/Baseline_data_clean.csv", row.names=FALSE)
write.csv(TP_2030, file = "derived_data/TP_2030.csv", row.names=FALSE)
write.csv(BAU_2030, file = "derived_data/BAU_2030.csv", row.names=FALSE)
