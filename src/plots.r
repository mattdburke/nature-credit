remove_argentina_from_dataset <- function(dataframe){
  #' Removes Argentina from the dataframe. Argentina's 
  #' results are generally not very reliable. As a result we don't report them
  #' for graphical purposes.
  #' dataframe: This must have a column titled iso2 and contain strings
  #' denoting a country's ISO 2 code.
  dataframe <- dplyr::filter(dataframe, iso2!="AR")
  return (dataframe)
}

create_iso2_var <- function(dataframe, type_of_debt){
  #' Adds an iso2 column to a dataframe containing a column titled "country"
  #' which denotes that country's proper name.
  colnames(dataframe) <- c("country", type_of_debt)
  dataframe$iso2 <- countrycode(dataframe$country, origin="country.name", destination="iso2c")
  return (dataframe)
}

organise_debt_dataframes <- function(dataframe, type_of_debt, debt_frame){
  #' Combines dataframes containing debt data with benchmark rating change
  #' estimates. This also produces a range of extra variables required for plotting. 
  #' dataframe: This should either be the sovereign or corporate debt dataframe. The
  #' benchmark dataset is not a parameter. 
  #' type_of_debt: This should be a string, either "SovereignDebt" or "CorporateDebt"
  #' debt_frame: This should be the name of the debt frame, either "sovereign" or "corporate"
  dataframe <- inner_join(m1.sum, dataframe, by=c("iso2"))
  dataframe$deltaTP <- dataframe$est_baseline - dataframe$est_TP
  dataframe$deltaBAU <- dataframe$est_baseline - dataframe$est_BAU
  dataframe <- dataframe[dataframe$deltaTP > 0, ]
  dataframe[[as.name(type_of_debt)]] <- as.numeric(as.character(dataframe[[as.name(type_of_debt)]]))
  if (debt_frame=="corporate"){
    dataframe <- dataframe[complete.cases(dataframe), ]
  }
  dataframe$lower_bound_cost_debt <- LOWER_BOUND_COST_OF_DEBT * abs(dataframe$deltaTP) * dataframe[[as.name(type_of_debt)]]
  dataframe$upper_bound_cost_debt <- UPPER_BOUND_COST_OF_DEBT * abs(dataframe$deltaTP) * dataframe[[as.name(type_of_debt)]]
  return (dataframe)  
}

LOWER_BOUND_COST_OF_DEBT <- 0.0008
UPPER_BOUND_COST_OF_DEBT <- 0.0012
RATING_LIST_ALPHA <- c("AAA", rep("AA", 3), rep("A", 3), rep("BBB", 3), rep("BB", 3), rep("B", 3), rep("CCC", 3), "C")
RATING_LIST_NUMERIC <- c(20:1)

TP <- read.csv("outputs/tp_estimates.csv", header=TRUE)
BAU <- read.csv("outputs/bau_estimates.csv", header=TRUE)
PD_data <- read.csv("data/10_year_default_rate.csv", header=FALSE)
m1.sum <- read.csv("outputs/output_data_clean.csv")
sovereign_debt <- read.csv("data/sovereignDebt.csv")
corporate_debt <- read.csv("data/corporateDebt.csv")
OAS_spread <- read.csv("derived_data/oas_spread.csv")

oas_poly <- lm(formula = oas ~ poly(rating, 3), data = OAS_spread)

get_estimate_poly <- function(rating){
    y <- predict(oas_poly, newdata = data.frame(rating = rating))
    return (y)}

TP <- remove_argentina_from_dataset(TP)
BAU <- remove_argentina_from_dataset(BAU)
m1.sum <- remove_argentina_from_dataset(m1.sum)

sovereign_debt <- create_iso2_var(sovereign_debt, "SovereignDebt")
corporate_debt <- create_iso2_var(corporate_debt, "CorporateDebt")

sovereign_debt_organised <- organise_debt_dataframes(sovereign_debt, "SovereignDebt", "sovereign")
corporate_debt_organised <- organise_debt_dataframes(corporate_debt, "CorporateDebt", "corporate")

