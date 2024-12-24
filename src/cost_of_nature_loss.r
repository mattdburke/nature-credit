setwd("C:/Users/mattb/OneDrive/GitHub/NatureRatings")
library(countrycode)
library(dplyr)
cd_estimates <- read.csv("outputs/CD_estimates.csv")
mean_income <- read.csv("data/mean-versus-median-monthly-per-capita-expenditure-or-income.csv")
population <- read.csv("data/population.csv")

# get, just the country, and increase in debt by billions
# call the new dataframe, df

df <- cd_estimates %>% mutate(
    iso3 = countrycode(iso2, origin="iso2c", destination="iso3c")
    ) %>% select(
    country = country.y,
    iso3,
    OAS_costofdebt_sov
)

mean_income <- mean_income %>% select(
    Code,
    Year,
    Median.income.or.consumption,
    Population..historical.
)
mean_income <- mean_income[complete.cases(mean_income),]

# reduce mean income to just the most recent year,
# and return only the median income or consumption
mean_income <- mean_income %>% group_by(
    Code
) %>% slice_max(Year, n=1)

df <- inner_join(
    df,
    mean_income,
    by = c("iso3"="Code")
)

df <- df %>% mutate(
    x = (OAS_costofdebt_sov*1000000000) / Population..historical.,
    y = (x / (Median.income.or.consumption*356)*100)
)

