#Library Needed
library(tidyverse)
library(stringr)
library(dplyr)
library(ggplot2)
library(stringr)
library(tsibble)
library(feasts)
library(lubridate)

historical_data = read.csv("dailydata.csv")
historical_data = historical_data %>% 
  mutate(date = as.Date(date)) %>% 
  arrange(exchange, date) 

# Calculating slopes per exchange
historical_data = historical_data %>%
  group_by(exchange) %>%
  mutate(slope = signif(as.double(coef(lm(market_daily ~ date))[2]), 3)) %>%
  ungroup()

# Creating the tsibble for features
historical_data_ts = as_tsibble(historical_data, index = date, key = exchange)

# Calculating trend features for each exchange
historical_trends = historical_data_ts %>%
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

# Joining trend features with the original data
historical_data = historical_data %>%
  left_join(historical_trends, by = "exchange")

simulated_data = read.csv("montecarlo.csv")
simulated_data = simulated_data %>% 
  mutate(date = as.Date(date)) %>% 
  arrange(exchange, date)  

# Calculating slopes per exchange
simulated_data = simulated_data %>%
  group_by(exchange) %>%
  mutate(slope = signif(as.double(coef(lm(market_daily ~ date))[2]), 3)) %>%
  ungroup()

# Creating the tsibble for features
simulated_data_ts = as_tsibble(historical_data, index = date, key = exchange)

# Calculating trend features for each exchange
simulated_trends = simulated_data_ts %>%
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

# Joining trend features with the original data
simulated_data = simulated_data %>%
  left_join(simulated_trends, by = "exchange")

normalize_factors <- historical_data %>%
  summarise(
    mean_trend = mean(trend_strength, na.rm = TRUE),
    sd_trend = sd(trend_strength, na.rm = TRUE),
    mean_slope = mean(slope, na.rm = TRUE),
    sd_slope = sd(slope, na.rm = TRUE),
    mean_spikiness = mean(spikiness, na.rm = TRUE),
    sd_spikiness = sd(spikiness, na.rm = TRUE)
  )

calculate_score <- function(trend_strength, slope, spikiness, factors) {
  # Apply normalization using precomputed factors
  normalized_trend_strength <- (trend_strength - factors$mean_trend) / factors$sd_trend
  normalized_slope <- (slope - factors$mean_slope) / factors$sd_slope
  normalized_spikiness <- (spikiness - factors$mean_spikiness) / factors$sd_spikiness
  
  # Calculate the score with adjusted weights and risk_aversion factor
  score <- (1 * normalized_trend_strength +
              1 * normalized_slope +
              -1 * normalized_spikiness)
  
  return(score)
}

historical_data = historical_data %>% 
  mutate(score = calculate_score(trend_strength, slope, spikiness, normalize_factors)) 



normalize_factors <- simulated_data %>%
  summarise(
    mean_trend = mean(trend_strength, na.rm = TRUE),
    sd_trend = sd(trend_strength, na.rm = TRUE),
    mean_slope = mean(slope, na.rm = TRUE),
    sd_slope = sd(slope, na.rm = TRUE),
    mean_spikiness = mean(spikiness, na.rm = TRUE),
    sd_spikiness = sd(spikiness, na.rm = TRUE)
  )

calculate_score <- function(trend_strength, slope, spikiness, factors) {
  # Apply normalization using precomputed factors
  normalized_trend_strength <- (trend_strength - factors$mean_trend) / factors$sd_trend
  normalized_slope <- (slope - factors$mean_slope) / factors$sd_slope
  normalized_spikiness <- (spikiness - factors$mean_spikiness) / factors$sd_spikiness
  
  # Calculate the score with adjusted weights and risk_aversion factor
  score <- (1 * normalized_trend_strength +
              1 * normalized_slope +
              -1 * normalized_spikiness)
  
  return(score)
}

simulated_data <- simulated_data %>% 
  mutate(score = calculate_score(trend_strength, slope, spikiness, normalize_factors))




# Define simulation parameters
historical_start = as.Date("2023-01-01")
historical_end = as.Date("2023-04-30")
simulation_start = as.Date("2023-05-01")
simulation_end = as.Date("2023-08-31")
simulation_days = as.numeric(simulation_end - simulation_start) + 1

simulate_exchanges <- function(data, initial_amount, num_exchanges) {
  if (nrow(data) < num_exchanges) {
    stop("Not enough data points for the number of exchanges specified")
  }
  
  results_single <- vector("numeric", length = nrow(data))
  results_multiple <- vector("numeric", length = nrow(data))
  interval_days <- max(1, floor(nrow(data) / num_exchanges))  # Avoid division by zero
  
  for (i in 1:nrow(data)) {
    results_single[i] <- initial_amount * (1 + ifelse(data$score[i] > 0, data$market_daily[i], -data$market_daily[i]) / 100)
    
    for (j in seq(i, min(i + interval_days - 1, nrow(data)))) {
      results_multiple[i] <- results_multiple[i] + initial_amount / num_exchanges * (1 + ifelse(data$score[j] > 0, data$market_daily[j], -data$market_daily[j]) / 100)
    }
  }
  
  list(single = mean(results_single), multiple = mean(results_multiple))
}

# Simplified testing of the simulation function
test_results <- simulate_exchanges(simulated_data[1:100, ], 100, 5)
print(test_results)


num_simulations = 100
initial_amount = 100
num_exchanges = 5
# Interval for multiple exchanges

all_results <- replicate(num_simulations, simulate_exchanges(simulated_data, initial_amount, num_exchanges), simplify = FALSE)

# Calculate averages of simulations
mean_single <- mean(sapply(all_results, function(x) x$single))
mean_multiple <- mean(sapply(all_results, function(x) x$multiple))

# Print results
print(paste("Average Return for Single Exchange:", mean_single))
print(paste("Average Return for Multiple Exchanges:", mean_multiple))

test_results <- simulate_exchanges(simulated_data[1:100, ], 100, 5)
print(test_results)


print(head(historical_data))
print(head(simulated_data))

# Check summary statistics for scores and slopes to ensure they are reasonable
summary(historical_data$score)
summary(simulated_data$score)

# Run a smaller number of simulations for initial testing
test_results <- simulate_exchanges(simulated_data, initial_amount, num_exchanges)
print(test_results)