sovereign_debt_organised$TP_spread <- get_estimate_poly(sovereign_debt_organised$est_TP)
sovereign_debt_organised$baseline_spread <- get_estimate_poly(sovereign_debt_organised$est_baseline)
corporate_debt_organised$TP_spread <- get_estimate_poly(corporate_debt_organised$est_TP)
corporate_debt_organised$baseline_spread <- get_estimate_poly(corporate_debt_organised$est_baseline)

sovereign_debt_organised$delta_spread <- sovereign_debt_organised$TP_spread-sovereign_debt_organised$baseline_spread
corporate_debt_organised$delta_spread <- corporate_debt_organised$TP_spread-corporate_debt_organised$baseline_spread

sovereign_debt_organised$OAS_costofdebt_sov <- (sovereign_debt_organised$delta_spread/100)*sovereign_debt_organised$SovereignDebt	
corporate_debt_organised$OAS_costofdebt_corp <- (corporate_debt_organised$delta_spread/100)*corporate_debt_organised$CorporateDebt	

th_set <- theme_bw()
th_options <-  theme(
  text = element_text(size=12)
  )
fill_palette_ <- scale_fill_npg()
color_palette_ <- scale_color_npg()
alpha_parameter <- 7/10
A4_WIDTH <- 210
A4_HEIGHT <- 297
SLIDE_WIDTH <- 126 * 1.7
SLIDE_HEIGHT <- 96/126 * SLIDE_WIDTH


figure1_A <- function(){
  # Capping Madagascar's loss to improve the aesthetic of the figure
  m1.sum[m1.sum$iso2=="MG", ]$loss_TP <- -20
    # Adding an asteriks to make it clear
  levels(m1.sum$country) <- c(levels(m1.sum$country), "Madagascar*") 
  m1.sum$country[m1.sum$country == "Madagascar"] <- "Madagascar*"
  fig1 <- melt(m1.sum[,c("country","loss_TP", "loss_BAU")],id.vars=1)
  fig1 <- as.data.frame(fig1)
  levels(fig1$variable)[levels(fig1$variable) == "loss_TP"] <- "Partial nature collapse"
  levels(fig1$variable)[levels(fig1$variable) == "loss_BAU"] <- "Business-as-usual"
  fig1 <- fig1 %>%
    rowwise() %>% 
    mutate( mymean = mean(c(value))) %>% 
    arrange(mymean) %>% 
    mutate(country=factor(country, country))
  plt1 <- ggplot(data=fig1, aes(x=country, y=value, fill=variable)) +
    geom_bar(stat="identity", position=position_dodge(), alpha=alpha_parameter)+
    fill_palette_ +
    th_set + th_options + coord_flip() +
    labs(y = "GDP change by 2030 (%)", x="",
      caption = "Source: Compiled with data from Johnson et al. (2023).",
      fill = "Scenario") + 
      theme(legend.position="bottom")
  ggsave("plots/figure1_A.jpeg",dpi=300, height = SLIDE_HEIGHT, width = SLIDE_WIDTH, units="mm")
}
figure1_A()







figure1_B <- function(){
  m1.sum$dRating_TP <- m1.sum$est_TP - m1.sum$est_baseline
  m1.sum$dRating_BAU <- m1.sum$est_BAU - m1.sum$est_baseline
  fig2 <- melt(m1.sum[,c("country","dRating_TP", "dRating_BAU")],id.vars=1)
  fig2 <- as.data.frame(fig2)
  levels(fig2$variable)[levels(fig2$variable) == "dRating_TP"] <- "Partial nature collapse"
  levels(fig2$variable)[levels(fig2$variable) == "dRating_BAU"] <- "Business-as-usual"
  fig2 <- fig2 %>%
      rowwise() %>% 
    mutate( mymean = mean(c(value))) %>% 
    arrange(mymean) %>% 
    mutate(country=factor(country, country))
  fig2 <- fig2[-c(53,54), ]
  ggplot(data=fig2, aes(x=country, y=value, fill=variable)) +
    geom_bar(stat="identity", position=position_dodge(), alpha=alpha_parameter, lineend = "round")+
    fill_palette_ +
    th_set + th_options + coord_flip() +
    labs(y = "Rating change (notches)", 
      x="",
    #   caption = "Source: Analysis based on data from Johnson et al. (2023).",
      fill = "Scenario") + 
      theme(legend.position="bottom")
  ggsave("plots/figure1_B.jpeg",dpi=300, height = SLIDE_HEIGHT, width = SLIDE_WIDTH, units="mm")
}
figure1_B()




