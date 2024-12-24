CRITICAL_VALUE <- .05
cl <- read.table("data/country_list.txt")
cl <- unique(cl$V1)
Baseline <- read.csv("derived_data/baseline_clean_w_mg.csv", header=TRUE)
TP_2030 <- read.csv("derived_data/tp_2030.csv", header=TRUE)
BAU_2030 <- read.csv("derived_data/bau_2030.csv", header=TRUE)

country_list <- TP_2030$iso2

in_sample_baseline <- dplyr::filter(Baseline, iso2 %in% country_list & Year == 2020)

# Remove madagascar and ethiopia for model building
Baseline <- dplyr::filter(Baseline, iso2 %in% cl)
Baseline <- dplyr::filter(Baseline, iso2 != "MG" & iso2 != "ET")

set.seed(77)
model.forest <- ranger(scale20 ~
	ln_S_GDPpercapitaUS_Z +
	S_RealGDPgrowth_Z +
	S_NetGGdebtGDP +
	S_GGbalanceGDP +
	S_NarrownetextdebtCARs +
	S_CurrentaccountbalanceGDP
	,
	data=Baseline,
	num.trees=2000,
	importance='permutation',
	write.forest = TRUE,
	keep.inbag=TRUE)

produce_baseline_estimate <- function(model, df = in_sample_baseline){
    pred <- predict(model, df, type="se")
	est <- pred$predictions
    return (est)}

produce_adjusted_ratings <- function(model, df){
	pred <- predict(model, df, type="se")
	est <- pred$predictions
	se <- pred$se
	actual <- df$scale20
    baseline_estimate <- produce_baseline_estimate(model)
	T <- pred$predictions / se
	n = length(df$CountryName)
	DF = n - 3
	crit = tinv(CRITICAL_VALUE, DF)
	est_lower = est + crit*se
	est_upper = est - crit*se
	country <- df$CountryName
	iso2 <- df$iso2
	m1 <- cbind(country, iso2, actual, est, est_lower, est_upper, baseline_estimate)
	m1 <- do.call(rbind, Map(data.frame, country=country,
		iso2 = iso2,
		actual=actual,
		est=est,
		est_lower=est_lower,
		est_upper=est_upper,
        baseline_estimate=baseline_estimate
		))
	return (m1)
}

write.csv(produce_adjusted_ratings(model.forest, TP_2030), file="outputs/tp_estimates.csv", row.names = FALSE)
write.csv(produce_adjusted_ratings(model.forest, BAU_2030), file="outputs/bau_estimates.csv", row.names = FALSE)
