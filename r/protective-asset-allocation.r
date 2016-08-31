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

## Explore Mom(L)
cbind(head(SMA(Ad(GLD), 10), 20), head(Ad(GLD), 20), head(100 * (Ad(GLD) / SMA(Ad(GLD), 10)) - 1, 20))




frequency <- "weekly"
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


portfolio.returns <- getReturns(symbols = symbols, frequency = "monthly")
portfolio.weights <- c(0.075, 0.075, 0.15, 0.30, 0.40)
strategy <-xts(x = rowSums(portfolio.returns * portfolio.weights), 
               order.by = index(portfolio.returns)) 





getSymbols(symbols, from = "1990-01-01")
prices.daily <- list()
for(i in 1:length(symbols)) {
  prices.daily[[i]] <- Ad(get(symbols[i]))  
}
prices.daily <- do.call(cbind, prices.daily)
prices.daily <- na.omit(prices.daily)
colnames(prices.daily) <- gsub("\\.[A-z]*", "", colnames(prices.daily))