# print_figure_3 <- function(){
# fig3 <- m1.sum %>% 
#     rowwise() %>% 
#     mutate( mymean = mean(c(est_baseline,est_TP) )) %>% 
#     arrange(mymean) %>% 
#     mutate(country=factor(country, country))
#   ggplot(fig3) +
#     geom_segment( aes(x=country, xend=country, y=est_baseline, yend=est_TP, alpha = alpha_parameter), color="grey", lwd=1.2, lineend = "round") +
#     geom_point( aes(x=country, y=est_baseline, color="00A087FF", alpha = alpha_parameter), size=4 ) +
#     geom_point( aes(x=country, y=est_TP, color="#4DBBD5FF", alpha = alpha_parameter), size=4 ) +
#     geom_point( aes(x=country, y=est_BAU, color="#E64B35FF", alpha = alpha_parameter), size=4)+
#     geom_segment( aes(x=country, xend=country, y=est_lower_TP, yend=est_upper_TP, color="#4DBBD5FF", alpha = alpha_parameter), lwd=1.2, lineend = "round") +
#     coord_flip()+
#     color_palette_ +
#     th_set + th_options +
#     theme(
#       legend.position = "none",
#     ) +
#     xlab("") +
#     ylab("Credit Rating (20-point scale)")+
#     labs(caption = "Source: Analysis based on data from Johnson et al. (2023).")
#   ggsave("plots/fig3_SLIDE.png", dpi=300, height = SLIDE_HEIGHT, width = SLIDE_WIDTH, units="mm")
# }
# print_figure_3()




# print_figure_4 <- function(){
#   fig4 <- as.data.frame(m1.sum %>%
#     mutate(est_baseline_int = round(est_baseline),
#         est_baseline_int = factor(est_baseline_int),
#         dRating_TP = est_TP - est_baseline,
#         dRating_BAU = est_BAU - est_baseline))
#         for (i in 1:length(RATING_LIST_ALPHA)){
#           levels(fig4$est_baseline_int)[levels(fig4$est_baseline_int) == as.character(RATING_LIST_NUMERIC[i])] <- RATING_LIST_ALPHA[i]}
#   fig4 <- melt(fig4[,c("est_baseline_int","dRating_TP", "dRating_BAU")],id.vars=1)
#   fig4 <- as.data.frame(fig4)
#   levels(fig4$variable)[levels(fig4$variable) == "dRating_TP"] <- "Partial nature collapse"
#   levels(fig4$variable)[levels(fig4$variable) == "dRating_BAU"] <- "Business-as-usual"
#   fig4 <- as.data.frame(fig4 %>%
#       group_by(variable,est_baseline_int) %>%
#       summarise(mean_change = mean(value)))
#   fig4$est_baseline_int <- factor(fig4$est_baseline_int, levels=c("AA", "A", "BBB", "BB", "B", "CCC"))
#   fig4 <- dplyr::filter(fig4, est_baseline_int != "CCC")
#   ggplot(data=fig4, aes(x=est_baseline_int, y=mean_change, fill=variable)) +
#     geom_bar(stat="identity", position=position_dodge(), alpha=alpha_parameter)+
#     fill_palette_ +
#     th_set + th_options +
#     labs(y = "Rating change (notches)", 
#       x="",
#       caption = "Source: Analysis based on data from Johnson et al. (2023).",
#       fill = "Scenario") + 
#       theme(legend.position="bottom") 
#   ggsave("plots/fig4_SLIDE.png",dpi=300, height = SLIDE_HEIGHT, width = SLIDE_WIDTH, units = "mm")
# }
# print_figure_4()





