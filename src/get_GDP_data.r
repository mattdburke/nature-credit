df1 <- read.csv("https://raw.githubusercontent.com/jandrewjohnson/gtap_invest/0.9.1/gtap_invest/gtap_aez/PNAS-Sep22-Oct28aedits/results/res/GDPR.csv")

df1 <- dplyr::filter(
    df1,
    GDPS=="GDPpct",
    SCEN=="BAU_aECOLLPS" | SCEN=="BAU_aES"
)

source("src/get_country_mapping.r")
df1$region <- rep(mapping_list, 2)

bau <- dplyr::filter(df1, SCEN=="BAU_aES")
ec <- dplyr::filter(df1, SCEN=="BAU_aECOLLPS")

bau <- dplyr::select(bau, region, Value)
ec <- dplyr::select(ec, region, Value)

write.csv(bau, "data/bau.csv", row.names=FALSE)
write.csv(ec, "data/ec.csv", row.names=FALSE)
