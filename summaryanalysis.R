#Get Argument
args = (commandArgs(trailingOnly = TRUE))
if (length(args) == 1){
  RpackagesDir = args[1]
} else {
  cat('usage: Rscript summaryanalysis.R <RpackagesDir>\n')
}

.libPaths(new=c(RpackagesDir, .libPaths()))

library(tidyverse)
library(stringr)
library(dplyr)
library(ggplot2)
library(stringr)
library(tsibble)
library(feasts)
library(lubridate)

#Read in summary data 
summary_stats=read.csv("results/summary.csv")

#Plot Trend Strength
ggplot(summary_stats, aes(x=exchanges, y=trend_strength, fill = slope)) + 
  scale_fill_gradient2(low = "red", mid = "white", high = "green", midpoint = 0) +
  geom_bar(stat = "identity") + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + ggtitle("Trend Strength of Exchanges") + coord_cartesian(ylim = c(0.75, 1))
ggsave("TrendStrength.png")

#Plot Spikiness 
ggplot(summary_stats, aes(x=exchanges, y=spikiness)) +
  geom_bar(stat = "identity") + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + ggtitle("Spikinesses of Exchanges", subtitle = "note: JPY exchanges have larger spikiness scores than other exchanges") 
ggsave("Spikiness.png")

#Plot Correlation Coefficent of Market Price
ggplot(summary_stats, aes(x = exchanges, y = market_sd/market_mean, fill = slope)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient2(low = "red", mid = "white", high = "green", midpoint = 0) +  # Color transition from red to green
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
  ggtitle("Correlation Coefficient of Price") +
  ylab("Correlation Coefficient") +
  xlab("Exchange")
ggsave("MarketPriceCorrelationCoefficient.png")




#Plot Correlation Coefficent of Spread
ggplot(summary_stats, aes(x = exchanges, y = spread_sd/spread_mean, fill = slope)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient2(low = "red", mid = "white", high = "green", midpoint = 0) +  # Color transition from red to green
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
  ggtitle("Correlation Coefficient of Spread", subtitle = "Spread = Ask Price - Bid Price") +
  ylab("Correlation Coefficient") +
  xlab("Exchange") 
ggsave("SpreadCorrelationCoefficient.png")

#Get coefficients & prediction
lmresults = read_csv("results/lmresults.csv")
max_row_indices <- c()

# Loop through each column
for (col_index in seq_along(lmresults)) {
  # Find row index of maximum value in the current column
  max_row_index <- which.max(lmresults[[col_index]])
  max_row_indices = c(max_row_indices, max_row_index)
  
}


test_data = read.csv("results/dailydata.csv")
test_data = test_data %>% 
  mutate(date = as.Date(date)) %>% 
  arrange(exchange, date) 
test_data = test_data %>%
  group_by(exchange) %>%
  mutate(slope = signif(as.double(coef(lm(market_daily ~ date))[2]), 3)) %>% ungroup()

test_data_ts = as_tsibble(test_data, index = date, key = exchange)

test_trends = test_data_ts %>%
  group_by(exchange) %>%
  features(market_daily, features = feature_set(tags = "trend")) %>%
  ungroup() %>%
  select(exchange, trend_strength, spikiness, linearity, curvature) %>%
  mutate(
    trend_strength = signif(trend_strength, 3), 
    linearity = signif(linearity, 3), 
    curvature = signif(curvature, 3), 
    spikiness = signif(spikiness, 3)
  )

test_data = left_join(test_data, test_trends, by = "exchange")

sum_test_data = test_data %>% group_by(exchange) %>% summarise(market_daily = mean(market_daily), slope = mean(slope), trend_strength = mean(trend_strength), spikiness = mean(spikiness))

sum_test_data = sum_test_data %>% mutate(norm_slope = slope/market_daily)


sum_test_data$indice = max_row_indices

mean_slope = mean(sum_test_data$norm_slope)
sd_slope = sd(sum_test_data$norm_slope)

sum_test_data = sum_test_data %>% mutate(indice = as.numeric(indice),z_slope = (norm_slope - mean_slope)/sd_slope)

test_lm = lm(data = sum_test_data, indice ~ z_slope:trend_strength + z_slope + trend_strength + spikiness)
summary(test_lm)

intercept = as.numeric(test_lm$coefficients[1])
z_slope_coeff = as.numeric(test_lm$coefficients[2])  
ts_coeff = as.numeric(test_lm$coefficients[3])  
spikiness_coeff = as.numeric(test_lm$coefficients[4]) 
z_ts_coeff = as.numeric(test_lm$coefficients[5])  

sum_test_data = sum_test_data %>% mutate(score = intercept + z_slope_coeff*z_slope + ts_coeff*trend_strength + spikiness_coeff*spikiness + z_ts_coeff*z_slope*trend_strength, prediction = ifelse((score > 3 & indice >= 3) | (score < 3 & indice <= 3), "correct", "wrong"))
sum(sum_test_data$prediction == "correct")




sum_test_data %>% select(exchange, score, indice, prediction) %>% rename(optimal_exchanges = indice)
