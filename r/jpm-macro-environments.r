library(Quandl)

setwd("D:/Github/quant-intro/r")

source("secrets.r")

Quandl.api_key(api_key = quandl.apikey)
trade_weighted_usd = Quandl("FRED/DTWEXM", type="xts")
volatility_index = Quandl("CBOE/VIX", type="xts")
wti_crude_oil_prices = Quandl("FRED/DCOILWTICO", type="xts")
brent_crude_oil_prices = Quandl("FRED/DCOILBRENTEU", type="xts")
gold_price = Quandl("BUNDESBANK/BBK01_WT5511", type="xts")
copper_price = Quandl("ODA/PCOPP_USD", type="xts")
baltic_dry_idx = Quandl("LLOYDS/BDI", type="xts")
ted_spread = Quandl("FRED/TEDRATE", type="xts")
usa_federal_rate = Quandl("FRED/DFF", type="xts")
usa_unemployment_rate = Quandl("BCB/3787", type="xts")


snp500_index = Quandl("YAHOO/INDEX_GSPC", type="xts")
snp500tr_index = Quandl("YAHOO/SP500TR", type="xts")


consumer_sentiment = Quandl("UMICH/SOC1", type="xts")
consumer_discretionary_spdr_xly = Quandl("GOOG/NYSEARCA_XLY", type="xts")

str(consumer_sentiment)

cor(consumer_sentiment[,1], consumer_discretionary_spdr_xly[,4])

m <- to.monthly(consumer_discretionary_spdr_xly["2002/2015"], indexAt='yearmon', drop.time = TRUE)[,4]
c <- consumer_sentiment["2002/2015"][,1]

c

plot(rollapply(cbind(m,c), 36, function(x) cor(x[,1], x[,2]), by.column = FALSE))
lines(rollapply(cbind(m,c), 24, function(x) cor(x[,1], x[,2]), by.column = FALSE), col="red")
lines(rollapply(cbind(m,c), 12, function(x) cor(x[,1], x[,2]), by.column = FALSE), col="blue")

cor(m,c)

cor(consumer_sentiment["2002/"][,1], to.monthly(consumer_discretionary_spdr_xly["2002/"], drop.time = TRUE)[,4])


plot(consumer_sentiment)
plot(consumer_discretionary_spdr_xly)

str(snp500_index)

dev.new()
plot(trade_weighted_usd)
plot(volatility_index)

plot(wti_crude_oil_prices)
plot(brent_crude_oil_prices)

## Classifiying environments
## 

# High vs. low. 
# When the value of the time series is above or below the standard deviation 
# band about the average. They use 12 month rolling mean, and 1 SD

# Peaks and Troughs
# The local maximum or minimum at the middele of any 12 month rolling window. 
# Extended periods can pass with no peak or trough if the series keeps rising or 
# falling. Tested the 6 month window following every peak and trough.

# Rising and falling. Periods between peaks and troughs identified above