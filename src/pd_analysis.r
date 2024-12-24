TP <- read.csv("outputs/tp_estimates.csv", header=TRUE)
BAU <- read.csv("outputs/bau_estimates.csv", header=TRUE)
PD_data <- read.csv("data/10_year_default_rate.csv", header=FALSE)

rating <- PD_data$V2
default <- PD_data$V3

f_poly <- lm(formula = default ~ poly(rating, 5))

get_estimate_poly <- function(rating){
    y <- predict(f_poly, newdata = data.frame(rating = rating))
    y <- ifelse(y<0, 0, y)
    return (y)}

TP <- TP %>% dplyr::mutate(
    baseline_PD = get_estimate_poly(baseline_estimate),
    TP_PD = get_estimate_poly(est),
    deltaPD_TP = TP_PD - baseline_PD
) %>% dplyr::select(
    country,
    iso2,
    baseline_PD,
    TP_PD,
    deltaPD_TP
)

BAU <- BAU %>% dplyr::mutate(
    baseline_PD = get_estimate_poly(baseline_estimate),
    BAU_PD = get_estimate_poly(est),
    deltaPD_BAU = BAU_PD - baseline_PD
) %>% dplyr::select(
    country,
    iso2,
    baseline_PD,
    BAU_PD,
    deltaPD_BAU
)

pd_estimates <- dplyr::inner_join(
    TP,
    BAU,
    by = c("country", "iso2", "baseline_PD")
)

write.csv(pd_estimates, "outputs/pd_estimates.csv", row.names=FALSE)