# print_figure_5 <- function(){
#   fig5 <- as.data.frame(m1.sum %>%
#     mutate(est_baseline_int = round(est_baseline),
#         est_baseline_int = factor(est_baseline_int)))
#         for (i in 1:length(RATING_LIST_ALPHA)){
#           levels(fig5$est_baseline_int)[levels(fig5$est_baseline_int) == as.character(RATING_LIST_NUMERIC[i])] <- RATING_LIST_ALPHA[i]}
#   fig5 <- melt(fig5[,c("est_baseline_int","deltaPD_TP", "deltaPD_BAU")],id.vars=1)
#   fig5 <- as.data.frame(fig5)
#   levels(fig5$variable)[levels(fig5$variable) == "deltaPD_TP"] <- "Partial nature collapse"
#   levels(fig5$variable)[levels(fig5$variable) == "deltaPD_BAU"] <- "Business-as-usual"
#   fig5 <- as.data.frame(fig5 %>%
#       group_by(variable,est_baseline_int) %>%
#       summarise(mean_change = mean(value)))
#   fig5$est_baseline_int <- factor(fig5$est_baseline_int, levels=c("AA", "A", "BBB", "BB", "B", "CCC"))
#   fig5 <- dplyr::filter(fig5, est_baseline_int != "CCC")
#   ggplot(data=fig5, aes(x=est_baseline_int, y=mean_change, fill=variable)) +
#     geom_bar(stat="identity", position=position_dodge(), alpha=alpha_parameter)+
#     fill_palette_ +
#     th_set + th_options +
#     labs(y = "Probability of default change (%)", 
#       x="",
#       caption = "Source: Analysis based on data from Johnson et al. (2023) and Standard & Poor's.",
#       fill = "Scenario") + 
#       theme(legend.position="bottom") 
#   ggsave("plots/fig5_SLIDE.png", dpi=300, height = SLIDE_HEIGHT, width = SLIDE_WIDTH, units = "mm")
# }
# print_figure_5()




# print_figure_6 <- function(){
#   fig6 <- melt(m1.sum[,c("country","deltaPD_TP", "deltaPD_BAU")],id.vars=1)
#   fig6 <- as.data.frame(fig6)
#   fig6 <- dplyr::filter(fig6, country != "Argentina")
#   levels(fig6$variable)[levels(fig6$variable) == "deltaPD_TP"] <- "Partial nature collapse"
#   levels(fig6$variable)[levels(fig6$variable) == "deltaPD_BAU"] <- "Business-as-usual"
#   fig6 <- fig6 %>%
#       rowwise() %>% 
#     mutate( mymean = mean(c(value))) %>% 
#     arrange(desc(mymean)) %>% 
#     mutate(country=factor(country, country))
#   ggplot(data=fig6, aes(x=country, y=value, fill=variable)) +
#     geom_bar(stat="identity", position=position_dodge(), alpha=alpha_parameter)+
#     coord_flip() +
#     fill_palette_ +
#     th_set + th_options +
#     labs(y = "Change in probability of default (%)", 
#       x="",
#       caption = "Source: Analysis based on data from Johnson et al. (2023) and Standard & Poor's.",
#       fill = "Scenario") + 
#       theme(legend.position="bottom") 
#   ggsave("plots/fig6_SLIDE.png",dpi=300, height = SLIDE_HEIGHT, width = SLIDE_WIDTH, units = "mm")
# }
# print_figure_6()





figure2 <- function(){
  fig7 <- melt(m1.sum[,c("country","baseline_PD", "deltaPD_TP")],id.vars=1)
  fig7 <- as.data.frame(fig7)
  fig7 <- dplyr::filter(fig7, country != "Argentina")
  levels(fig7$variable)[levels(fig7$variable) == "deltaPD_TP"] <- "Increase with partial nature collapse"
  levels(fig7$variable)[levels(fig7$variable) == "baseline_PD"] <- "2020 current values"
  fig7 <- fig7 %>%
      group_by(country) %>%
      mutate(x = sum(value))
  fig7 <- fig7 %>%
      rowwise() %>% 
    arrange(x) %>% 
    mutate(country=factor(country, country))
  ggplot(data=fig7, aes(x=country, y=value, fill=variable)) +
    geom_bar(stat="identity", position=position_stack(reverse = TRUE), alpha=alpha_parameter)+
    coord_flip() +
    fill_palette_ +
    th_set + th_options +
    labs(y = "Probability of default (%)", 
      x="",
    #   caption = "Source: Analysis based on data from Johnson et al. (2023) and Standard & Poor's.",
      fill = "Scenario") +
      theme(legend.position="bottom") 
  ggsave("plots/figure2.jpeg",dpi=300, height = SLIDE_HEIGHT, width = SLIDE_WIDTH, units = "mm")
}
figure2()





