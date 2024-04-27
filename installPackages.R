rm(list=ls())

## Run to install all packages
args = (commandArgs(trailingOnly=TRUE))
if(length(args) == 2){
  RpackagesDir = args[1]
  libr = args[2]
} else {
  cat('usage: Rscript installPackages.R <RpackagesDir> <Package Name>\n', file=stderr())
  stop()
}

.libPaths(new=c(RpackagesDir, .libPaths()))
if (!require(libr)) { # If loading package fails ...
  # Install package in RpackagesDir.
   install.packages(pkgs=libr, lib=RpackagesDir, repos="https://cran.r-project.org")

  stopifnot(require(libr)) # If loading still fails, quit.
}

