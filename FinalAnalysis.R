library(ggplot2)

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
