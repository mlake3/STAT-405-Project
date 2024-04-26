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
jobId3=$(sbatch --array=1-5 \
                --output="slurm_out/slurm-%A_%a.out" \
                --error="slurm_out/slurm-%A_%a.err" \
                --dependency=afterok:$jobId2 \
                installPackages.sh)
jobId3=$(echo $jobId3 | sed 's/Submitted batch job //')             


#Run exchange analysis in parrallel
jobId4=$(sbatch --array=1-19 \
                --output="slurm_out/slurm-%A_%a.out" \
                --error="slurm_out/slurm-%A_%a.err" \
                --dependency=afterok:$jobId3 \
                exchangeanalysis.sh)
jobId4=$(echo $jobId4 | sed 's/Submitted batch job //')             

#run final analysis
