#!/bin/bash

# process: collect all the csv of an exchange into one file
mkdir -p allexchanges


# define array of exchanges to be used with task ID (19)
exchanges=("AUDJPY" "AUDNZD" "AUDUSD" "CADJPY" "CHFJPY" "EURCHF" "EURGBP" "EURJPY" "EURPLN" "EURUSD" "GBPJPY" "GBPUSD" "NZDUSD" "USDCAD" "USDCHF" "USDJPY" "USDMXN" "USDTRY" "USDZAR")

n=$SLURM_ARRAY_TASK_ID
index=$(($n-1))

exchange=${exchanges[$index]}
echo $exchange

for dir in data/*; do
    if [ -d $dir/$exchange* ]; then
	cat $dir/$exchange*/*.csv >> allexchanges/$exchange.csv
    fi
done
