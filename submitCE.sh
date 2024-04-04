#!/bin/bash

mkdir -p slurm_out


jobId1=$(sbatch --array=1-19 \
                --output="slurm_out/slurm-%A_%a.out" \
                --error="slurm_out/slurm-%A_%a.err" \
                collectExchange.sh)
jobId1=$(echo $jobId1 | sed 's/Submitted batch job //')
