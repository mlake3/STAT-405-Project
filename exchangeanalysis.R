#Libraries Needed
library(tidyverse)
library(stringr)
library(dplyr)
library(ggplot2)
library(tsibble)
library(feasts)

#Get Argument
args = (commandArgs(trailingOnly = TRUE))
if (length(args) == 1){
  file = toString(args[1])
} else {
  cat('usage: Rscript exchangeanalysis.R <file>\n')
}

#Read/clean Data
data = read.csv(file)
data = data %>% rename(exchange = 1, date_time = 2, bid=3, ask=4)
data = data %>% mutate(bid = as.numeric(bid), ask = as.numeric(ask), market = (ask + bid )/2, spread = ask - bid, date =  as.Date(paste0(str_sub(date_time,1,4),"-",str_sub(date_time,5,6),"-", str_sub(date_time,7,8))))

#Get Important Data
exchange = str_match(file, "[A-Z]+")
ex_market_mean = mean(data$market)
ex_market_sd = sd(data$market)
ex_spread_mean = mean(data$spread)
ex_spread_sd = sd(data$spread)


# Convert to tsibble
data_ts <- data %>%
  group_by(exchange, date) %>%
  summarise(market = mean(market))%>%
  as_tsibble(key = exchange, index = date)


# Extract trend features
trends <- data_ts %>%
  features(market, features = feature_set(tags = "trend"))%>%
  select(c(exchange,trend_strength,spikiness, linearity, curvature))

trend_strength=trends$trend_strength
linearity=trends$linearity
curvature=trends$curvature
spikiness=trends$spikiness

#Write Summary Data
output = data.frame(exchanges = exchange, market_mean=ex_market_mean, market_sd=ex_market_sd, spread_mean = ex_spread_mean, spread_sd= ex_spread_sd,trend_strength = trend_strength , linearity = linearity, curvature= curvature,spikiness=spikiness)
if (file.exists("summary.csv")){
  write.table(output, file = "summary.csv", append = TRUE, sep = ",", col.names = FALSE, row.names = FALSE)
} else {
  write.table(output, file = "summary.csv", append = TRUE, sep = ",", col.names = TRUE, row.names = FALSE)
}

#Get Daily Data
daily_data = data %>% select(market, spread, date) %>% group_by(date) %>% summarise("market_mean" =  mean(market), "market_sd" = sd(market), market_max = max(market), market_min = min(market), "spread_mean" = mean(spread),"spread_sd" =  sd(spread))

#Graph Market Price of Exchange
ggplot(data = daily_data, aes(x = date)) + geom_ribbon(aes(ymin = market_mean - market_sd, ymax = market_mean + market_sd), fill = 'lightgrey') + geom_line(aes(y = market_mean), color = "blue") + geom_line(aes(y = market_min), color = "red") + geom_line(aes(y = market_max), color = "red") + ylab("Exchange Rate") + xlab("Date") + ggtitle(paste0("Daily Price graph for ",data$exchange[1]))

#Save Graph
ggsave(paste0("Daily_", exchange, "_Graph.png"))
