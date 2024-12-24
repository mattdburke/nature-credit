# Code and Data for "Biodiversity and the Future Creditworthiness of Nations"

🌿 *Exploring the link between biodiversity loss and sovereign credit ratings.*

We directly incorporate biodiversity and nature-related risks into assessments of sovereign creditworthiness. We extend S&P Global’s sovereign ratings methodology to assess creditworthiness of 23 nations under a range of scenarios relating to changes in tropical timber production, wild pollination services, and marine fisheries.

## Running the code

To run this code, open `main.r` in the root directory and type in the path to the root directory in the `setwd()` command. Then, you can run the sequence of source code commands, or simply run `main.r` as a `source(main.r)`. You may also run any element of the code, but just be conscious that some of it is dependent on previous files and data being produced. 

- Typical installation time is minutes if the user already has R installed, without R this may take up to 30 minutes or so just to get set up.
- Note that this directory already has all the derived data, plots etc produced. You may wish to test the code by deleting all of the output and then re-running with just the data in the `data` folder populated.
- To download R, follow the instructions on [R project]([https://www.r-project.org/])
- There isn't necessarily any expected output to be had on the R terminal, only that the code completes within about 25 minutes on a normal PC. However, you can expect that the files in `derived_data`, `outputs` and `plots` be populated.
- For a brief description of each R file, refer to [code description](src/code_description.md), data is also described [here](data/data_description.md)

## Reproducing plots

To directly reproduce specific plots, you may use the command `figure1_B` to produce figure1_B, and so on. Alternatively, run the script `source(plots.r)`.

## System requirements

This code was run on the following system, print out from `sessionInfo()` command in R.

```
R version 4.4.1 (2024-06-14 ucrt)
Platform: x86_64-w64-mingw32/x64
Running under: Windows 11 x64 (build 22631)

Matrix products: default


locale:
[1] LC_COLLATE=English_United Kingdom.utf8 
[2] LC_CTYPE=English_United Kingdom.utf8   
[3] LC_MONETARY=English_United Kingdom.utf8
[4] LC_NUMERIC=C                           
[5] LC_TIME=English_United Kingdom.utf8    

time zone: Europe/London
tzcode source: internal

attached base packages:
[1] stats4    grid      stats     graphics  grDevices utils     datasets 
[8] methods   base     

other attached packages:
 [1] tidyr_1.3.1       caTools_1.18.2    ggsci_3.2.0       patchwork_1.3.0  
 [5] docstring_1.0.0   wesanderson_0.3.7 passport_0.3.0    party_1.3-17     
 [9] strucchange_1.5-3 sandwich_3.1-0    modeltools_0.2-23 mvtnorm_1.3-0    
[13] gridExtra_2.3     ggrepel_0.9.5     reshape2_1.4.4    ggplot2_3.5.1    
[17] missForest_1.5    quantmod_0.4.26   TTR_0.24.4        xts_0.14.0       
[21] zoo_1.8-12        countrycode_1.6.0 stringr_1.5.1     DALEX_2.4.3      
[25] PEIP_2.2-5        ranger_0.16.0     dplyr_1.1.4      

loaded via a namespace (and not attached):
 [1] tidyselect_1.2.1     viridisLite_0.4.2    farver_2.1.2        
 [4] libcoin_1.0-10       bitops_1.0-8         fields_16.2         
 [7] TH.data_1.1-2        pracma_2.4.4         digest_0.6.37       
[10] dotCall64_1.1-1      lifecycle_1.0.4      survival_3.6-4      
[13] Rwave_2.6-5          magrittr_2.0.3       compiler_4.4.1      
[16] rlang_1.1.4          rngtools_1.5.2       tools_4.4.1         
[19] utf8_1.2.4           knitr_1.48           doRNG_1.8.6         
[22] curl_5.2.2           xml2_1.3.6           plyr_1.8.9          
[25] multcomp_1.4-26      purrr_1.0.2          withr_3.0.1         
[28] itertools_0.1-3      fansi_1.0.6          roxygen2_7.3.2      
[31] colorspace_2.1-1     scales_1.3.0         iterators_1.0.14    
[34] MASS_7.3-60.2        cli_3.6.3            generics_0.1.3      
[37] RSEIS_4.2-0          geigen_2.3           splines_4.4.1       
[40] bvls_1.4             maps_3.4.2           parallel_4.4.1      
[43] RPMG_2.2-7           matrixStats_1.3.0    vctrs_0.6.5         
[46] Matrix_1.7-0         foreach_1.5.2        glue_1.7.0          
[49] spam_2.10-0          codetools_0.2-20     stringi_1.8.4       
[52] gtable_0.3.5         munsell_0.5.1        tibble_3.2.1        
[55] pillar_1.9.0         randomForest_4.7-1.1 R6_2.5.1            
[58] lattice_0.22-6       Rcpp_1.0.13          coin_1.4-3          
[61] xfun_0.47            pkgconfig_2.0.3 
```
- This code, in various forms, runs fine on most versions of R and will produce the results without the need for many of the libraries. Some of these facilitate additional tests or producing the graphs etc. 
- There isn't a non-standard hardware requirement.

**Note** - Some of the code has redundancies, this will be cleaned up - however the main result is unaffected.

**Citation:**

If you use our data please cite,
```
@article{agarwala2024,
  title={Biodiversity and the Future Creditworthiness of Nations},
  author={Agarwala, M., Burke, M., Klusak, P., Kraemer, M., Volz, U., Sovacool, B.},
  year={2024}
}
```