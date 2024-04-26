#!/bin/bash

module load R/R-4.0.1 


# define array of exchanges to be used with task ID (19)
exchanges=("AUDJPY" "AUDNZD" "AUDUSD" "CADJPY" "CHFJPY" "EURCHF" "EURGBP" "EURJPY" "EURPLN" "EURUSD" "GBPJPY" "GBPUSD" "NZDUSD" "USDCAD" "USDCHF" "USDJPY" "USDMXN" "USDTRY" "USDZAR")

n=$SLURM_ARRAY_TASK_ID
index=$(($n-1))

exchange=${exchanges[$index]}
echo $exchange

Rscript exchangeanalysis.R allexchanges/$exchange.csv
