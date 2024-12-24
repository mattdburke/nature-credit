# Raw data dictionary

Add the raw data files from the online appendices to this folder. 

## Nature loss and climate data

A number of the files in this directory represent economic loss data from various scenarios. I provide a list below of the datasets and their corresponding published papers.

* [Johnson, J. A., Baldos, U. L., Corong, E., Thakrar, S. (2022). Investing in nature can improve equity and economic returns. PNAS, 120(27)](https://www.pnas.org/doi/10.1073/pnas.2220401120#supplementary-materials)
    - `BAU.csv` 
    - `EC.csv` 

This data is downloaded directly from Justin Andrew Johnson's GitHub repo, link is [here](https://github.com/jandrewjohnson/gtap_invest/blob/0.9.1/gtap_invest/gtap_aez/PNAS-Sep22-Oct28aedits/results/res/GDPR.csv). It is downloaded and processed using the code [here](src/get_GDP_data.r). The raw data has also been downloaded and saved [here](data/GDPR.csv) to ensure reproducibility.

## Economic and other data

Corporate and Sovereign debt data from the Bank of International Settlements and Standard & Poor's respectively
- `corporateDebt.csv`
- `sovereignDebt.csv`

Data from Table 3 in "Storm Alert: Natural Disasters Can Damage Sovereign Creditworthiness" by Standard & Poor's
- `T3.csv`

Fundemental economic data
- `economic.csv`
Data on the economic fundementals of the sovereigns under study. The variables of interest in this dataset are the following;
* **CountryName**: List of country names
* **Year**: Year of observation
* **scale20**: 1-20 scale corresponding to S&P Sovereign rating scale
* **S_GDPpercapitaUS**: GDP per capita in US$ as defined by S&P SRI
* **S_RealGDPgrowth**: Real GDP growth as defined by S&P SRI
* **S_NetGGdebtGDP**: Net general government debt to GDP as defined by S&P SRI
* **S_GGbalanceGDP**: General government balance to GDP as defined by S&P SRI
* **S_NarrownetextdebtCARs**: Narrow net external debt to CARs as defined by S&P SRI
* **S_CurrentaccountbalanceGDP**: Current account balance to GDP as defined by S&P SRI

Data from the St Louis Fed to give the option-adjusted spreads data. The headers in this file provide the code for the specific series used. 
-  `FRED_OAS_data_raw.csv`

Data input manually from the World Bank to construct `Ethiopia_data.csv`. This is done using the code [here](src\construct_ethiopia_data.r)
-   `Ethiopia_data.csv`

We repeat a similar exercise for Madagascar. 
-   `Madagascar_data.csv`
-   `Madagascar_data_mod.csv`

To keep the underlying model as close to [Klusak et al (2023)](MS link here) as possible we train the random forest on the same cross-section of countries. We take a list from an output of that model to filter the input in this setting.
-   `country_list.txt`

10 year Default rates are taken from the following S&P website and transcribed manually. Table 18.
- https://www.spglobal.com/ratings/en/research/articles/220504-default-transition-and-recovery-2021-annual-global-sovereign-default-and-rating-transition-study-12350530 

Special note regarding permissions for S&P Data
- S&P played no role in the application of this data to our research. We obtained the Sovereign Risk Indicators via the publicly available website [here](https://disclosure.spglobal.com/sri/). 