rm(list=ls())

args = (commandArgs(trailingOnly=TRUE))
if(length(args) == 1){
  RpackagesDir = args[1]
} else {
  cat('usage: Rscript installR.R <RpackagesDir>\n', file=stderr())
  stop()
}
#require(remotes)

# Tell R to search in RpackagesDir, in addition to where it already
# was searching, for installed R packages.
.libPaths(new=c(RpackagesDir, .libPaths()))
if (!require("tsibble")) { # If loading package fails ...
  # Install package in RpackagesDir.
   install.packages(pkgs="tsibble", lib=RpackagesDir, repos="https://cran.r-project.org")
  #   remotes::install_github("tidyverts/tsibble")
  #  devtools::install_github("business-science/tidyquant")

  stopifnot(require("tsibble")) # If loading still fails, quit.
}


