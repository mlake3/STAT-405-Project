## GENERAL INFORMATION
- Add information about the project

## SETTING UP THE DATA

1) Clone the repository into a new folder with `git clone https://github.com/mlake3/STAT-405-Project.git folderName`. From now on, work in this folder.
2) Download archive.zip file containing all the data [here](https://www.kaggle.com/datasets/joseserrat/forex-tick-data-huge-database-part-2).
3) Copy and paste (with `scp`) the .zip file into the directory.
4) Unzip the file with `unzip archive.zip`. Now you should have 13 folders containing data for each month for respective 19 currency pairs.
5) Remove the archive file with `rm archive.zip`.
6) Create a directory to store all of the 13 folders by doing `mkdir data`.
7) Move all of the currency monthly folders into `data/` by doing `mv *202[23] data`.
8) Run `sbatch submitCE.sh` to parallelly collect all data of each currency pair into one csv file. All these csv files will be saved in directory named `allExchanges`.

You should have the following csv files in your `allExchanges` directory:
![exchanges files](exchanges.png)

These 19 csv files are the ones that will be used in 19 parallel jobs to do our statistical analysis.
