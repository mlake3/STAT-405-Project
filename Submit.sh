#!/bin/bash

mkdir -p slurm_out
# Exchange analysis jobs (divided into 5 parts to increase efficiency of computer power)

## light job
jobId1_1=$(sbatch --array=18 \
		--cpus-per-task=1 \
                --output="slurm_out/slurm-%A_%a.out" \
                --error="slurm_out/slurm-%A_%a.err" \
		--mem-per-cpu=1500M \
                exchangeanalysis.sh)
jobId1_1=$(echo $jobId1_1 | sed 's/Submitted batch job //')             

## light-medium job
jobId1_2=$(sbatch --array=4-5,9 \
		--cpus-per-task=8 \
                --output="slurm_out/slurm-%A_%a.out" \
                --error="slurm_out/slurm-%A_%a.err" \
		--mem-per-cpu=2600M \
                exchangeanalysis.sh)
jobId1_2=$(echo $jobId1_2 | sed 's/Submitted batch job //')             

## heavy-medium job
jobId1_3=$(sbatch --array=2,3,6,7,13-15,17,19 \
		--cpus-per-task=20 \
                --output="slurm_out/slurm-%A_%a.out" \
                --error="slurm_out/slurm-%A_%a.err" \
		--mem-per-cpu=2600M \
                exchangeanalysis.sh)
jobId1_3=$(echo $jobId1_3 | sed 's/Submitted batch job //')             



## heavy job
jobId1_4=$(sbatch --array=8,10,12,16 \
		--cpus-per-task=30 \
                --output="slurm_out/slurm-%A_%a.out" \
                --error="slurm_out/slurm-%A_%a.err" \
		--mem-per-cpu=2600M \
                exchangeanalysis.sh)
jobId1_4=$(echo $jobId1_4 | sed 's/Submitted batch job //')             

## super heavy job
jobId1_5=$(sbatch --array=1,11 \
		--cpus-per-task=40 \
                --output="slurm_out/slurm-%A_%a.out" \
                --error="slurm_out/slurm-%A_%a.err" \
		--mem-per-cpu=2600M \
                exchangeanalysis.sh)
jobId1_5=$(echo $jobId1_5 | sed 's/Submitted batch job //')       


#Monte Carlo Analysis
jobId2=$(sbatch --output="slurm_out/slurm-%A_%a.out" \
                --error="slurm_out/slurm-%A_%a.err" \
		--dependency=afterok:$jobId1_1:$jobId1_2:$jobId1_3:$jobId1_4:$jobId1_5 \
                montecarloanalysis.sh)
jobId2=$(echo $jobId2 | sed 's/Submitted batch job //')

#Summary Data Analysis
jobId3=$(sbatch --output="slurm_out/slurm-%A_%a.out" \
                --error="slurm_out/slurm-%A_%a.err" \
		--dependency=afterok:$jobId1_1:$jobId1_2:$jobId1_3:$jobId1_4:$jobId1_5 \
                summaryanalysis.sh)
jobId3=$(echo $jobId3 | sed 's/Submitted batch job //')       