# print_figure_8 <- function(){
#   fig8 <- m1.sum %>% mutate(dRating_TP = est_TP - est_baseline) %>% dplyr::select(country, dRating_TP, deltaPD_TP) 
#   ggplot(fig8, aes(x=dRating_TP, y=deltaPD_TP, color=factor(3), alpha = alpha_parameter)) + geom_point(size=2, shape=23) +
#   color_palette_ +
#   th_set + th_options +
#   stat_smooth(method="lm", se=FALSE) +
#   geom_text_repel(aes(label=country), color="black", size=4)+
#   labs(y = "Change in probability of default (%)", 
#       caption = "Source: Analysis based on data from Johnson et al. (2023) and Standard & Poor's.",
#       x="Change in rating (notches)") +
#   theme(legend.position = "none")
#   ggsave("plots/fig8_SLIDE.png",dpi=300, height = SLIDE_HEIGHT, width = SLIDE_WIDTH, units = "mm")
# }
# print_figure_8()





# print_figure_9 <- function(){
#   m1.sum <- m1.sum[-13, ]
#   fig9 <- m1.sum %>% select(country, loss_TP, deltaPD_TP)
#   ggplot(fig9, aes(x=loss_TP, y=deltaPD_TP, color=factor(3), alpha = alpha_parameter)) + geom_point(size=2, shape=23) +
#   color_palette_ +
#   th_set + th_options +
#   stat_smooth(method="lm", se=FALSE) +
#   geom_text_repel(aes(label=country), color="black", size=4)+
#   labs(y = "Change in probability of default (%)", 
#       caption = "Source: Analysis based on data from Johnson et al. (2023) and Standard & Poor's.",
#       x="Change in GDP (%)") +
#   theme(legend.position = "none")
#   ggsave("plots/fig9_SLIDE.png",dpi=300, height = SLIDE_HEIGHT, width = SLIDE_WIDTH, units = "mm")
# }
# print_figure_9()





figureM4_A <- function(){
  ggplot(OAS_spread, aes(x=rating, y=oas))+
    geom_point(size=2, shape=23) +
  color_palette_ +
  th_set + th_options +
    theme(legend.position="none")+
    stat_smooth(method="lm", se=FALSE, formula=y ~ poly(x,3), aes(colour="3rd Order Polynomial", linetype="Non-Linear"))+
    labs(
      y = "Median OAS Spread (%)", 
      caption = "Source: Analysis based on data from Johnson et al. (2023) and Standard & Poor's.",
      x="20 point numerical rating (20=AAA)")
  ggsave("plots/figureM4_A.png",dpi=300, height = SLIDE_HEIGHT, width = SLIDE_WIDTH, units = "mm") 
}
figureM4_A()


figureM4_B <- function(){
  ggplot(PD_data, aes(x=V2, y=V3))+
    geom_point(size=2, shape=23) +
  color_palette_ +
  th_set + th_options +
    theme(legend.position="none")+
    stat_smooth(method="lm", se=FALSE, formula=y ~ poly(x,5), aes(colour="Quintic Regression", linetype="Non-Linear"))+
    labs(
      y = "Probability of Default (%)", 
      caption = "Source: Compiled based on data from Standard & Poor's",
      x="20 point numerical rating (20=AAA)")
  ggsave("plots/figureM4_B.png",dpi=300, height = SLIDE_HEIGHT, width = SLIDE_WIDTH, units = "mm")
}
figureM4_B()

