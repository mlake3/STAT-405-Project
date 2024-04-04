Download the neccesary data with the following link
https://www.kaggle.com/datasets/joseserrat/forex-tick-data-huge-database-part-2

Once at the kaggle page click the black download button. Now from here we see that each currency pair is spread out in different files by month In order to work around this we will wrangle and combine them together so that each pair is stored in one unique .csv file. First, we unzipped the forex file that we downloaded. 13 files for each month are now available for each of the months we have. Next step is to move all files into a folder called "data" to be used in our shell script for collecting the exchange pairs. The shell script handles all the 19 pairs in parallel and collects the data into one csv file respectively before they are all moved into one folder called 'allexchanges'. The resulting files follow the pattern (exchangepair).csv where exchange pair represents all the 19 exchange pairs. These 19 .csv files are the ones that will be used in 19 parallel jobs to do our statistical analysis.
# STAT-405-Project
# STAT-405-Project
# STAT-405-Project
