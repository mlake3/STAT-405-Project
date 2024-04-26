#!/bin/bash

# Install packages needed for analysis
module load R/R-4.0.1

packages=("lubridate" "tidyverse" "feasts" "tsibble" "tidyquant")

n=$SLURM_ARRAY_TASK_ID
index=$(($n-1))

library=${packages[$index]}

RpackagesDir="R/library"
mkdir --parents "$RpackagesDir" 

Rscript installPackages.R "$RpackagesDir" "$library"


