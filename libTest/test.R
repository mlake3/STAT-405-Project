## use this to test the libraries you downloaded
## customize the contents by yourself
rm(list=ls())

args = (commandArgs(trailingOnly=TRUE))
if(length(args) == 1){
  RpackagesDir = args[1]
} else {
  cat('usage: Rscript test.R <RpackagesDir>\n', file=stderr())
  stop()
}

.libPaths(new=c(RpackagesDir, .libPaths()))

library(tsibble)

# Create a simple time series data
ts_data <- tsibble(
  time = seq.Date(from = as.Date("2022-01-01"), by = "month", length.out = 12),
  value = 1:12
)

# Print the first few rows of the tsibble object
print(head(ts_data))