figure3 <- function(){

    mean_income <- read.csv("data/mean-versus-median-monthly-per-capita-expenditure-or-income.csv")

    mean_income <- mean_income %>% mutate(
        Code = countrycode(Code, origin="iso3c", destination="iso2c")
    ) %>% select(
        Code,
        Year,
        Median.income.or.consumption,
        Population..historical.
    )
    mean_income <- mean_income[complete.cases(mean_income),]
    mean_income <- mean_income %>% group_by(
        Code
    ) %>% slice_max(Year, n=1)


    df2x <- inner_join(
        sovereign_debt_organised,
        mean_income,
        by = c("iso2"="Code")
    )

    df2x <- df2x %>% mutate(
        per_capita_increase_in_cod = (OAS_costofdebt_sov*1000000000) / Population..historical.,
        per_capita_increase_in_cod_prop_to_annual_income = (per_capita_increase_in_cod / (Median.income.or.consumption*356)*100)
    )

  df2x <- df2x %>% 
    rowwise() %>% 
    mutate( mymean = mean(per_capita_increase_in_cod_prop_to_annual_income)) %>% 
    arrange(mymean) %>% 
    # mutate(across('country.y', str_replace, 'Democratic Republic of the Congo', 'Congo, D.R.')) %>%
    mutate(country.y = str_replace(country.y, "Democratic Republic of the Congo", "Congo, D.R.")) %>%
    mutate(country.y=factor(country.y, country.y))
    write.csv(df2x, "./outputs/CD_estimates.csv")

  plt2 <- ggplot(df2x) +
    geom_segment( aes(x=country.y, xend=country.y, y=per_capita_increase_in_cod_prop_to_annual_income, yend=per_capita_increase_in_cod_prop_to_annual_income), color="grey", lwd=1.2, lineend = "round") +
    geom_point( aes(x=country.y, y=per_capita_increase_in_cod_prop_to_annual_income, color="#E64B35FF", alpha = alpha_parameter), size=4 ) +
    coord_flip()+
    th_set + th_options +
    theme(
      legend.position = "none",
    ) +
    xlab("") +
    ylab("Per capita debt rise (% median income)")+
    labs(caption="")

  df1x <- sovereign_debt_organised %>% 
    rowwise() %>% 
    mutate( mymean = mean( OAS_costofdebt_sov )) %>% 
    arrange(mymean) %>% 
    mutate(country.y = str_replace(country.y, "Democratic Republic of the Congo", "Congo, D.R.")) %>%
    mutate(country.y=factor(country.y, country.y))
  plt1 <- ggplot(df1x) +
    geom_segment( aes(x=country.y, xend=country.y, y=OAS_costofdebt_sov, yend=OAS_costofdebt_sov), color="grey", lwd=1.2, lineend = "round") +
    geom_point( aes(x=country.y, y=OAS_costofdebt_sov, color="#E64B35FF", alpha = alpha_parameter), size=4 ) +
    coord_flip()+
    th_set + th_options +
    theme(
      legend.position = "none",
    ) +
    xlab("") +
    # ylab("Increase in cost of debt ($bn)") 
    ylab("Increase in cost of debt ($bn)") + 
    labs(caption="")
  g <- arrangeGrob(plt1, plt2, ncol=2) #generates g
  ggsave("plots/figure3.png",dpi=300, height = SLIDE_HEIGHT, width = SLIDE_WIDTH, units = "mm", g) #saves g
}
figure3()



# print_figure_rf_description <- function(){
#   baseline <- read.csv("derived_data/baseline_data_clean.csv")
#   baseline <- dplyr::select(
#     baseline,
#     rating = scale20, 
#     GDP = ln_S_GDPpercapitaUS_Z)
#   cf <- ctree(rating ~ ., data=baseline)
#   png("plots/RF_descriptor.png", height = SLIDE_HEIGHT, width = SLIDE_WIDTH, units = "mm", res=300)
#   plot(cf, type="simple")
#   dev.off()
# }
# print_figure_rf_description()


