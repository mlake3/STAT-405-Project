library(ggplot2)

#Read in summary data for Bar Graph on Trend_strength
trend_stats=read.csv("summary.csv")
ggplot(trend_stats, aes(x=exchanges, y=trend_strength)) + 
  geom_bar(stat = "identity")
