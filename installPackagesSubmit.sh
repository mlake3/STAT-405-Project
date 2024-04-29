#!/bin/bash

# Install required packages
jobId1=$(sbatch --array=1-4 \
                --output="slurm_out/slurm-%A_%a.out" \
                --error="slurm_out/slurm-%A_%a.err" \
                installPackages.sh)
jobId1=$(echo $jobId1 | sed 's/Submitted batch job //')      
