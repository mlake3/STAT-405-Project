#!/bin/bash

module load R/R-4.0.1

RpackagesDir="R/library" 

Rscript summaryanalysis.R "$RpackagesDir"
