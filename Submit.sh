#!/bin/bash

mkdir -p slurm_out

# Install required packages
jobId1=$(sbatch --array=1-4 \
                --output="slurm_out/slurm-%A_%a.out" \
                --error="slurm_out/slurm-%A_%a.err" \
                installPackages.sh)
jobId1=$(echo $jobId1 | sed 's/Submitted batch job //')             

# Exchange analysis jobs (divided into 5 parts to increase efficiency of computer power)

## light job
jobId2_1=$(sbatch --array=18 \
		--cpus-per-task=1 \
                --output="slurm_out/slurm-%A_%a.out" \
                --error="slurm_out/slurm-%A_%a.err" \
		--mem-per-cpu=1500M \
                --dependency=afterok:$jobId1 \
                exchangeanalysis.sh)
jobId2_1=$(echo $jobId2_1 | sed 's/Submitted batch job //')             

## light-medium job
jobId2_2=$(sbatch --array=4-5,9 \
		--cpus-per-task=8 \
                --output="slurm_out/slurm-%A_%a.out" \
                --error="slurm_out/slurm-%A_%a.err" \
		--mem-per-cpu=2600M \
                --dependency=afterok:$jobId1 \
                exchangeanalysis.sh)
jobId2_2=$(echo $jobId2_2 | sed 's/Submitted batch job //')             

## heavy-medium job
jobId2_3=$(sbatch --array=2,3,6,7,13-15,17,19 \
		--cpus-per-task=20 \
                --output="slurm_out/slurm-%A_%a.out" \
                --error="slurm_out/slurm-%A_%a.err" \
		--mem-per-cpu=2600M \
                --dependency=afterok:$jobId1 \
                exchangeanalysis.sh)
jobId2_3=$(echo $jobId2_3 | sed 's/Submitted batch job //')             



## heavy job
jobId2_4=$(sbatch --array=8,10,12,16 \
		--cpus-per-task=30 \
                --output="slurm_out/slurm-%A_%a.out" \
                --error="slurm_out/slurm-%A_%a.err" \
		--mem-per-cpu=2600M \
                --dependency=afterok:$jobId1 \
                exchangeanalysis.sh)
jobId2_4=$(echo $jobId2_4 | sed 's/Submitted batch job //')             

## super heavy job
jobId2_5=$(sbatch --array=1,11 \
		--cpus-per-task=40 \
                --output="slurm_out/slurm-%A_%a.out" \
                --error="slurm_out/slurm-%A_%a.err" \
		--mem-per-cpu=2600M \
                --dependency=afterok:$jobId1 \
                exchangeanalysis.sh)
jobId2_5=$(echo $jobId2_5 | sed 's/Submitted batch job //')       


#Monte Carlo Analysis
jobId3=$(sbatch --output="slurm_out/slurm-%A_%a.out" \
                --error="slurm_out/slurm-%A_%a.err" \
		--dependency=afterok:$jobId2_1:$jobId2_2:$jobId2_3:$jobId2_4:$jobId2_5 \
                montecarloanalysis.sh)
jobId3=$(echo $jobId3 | sed 's/Submitted batch job //')

#Summary Data Analysis
jobId4=$(sbatch --output="slurm_out/slurm-%A_%a.out" \
                --error="slurm_out/slurm-%A_%a.err" \
		--dependency=afterok:$jobId2_1:$jobId2_2:$jobId2_3:$jobId2_4:$jobId2_5 \
                summaryanalysis.sh)
jobId4=$(echo $jobId4 | sed 's/Submitted batch job //')
