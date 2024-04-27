#Get Argument
args = (commandArgs(trailingOnly = TRUE))
if (length(args) == 2){
  file = toString(args[1])
  RpackagesDir = args[2]
} else {
  cat('usage: Rscript exchangeanalysis.R <file> <RpackagesDir>\n')
}

.libPaths(new=c(RpackagesDir, .libPaths()))

# Libraries
library(tidyr)
library(readr)
library(stringr)
library(dplyr)
library(ggplot2)
library(tsibble)
library(feasts)
library(lubridate)

# Helper function to get daily data
get_daily_data_2023 <- function(data, start_date, end_date) {
  final_df = data %>% 
    filter(date >= as.Date(start_date) & date <= as.Date(end_date)) %>% 
    group_by(day(date), month(date)) %>% 
    mutate(
      market_daily = mean(market),
      market_sd = sd(market),
      market_max = max(market),
      market_min = min(market)
    ) %>% 
    ungroup() %>%
    group_by(exchange, day(date), month(date)) %>%
    summarise(
      market_daily = mean(market_daily),
      market_sd = mean(market_sd),
      market_max = mean(market_max),
      market_min = mean(market_min)
    ) %>%
    mutate(
      date = ymd(str_c("2023", "-", as.character(`month(date)`), "-", as.character(`day(date)`)))
    ) %>% 
    ungroup() %>% 
    select(exchange, date, market_daily:market_min)

    return(final_df)
}



#Read/clean Data
data = read_csv(file, col_names = c("exchange", "date", "bid", "ask")) %>%
  mutate(
    bid = as.numeric(bid),
    ask = as.numeric(ask),
    market = (ask + bid) / 2,
    spread = ask - bid,
    date = ymd_hms(date)
  )

message("successfully read the data")

#Get Important Data for the whole timeframe
exchange = str_match(file, "[A-Z]{6}")
ex_market_mean = signif(mean(data$market), 3)
ex_market_sd = signif(sd(data$market), 3)
ex_spread_mean = signif(mean(data$spread), 3)
ex_spread_sd = signif(sd(data$spread), 3)


message("successfully get important data")

# Get subset of the data for the rest of calculation (months before summer)
subset_data = get_daily_data_2023(data, "2023-01-01", "2023-05-01")

# Get subset of the data for Monte Carlo Simulation
subset_mc = get_daily_data_2023(data, "2023-05-01", "2023-08-31")

message("successfully created 2 subsets of the data")

# Convert to tsibble
data_ts <- subset_data %>%
  group_by(exchange, date) %>%
  as_tsibble(key = exchange, index = date)


# Extract trend features
trends <- data_ts %>%
  features(market_daily, features = feature_set(tags = "trend")) %>%
  select(c(exchange,trend_strength,spikiness, linearity, curvature))

trend_strength= signif(trends$trend_strength, 3)
linearity= signif(trends$linearity, 3)
curvature= signif(trends$curvature, 3)
spikiness= signif(trends$spikiness, 3)

message("successfully extract feasts")

#Get slope
slope = as.double(coef(lm(data = subset_data, market_daily ~ date))[2])
slope = signif(slope, 3)

#Write Summary Data
output = data.frame(exchanges = exchange, market_mean=ex_market_mean, market_sd=ex_market_sd, spread_mean = ex_spread_mean, spread_sd= ex_spread_sd,trend_strength = trend_strength , linearity = linearity, curvature= curvature,spikiness=spikiness, slope = slope)

if (file.exists("summary.csv")){
  write.table(output, file = "summary.csv", append = TRUE, sep = ",", col.names = FALSE, row.names = FALSE)
} else {
  write.table(output, file = "summary.csv", append = TRUE, sep = ",", col.names = TRUE, row.names = FALSE)
}

message("summary.csv is out")

if (file.exists("dailydata.csv")){
  write.table(subset_data, file = "dailydata.csv", append = TRUE, sep = ",", col.names = FALSE, row.names = FALSE)
} else {
  write.table(subset_data, file = "dailydata.csv", append = TRUE, sep = ",", col.names = TRUE, row.names = FALSE)
}

message("dailydata.csv is out")

if (file.exists("montecarlo.csv")){
  write.table(subset_mc, file = "montecarlo.csv", append = TRUE, sep = ",", col.names = FALSE, row.names = FALSE)
} else {
  write.table(subset_mc, file = "montecarlo.csv", append = TRUE, sep = ",", col.names = TRUE, row.names = FALSE)
}

message("montecarlo.csv is out")
