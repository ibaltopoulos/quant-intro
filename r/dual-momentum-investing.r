require(xts)
require(quantmod)
require(PerformanceAnalytics)
require(TTR)




category <- c("Domestic Large Cap", 
              "Domestic Mid Cap", 
              "Domestic Small Cap", 
              "Domestic Micro Cap", 
              "Foreign Developed Stocks", 
              "Foreign Emerging Stocks",
              "Foreign Developed Small Cap",
              "Foreign Emerging Small Cap",
              "Domestic Bonds",
              "TIPS",
              "Foreign Bonds",
              "Emerging Bonds",
              "Real Estate",
              "Foreign Real Estate",
              "Infrastructure",
              "Timber",
              "Commodities - Agriculture",
              "Commodities - Energy",
              "Commodities - Base Metals",
              "Commodities - Precious Metals")

products <- c("Vanguard Total Stock Market ETF",
              "Vanguard Mid-Cap ETF", 
              "Vanguard Small-Cap ETF", 
              "iShares Micro-Cap ETF",
              "Vanguard FTSE All-World ex-US ETF",
              "Vanguard FTSE Emerging Markets ETF",
              "SPDR S&P International Small Cap ETF",
              "SPDR S&P Emerging Markets Small Cap ETF",
              "Vanguard Total Bond Market ETF",
              "iShares TIPS Bond ETF",
              "SPDR Barclays International Treasury Bond ETF",
              "Western Asset Emerging Markets Debt Fund",
              "Vanguard REIT Index Fund", 
              "SPDR Dow Jones® International Real Estate ETF",
              "iShares Global Infrastructure ETF",
              "Cambium Global Timberland Limited",
              "PowerShares DB Agriculture ETF",
              "PowerShares DB Energy ETF",
              "PowerShares DB Base Metals ETF",
              "PowerShares DB Precious Metals ETF")
symbols <- c(
  "VTI",
  "VO", 
  "VB",
  "IWC",
  "VEU",
  "VWO",
  "GWX",
  "EWX",
  "BND",
  "TIP",
  "BWX",
  "ESD",
  "VNQ",
  "RWX",
  "IGF",
  "TREE.L",
  "DBA",
  "DBE",
  "DBB",
  "DBP")




getPrices <- function(symbols, frequency) {
  prices <- list()
  for(i in 1:length(symbols)) {
    adjustedPrices <- Ad(get(symbols[i], envir = globalenv()))
    colnames(adjustedPrices) <- gsub("\\.[A-z]*", "", colnames(adjustedPrices))
    prices[[i]] <-
      Cl(switch(frequency,
                daily = to.daily(adjustedPrices),
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


gem.symbols <- c("IVV", "BND", "VEU")
cash <- c("BIL")
frequency <- "weekly"
getSymbols(c(gem.symbols, cash), from="1990-01-01")
prices <- getPrices(gem.symbols, frequency)
returns <- getReturns(gem.symbols, frequency)

getSymbols( "SPY", from="1900-01-01" )
getSymbols( "SHY", from="1900-01-01" )

spy.weekly <- to.weekly(SPY)
shy.weekly <- to.weekly(SHY)

spy.returns <- Return.calculate(Ad(spy.weekly))
shy.returns <- Return.calculate(Ad(shy.weekly))

totalReturn <- function(prices, longPeriod, shortPeriod) {
  ROC(prices, n = longPeriod, type = "discrete") - ROC(prices, n = shortPeriod, type = "discrete")
}

spy.tr52wk8wk <- totalReturn(Ad(spy.weekly), 52, 8)["2003::"]
shy.tr52wk <- totalReturn(Ad(shy.weekly), 52, 0)["2003::"]

signal <- ifelse(spy.tr52wk8wk > shy.tr52wk, 1, 0)

strategy <- lag(signal) * spy.returns["2003::"] + lag(1-signal) * shy.returns["2003::"]

dev.new()
charts.PerformanceSummary(strategy)
table.AnnualizedReturns(strategy)

dev.new()
layout(rbind(c(1),c(2), c(3)))
chart.CumReturns(strategy)
chart.TimeSeries(signal)
chart.Drawdown(strategy)
