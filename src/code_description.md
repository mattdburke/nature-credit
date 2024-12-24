# Description of code

Description for each script in the folder explaining function in order of running.

1. **lib.r**: Downloads and loads necessary packages
2. **get_GDP_data.r**: Downloads the raw gdp data from Justin Andrew Johnson's GitHub repo
3. **clean_raw_data_1.r**: This script combines transcribed data for Ethiopia over to the ordinary dataset
4. **generate_madagascar.r**: Over the sample, Madagascar is an un-rated country. So we estimate a starting point. Our model gives 5.6, S&P rated Madagascar in 2022 as 5. We are quite happy with this!
5. **clean_raw_data_2.r**: This file does the bulk of the data work, combining and generating the climate data with the economic data
6. **impute_mg_rating.r**: Put the data for Madagascar back into the economic files.
7. **analysis.r**: generates the adjusted ratings
8. **pd_analysis.r**: gives the probabilities of default
9. **compile_output_data.r**: Produces a single datasheet to output
10. **cd_analysis.r**: Gives the cost of debt.
11. **plots.r**: produces the plots