figureM2 <- function(){
SP_data <- read.csv("data/T3.csv", header=TRUE)
x <- SP_data$GDP_per_capita/100
y <- log(SP_data$NGGD)

ggplot(SP_data, aes(x=GDP_per_capita/100, y=log(NGGD))) +
  geom_point(size = 2, shape = 23) +
  color_palette_ + th_set + th_options +
  theme(legend.position="none")+
#   stat_smooth(method="lm", se=FALSE, formula=y ~ x, aes(colour="Linear", linetype="Linear")) +
#   stat_smooth(method="lm", se=FALSE, formula=y ~ poly(x,2), aes(colour="2nd Order Polynomial", linetype="Linear")) +
  stat_smooth(method="lm", se=FALSE, formula=y ~ poly(x,3), aes(colour="3rd Order Polynomial", linetype="Non-Linear"))+
  labs( y = "ln Net General Government Debt / GDP",
  caption = "Source: Analysis based on data from S&P (2015)",
  x = "GDP loss (%)")
  ggsave("plots/figureM2.png",dpi=300, height = SLIDE_HEIGHT, width = SLIDE_WIDTH, units = "mm") 
}
figureM2()



# print_figure_3_alt <- function(){
#   fig3 <- melt(m1.sum[,c("country", "est_TP", "est_baseline")],id.vars=1)
#   colnames(fig3) <- c("country", "Scenario", "value")
#   levels(fig3$Scenario)[levels(fig3$Scenario) == "est_TP"] <- "Partial nature collapse"
#   levels(fig3$Scenario)[levels(fig3$Scenario) == "est_baseline"] <- "Baseline"
#   TP <- fig3 %>% filter(Scenario == "Partial nature collapse")
#   Baseline <- fig3 %>% filter(Scenario == "Baseline")
# fig3 <- fig3 %>% 
#     mutate(country=factor(country))
#  fig3a <- ggplot(fig3) +
#     geom_segment(data = Baseline, aes(x= reorder(country, value), y = value, yend = TP$value, xend = TP$country), color = "#c6c9cd", alpha = alpha_parameter,lwd=4, lineend = "round") +
#     geom_point( aes(x=country, y=value, color=Scenario), alpha = alpha_parameter, size=4 ) +
#     coord_flip()+
#     color_palette_ +
#     th_set + th_options +
#     xlab("") +
#     ylab("Credit Rating (20-point scale)")+
#     theme(legend.position = "bottom") +
#     ylim(0, 20)
#   fig3 <- melt(m1.sum[,c("country", "est_BAU", "est_baseline")],id.vars=1)
#   colnames(fig3) <- c("country", "Scenario", "value")
#   levels(fig3$Scenario)[levels(fig3$Scenario) == "est_BAU"] <- "Business-as-usual"
#   levels(fig3$Scenario)[levels(fig3$Scenario) == "est_baseline"] <- "Baseline"
#   BAU <- fig3 %>% filter(Scenario == "Business-as-usual")
#   Baseline <- fig3 %>% filter(Scenario == "Baseline")
# fig3 <- fig3 %>% 
#     mutate(country=factor(country))
#   fig3b <- ggplot(fig3) +
#     geom_segment(data = Baseline, aes(x= reorder(country, value), y = value, yend = BAU$value, xend = BAU$country), color = "#c6c9cd", alpha = alpha_parameter,lwd=4, lineend = "round") +
#     geom_point( aes(x=country, y=value, color=Scenario), alpha = alpha_parameter, size=4 ) +
#     coord_flip()+
#     color_palette_ +
#     th_set + th_options +
#     xlab("") +
#     ylab("Credit Rating (20-point scale)")+
#     labs(caption = "Source: Analysis based on data from Johnson et al. (2023).")+ 
#     theme(legend.position="bottom") + 
#     ylim(0, 20)
#   plt = fig3a + fig3b
#   plt[[2]] = plt[[2]] + theme(axis.text.y=element_blank())
#   plt
#   ggsave("plots/fig3_alt_SLIDE.png", dpi=300, height = SLIDE_HEIGHT*1.2, width = SLIDE_WIDTH*1.2, units="mm", plt)
# }
# print_figure_3_alt()
