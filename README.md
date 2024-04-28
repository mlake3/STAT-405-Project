## GENERAL INFORMATION
This project entails comprehensive analysis of major currency pairs within the forex market, utilizing tick-by-tick historical rates obtained from Kaggle. With data spanning from September 2022 to September 2023, the project employs a meticulous setup process, including the organization of data into a unified structure and parallel processing through a shell script for efficiency. The analysis primarily focuses on two crucial metrics: spread and volatility. The spread, calculated as the difference between asking and bidding prices, serves as an indicator of trading costs and liquidity for each currency pair. Meanwhile, volatility, measured through the standard deviation of market prices, reflects the fluctuation and risk associated with trading. Through this analysis, the project aims to provide valuable insights into forex market dynamics, offering perspectives beneficial to traders and financial analysts alike. Findings are anticipated to shed light on factors influencing trading decisions and strategy development, ultimately contributing to a deeper understanding of the forex marketplace.

## SETTING UP THE DATA

1) Clone the repository into a new folder with `git clone https://github.com/mlake3/STAT-405-Project.git folderName`. From now on, work in this folder.
2) Download archive.zip file containing all the data [here](https://www.kaggle.com/datasets/joseserrat/forex-tick-data-huge-database-part-2) into your computer.
3) Copy and paste (with `scp`) the .zip file into the working directory.
4) Run `sbatch Submit.sh` to set up the data and parallelly collect all data of each currency pair into one csv file. All these csv files will be saved in directory named `allExchanges`.

You should have the following csv files in your `allExchanges` directory:
![exchanges files](exchanges.png)

These 19 csv files are the ones that will be used in 19 parallel jobs to do our statistical analysis.
