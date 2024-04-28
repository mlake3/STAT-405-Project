#!/bin/bash

mkdir -p slurm_out


# Pre setup job
jobId1=$(sbatch --output="slurm_out/slurm-%A_%a.out" \
                --error="slurm_out/slurm-%A_%a.err" \
                preSetup.sh)
jobId1=$(echo $jobId1 | sed 's/Submitted batch job //')


# Exchange collection job
jobId2=$(sbatch --array=1-19 \
                --output="slurm_out/slurm-%A_%a.out" \
                --error="slurm_out/slurm-%A_%a.err" \
                --dependency=afterok:$jobId1 \
                collectExchange.sh)
jobId2=$(echo $jobId2 | sed 's/Submitted batch job //')

# Install required packages
jobId3=$(sbatch --array=1-4 \
                --output="slurm_out/slurm-%A_%a.out" \
                --error="slurm_out/slurm-%A_%a.err" \
                --dependency=afterok:$jobId2 \
                installPackages.sh)
jobId3=$(echo $jobId3 | sed 's/Submitted batch job //')             

# Exchange analysis jobs (divided into 5 parts to increase efficiency of computer power)

## light job
jobId4_1=$(sbatch --array=18 \
		--cpus-per-task=1 \
                --output="slurm_out/slurm-%A_%a.out" \
                --error="slurm_out/slurm-%A_%a.err" \
		--mem-per-cpu=1500M \
                --dependency=afterok:$jobId3 \
                exchangeanalysis.sh)
jobId4_1=$(echo $jobId4_1 | sed 's/Submitted batch job //')             

## light-medium job
jobId4_2=$(sbatch --array=4-5,9 \
		--cpus-per-task=8 \
                --output="slurm_out/slurm-%A_%a.out" \
                --error="slurm_out/slurm-%A_%a.err" \
		--mem-per-cpu=2600M \
                --dependency=afterok:$jobId3 \
                exchangeanalysis.sh)
jobId4_2=$(echo $jobId4_2 | sed 's/Submitted batch job //')             

## heavy-medium job
jobId4_3=$(sbatch --array=2,3,6,7,13-15,17,19 \
		--cpus-per-task=20 \
                --output="slurm_out/slurm-%A_%a.out" \
                --error="slurm_out/slurm-%A_%a.err" \
		--mem-per-cpu=2600M \
                --dependency=afterok:$jobId3 \
                exchangeanalysis.sh)
jobId4_3=$(echo $jobId4_3 | sed 's/Submitted batch job //')             



## heavy job
jobId4_4=$(sbatch --array=8,10,12,16 \
		--cpus-per-task=30 \
                --output="slurm_out/slurm-%A_%a.out" \
                --error="slurm_out/slurm-%A_%a.err" \
		--mem-per-cpu=2600M \
                --dependency=afterok:$jobId3 \
                exchangeanalysis.sh)
jobId4_4=$(echo $jobId4_4 | sed 's/Submitted batch job //')             

## super heavy job
jobId4_5=$(sbatch --array=1,11 \
		--cpus-per-task=40 \
                --output="slurm_out/slurm-%A_%a.out" \
                --error="slurm_out/slurm-%A_%a.err" \
		--mem-per-cpu=2600M \
                --dependency=afterok:$jobId3 \
                exchangeanalysis.sh)
jobId4_5=$(echo $jobId4_5 | sed 's/Submitted batch job //')       


#Monte Carlo Analysis
jobId5=$(sbatch --output="slurm_out/slurm-%A_%a.out" \
                --error="slurm_out/slurm-%A_%a.err" \
		--dependency=afterok:$jobId4_5 \
                montecarloanalysis.sh)
jobId5=$(echo $jobId5 | sed 's/Submitted batch job //')

#Summary Data Analysis
jobId6=$(sbatch --output="slurm_out/slurm-%A_%a.out" \
                --error="slurm_out/slurm-%A_%a.err" \
		--dependency=afterok:$jobId5 \
                summaryanalysis.sh)
jobId6=$(echo $jobId6 | sed 's/Submitted batch job //')
