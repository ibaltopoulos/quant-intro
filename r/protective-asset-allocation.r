require(xts)
require(quantmod)
require(PerformanceAnalytics)
require(TTR)

### The PAA model will be backtested from Dec 1970 - Dec 2015 (45 years) on
# monthly total return data (see paper for data construction). The universe 
# of choice is a global diversified multi-asset universe consisting of proxies 
# for 12 so called "risky" ETFs: SPY, QQQ, IWM (US equities: S&P500, Nasdaq100 
# and Russell2000 Small Cap), VGK, EWJ (Developed International Market equities: 
# Europe and Japan), EEM (Emerging Market equities), IYR, GSG, GLD 
# (Alternatives: REIT, Commodities, Gold), HYG, LQD and TLT (US High Yield bonds, 
# US Investment Grade Corporate bonds and Long Term US Treasuries). 
# The broadness of the universe makes it suitable for harvesting risk premia
# during different economical regimes. 


getPrices <- function(symbols, frequency) {
  prices <- list()
  for(i in 1:length(symbols)) {
    adjustedPrices <- Ad(get(symbols[i], envir = globalenv()))
    colnames(adjustedPrices) <- gsub("\\.[A-z]*", "", colnames(adjustedPrices))
    prices[[i]] <-
      Cl(switch(frequency,
                weekly = to.weekly(adjustedPrices),
                monthly = to.monthly(adjustedPrices),
                quarterly = to.quarterly(adjustedPrices),
                yearly = to.yearly(adjustedPrices)))
    
    colnames(prices[[i]]) <- symbols[i]
  }
  prices <- do.call(cbind, prices)
  
  return(prices)
}

getReturns <- function(symbols, frequency) {
  prices <- getPrices(symbols, frequency)
  colnames(prices) <- gsub("\\.[A-z]*", "", colnames(prices))
  returns <- Return.calculate(prices)
  
  return(returns)
}

MOM <- function(ts, lookback) {
  return ((ts / SMA(ts, lookback)) - 1)
}

BF <- function(mom, risky.symbols, protection) {
  N <- length(risky.symbols)
  good.assets <- rowSums(mom[, risky.symbols] > 0, na.rm=TRUE)
  
  BF <- pmin((N - good.assets) / (N - (protection * N/4)), 1)
  return(BF)
}

PAA <- function(risk_on, risk_off, frequency, lookback, protection, top) {
  prices <- getPrices(symbols, frequency)
  returns <- getReturns(symbols, frequency)
  mom <- apply(prices, 2, FUN = function(c) MOM(c, lookback))
  bf <- BF(mom, risk_on, protection)
  mom.rank <- t(apply(mom[, risk_on], 1, rank, ties.method="min"))
  mom.rank[mom.rank > top] <- 0
  
  weights.risk_on <- mom.rank
  weights.risk_on[weights.risk_on > 0] <- 1
  weights.risk_on <- weights.risk_on * (1 - bf) / top
  
  risk_off.count <- length(risk_off)
  weights.risk_off <-  matrix(rep(bf / risk_off.count, risk_off.count), ncol = risk_off.count)
  colnames(weights.risk_off) <- risk_off
  
  weights <- cbind(weights.risk_on, weights.risk_off)
  
  strategy <- lag(weights) * returns
  strategy.returns <- xts(rowSums(strategy), order.by = index(returns))
  
}

risk_on <- c("SPY", "QQQ", "EFA", "EEM", "GLD", "GSG", "IYR", "UUP", "HYG", "LQD", "IWM")
risk_off <- c("SHY", "IEF", "AGG", "TLT")

symbols <- c(risk_on, risk_off)

etf_names <- c(
  "SPDR S&P 500 ETF Trust",
  "NASDAQ- 100 Index Tracking Stock",
  "iShares MSCI EAFE Index Fund (ETF)",
  "iShares MSCI Emerging Markets Indx (ETF)",
  "SPDR Gold Trust (ETF)",
  "iShares S&P GSCI Commodity-Indexed Trust",
  "iShares Dow Jones US Real Estate (ETF)",
  "PowerShares DB US Dollar Bullish ETF",
  "iShares iBoxx $ High Yid Corp Bond (ETF)",
  "iShares IBoxx $ Invest Grade Corp Bd Fd",
  "iShares Russell 2000 Index (ETF)",
  "iShares 1-3 Year Treasury Bond",
  "iShares Barclays 7-10 Year Trasry Bnd Fd",
  "iShares Barclays Aggregate Bond Fund",
  "iShares Barclays 20+ Yr Treas.Bond (ETF)")


getSymbols(symbols, from="1990-01-01")





frequency <- "weekly"
lookback <- 39
prices <- getPrices(symbols, "weekly")
returns <- getReturns(symbols, "weekly")
mom <- apply(prices, 2, FUN = function(c) MOM(c, 39))
protection <- 2
bf <- BF(mom, risk_on, protection)
mom.rank <- t(apply(mom[, risk_on], 1, rank, ties.method="min"))
top <- 6
mom.rank[mom.rank > top] <- 0

weights.risk_on <- mom.rank
weights.risk_on[weights.risk_on > 0] <- 1
weights.risk_on <- weights.risk_on * (1 - bf) / top

risk_off.count <- length(risk_off)
weights.risk_off <-  matrix(rep(bf / risk_off.count, risk_off.count), ncol = risk_off.count)
colnames(weights.risk_off) <- risk_off

weights <- cbind(weights.risk_on, weights.risk_off)

strategy <- lag(weights) * returns
strategy.returns <- xts(rowSums(strategy), order.by = index(returns))


cbind(
  table.AnnualizedReturns(strategy.returns),
  maxDrawdown(strategy.returns),
  CalmarRatio(strategy.returns))
