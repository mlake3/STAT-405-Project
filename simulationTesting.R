library(tidyverse)
library(lubridate)

historical_data = # read csvs jan through april
  simulated_data = # read csvs may through august
  
historical_start = as.Date("2023-01-01")
historical_end = as.Date("2023-04-30")
simulation_start = as.Date("2023-05-01")
simulation_end = as.Date("2023-08-31")
simulation_days = as.numeric(simulation_end - simulation_start) + 1

historical_data = historical_data %>% 
  filter(date >= historical_start & date <= historical_end) %>% 
  mutate(score = calculate_score(.)) # example of adding scores

calculate_score = function(data) { 
  # define how score is calculated from data
  return(runif(1, 0, 100)) # random score between 0 and 100 for testing purposes
}

run_simulation = function(data, initial_amount, num_exchanges, interval_days) {
  # implement exchange logic for simulation
}

# Monte Carlo simulation
set.seed(1) # reproducibility
num_simulations = 1000
initial_amount = 100 # can experiment with different amounts

results_single = replicate(num_simulations, run_simulation(simulated_data, initial_amount, 1, NULL))
num_exchanges = 5  # Fixed number of multiple exchanges, can change later (possibly make dynamic based on formula?)
interval_days = floor(simulation_days / num_exchanges)  # Interval for multiple exchanges
results_multiple = replicate(num_simulations, run_simulation(simulated_data, initial_amount, num_exchanges, interval_days))

# examples of comparing single and multiple exchanges

analysis_single = summary_statistics(results_single)
analysis_multiple = summary_statistics(results_multiple)

plot_results(analysis_single, analysis_multiple)

test_results(analysis_single, analysis_multiple)
