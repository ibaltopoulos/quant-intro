require(xts)
require(quantmod)
require(PerformanceAnalytics)
require(TTR)

# Strategy description from  https://allocatesmartly.com/stokens-active-combined-asset-strategy/
#
# 
# Divide the portfolio into three equal slices (1/3 each). Each slice uses price 
# channel breakouts to choose between two opposing asset classes as shown in the table below.
# Go long the "risk" asset at today's close when the risk asset will end the day 
# above its upper channel (highest close of previous n-days). Switch to the 
# defensive asset at today's close when the risk asset will end the day below 
# its lower channel (lowest close of previous n-days). Hold positions until a 
# change in signal. Rebalance the entire portfolio either on a change in signal 
# or on the last trading day of the calendar year.

# Slice 1: SPY or IEF. Upper Channel 6 months, Lower Channel 1 year
# Slice 2: GLD or TLT. Upper Channel 1 year, Lower Channel 6 months
# Slice 3: VNQ or IEF. Upper Channel 6 months, Lower Channel 1 year


symbols <- c(
  "SPY", "IEF", # slice 1
  "GLD", "TLT", # slice 2
  "VNQ", "IEF"  # slice 3
)
getSymbols(symbols, from="1990-01-01")

getUpperChannel <- function(symbol, lookback) {
  return(rollapply(symbol, lookback, max, align = "right"))
}

getLowerChannel <- function(symbol, lookback) {
  return(rollapply(symbol, lookback, min, align = "right"))
}

oneYear <- 365
halfYear <- 365 / 2

spy.upper.channel <- getUpperChannel(Ad(SPY), halfYear)
spy.lower.channel <- getLowerChannel(Ad(SPY), oneYear)
gld.upper.channel <- getUpperChannel(Ad(GLD), oneYear)
gld.lower.channel <- getLowerChannel(Ad(GLD), halfYear)
vnq.upper.channel <- getUpperChannel(Ad(VNQ), halfYear)
vnq.lower.channel <- getLowerChannel(Ad(VNQ), oneYear)

spy.buy.signal <- ifelse(Ad(SPY) >= spy.upper.channel, 1, NA)
spy.sell.signal <- ifelse(Ad(SPY) <= spy.lower.channel, -1, NA)


spy.signal <- xts(rowSums(cbind(spy.buy.signal, spy.sell.signal), na.rm = TRUE), order.by = index(spy.buy.signal))
spy.signal <- na.locf(spy.signal)


