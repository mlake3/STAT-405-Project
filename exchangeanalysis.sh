#!/bin/bash

<<<<<<< HEAD
# This shell script handles parallel job of analysis2
module load R/R-4.0.1

RpackagesDir="R/library" # the R script will install packages here
mkdir --parents "$RpackagesDir" # make directory & parents; no error if dir already exists
=======
module load R/R-4.0.1 

>>>>>>> 1f8648dee4a0f1ae63c7957256c3c9be072a57ae

# define array of exchanges to be used with task ID (19)
exchanges=("AUDJPY" "AUDNZD" "AUDUSD" "CADJPY" "CHFJPY" "EURCHF" "EURGBP" "EURJPY" "EURPLN" "EURUSD" "GBPJPY" "GBPUSD" "NZDUSD" "USDCAD" "USDCHF" "USDJPY" "USDMXN" "USDTRY" "USDZAR")

n=$SLURM_ARRAY_TASK_ID
index=$(($n-1))

exchange=${exchanges[$index]}
echo $exchange

<<<<<<< HEAD
Rscript exchangeanalysis.R allexchanges/$exchange.csv "$RpackagesDir"
=======
Rscript exchangeanalysis.R allexchanges/$exchange.csv
>>>>>>> 1f8648dee4a0f1ae63c7957256c3c9be072a57ae
