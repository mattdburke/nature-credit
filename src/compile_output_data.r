BAU_estimate <- read.csv("outputs/bau_estimates.csv")
TP_estimate <- read.csv("outputs/tp_estimates.csv")
PD_estimate <- read.csv("outputs/pd_estimates.csv")
gdp_losses <- read.csv("outputs/gdp_losses_clean.csv")

colnames(BAU_estimate) <- c(
    "country", 
    "iso2", 
    "actual_BAU", 
    "est_BAU", 
    "est_lower_BAU", 
    "est_upper_BAU",
    "est_baseline_BAU"
    )

colnames(TP_estimate) <- c(
    "country", 
    "iso2", 
    "actual_TP", 
    "est_TP", 
    "est_lower_TP", 
    "est_upper_TP",
    "est_baseline_TP"
    )


output_data <- inner_join(gdp_losses, TP_estimate, by=c("iso2"))
output_data <- inner_join(output_data, BAU_estimate, by=c("iso2"))
output_data <- inner_join(output_data, PD_estimate, by=c("iso2"))

output_data <- as.data.frame(output_data %>%
    dplyr::select(
        iso2 = iso2,
        country = country.x,
        actual = actual_BAU,
        est_baseline = est_baseline_BAU,
        est_BAU = est_BAU,
        est_lower_BAU = est_lower_BAU,
        est_upper_BAU = est_upper_BAU,
        est_TP = est_TP,
        est_lower_TP = est_lower_TP,
        est_upper_TP = est_upper_TP,
        loss_BAU = BAU_loss_as_pc,
        loss_TP = TP_loss_as_pc,
        baseline_PD = baseline_PD,
        TP_PD = TP_PD,
        BAU_PD = BAU_PD,
        deltaPD_TP = deltaPD_TP,
        deltaPD_BAU = deltaPD_BAU
))

write.csv(output_data, "outputs/output_data_clean.csv", row.names=FALSE)
