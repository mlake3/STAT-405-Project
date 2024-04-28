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




# Set initial parameters, can adjust based on travel budget, vacation duration, number of simulations, number of exchanges, etc...
amount_money = 10000
travel_duration = 123 # days
num_exchanges_options = 1:5
num_scenarios = 100

perform_simulation <- function(num_exchanges, currency_pair) {
  specific_data <- simulated_data %>% filter(exchange == currency_pair)
  results <- numeric(num_scenarios)  # Store results of each simulation
  
  if (nrow(specific_data) == 0) {
    warning(paste("No data found for currency pair:", currency_pair))
    return(NA)
  }
  
  # Define the full period for exchanges
  full_period <- as.Date(max(specific_data$date)) - as.Date(min(specific_data$date))
  
  for (simulation in 1:num_scenarios) {
    # Initialize money in base and foreign currencies
    base_currency_amount <- amount_money
    foreign_currency_amount <- 0
    
    for (exchange_index in 1:num_exchanges) {
      # Calculate the time of the next exchange
      if (exchange_index == 1) {
        exchange_date <- as.Date(min(specific_data$date))
      } else {
        exchange_date <- exchange_date + floor(full_period / num_exchanges)
      }
      
      # Find the closest rate up to the exchange date
      rate_on_date <- specific_data %>%
        filter(date <= exchange_date) %>%
        summarize(closest_rate = last(market_daily)) %>%
        pull(closest_rate)
      
      # Convert a portion of base currency at the sampled rate
      exchange_amount <- base_currency_amount / (num_exchanges - exchange_index + 1)
      converted_amount <- exchange_amount * rate_on_date
      base_currency_amount <- base_currency_amount - exchange_amount
      foreign_currency_amount <- foreign_currency_amount + converted_amount
    }
    
    # Final result is all foreign currency plus any remaining base currency
    total_after_all_exchanges <- foreign_currency_amount + base_currency_amount
    results[simulation] <- total_after_all_exchanges
  }
  
  # Average result over all simulations
  return(mean(results, na.rm = TRUE))
}

currency_pairs = unique(simulated_data$exchange)

# Initialize the matrix to hold simulation outcomes for each currency pair
simulation_outcomes = matrix(nrow = length(num_exchanges_options), ncol = length(currency_pairs))
colnames(simulation_outcomes) = currency_pairs
rownames(simulation_outcomes) = paste(num_exchanges_options, "exchanges")

# Perform simulations for each currency pair and number of exchanges
for (currency_pair in currency_pairs) {
  for (num_exchanges in num_exchanges_options) {
    simulation_outcomes[num_exchanges, currency_pair] = perform_simulation(num_exchanges, currency_pair)
  }
}

# Matrix to DF 
simulation_results_df = as.data.frame(simulation_outcomes)

print(simulation_results_df)
