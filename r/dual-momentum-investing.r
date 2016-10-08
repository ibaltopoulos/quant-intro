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


getSymbols("^IRX", from="1900-01-01")
getSymbols("^GSPC", from="1900-01-01")

irx.dailyYield <- (1+(Cl(IRX)/100))^(1/252) - 1
irx.dailyPrice <- cumprod(1+dailyYield)

gspc.weekly <- to.weekly(GSPC)
irx.weekly <- to.weekly(irx.dailyPrice)

gspc.returns <- Return.calculate(Ad(gspc.weekly))
irx.returns <- Return.calculate(Cl(irx.weekly))                                 

startDate <- max(min(index(gspc.returns)), min(index(irx.returns)))
startDateFilter <- paste0(startDate,"::")
gspc.tr52wk8wk <- totalReturn(Ad(gspc.weekly), 52, 8)[startDateFilter]
irx.tr52wk <- totalReturn(Cl(irx.weekly), 52, 0)[startDateFilter]

signal <- ifelse(gspc.tr52wk8wk > irx.tr52wk, 1, 0)

strategy <- lag(signal) * gspc.returns[startDateFilter] + lag(1-signal) * irx.returns[startDateFilter]

strategies <- cbind(gspc.returns, irx.returns, strategy) 
colnames(strategies) <- c("GSPC", "TBill", "GSPC Absolute momentum")







getSymbols( "SPY", from="1900-01-01" )
getSymbols( "SHY", from="1900-01-01" )

spy.weekly <- to.weekly(SPY)
shy.weekly <- to.weekly(SHY)

spy.returns <- Return.calculate(Ad(spy.weekly))
shy.returns <- Return.calculate(Ad(shy.weekly))

totalReturn <- function(prices, longPeriod, shortPeriod) {
  ROC(prices, n = longPeriod, type = "discrete") - ROC(prices, n = shortPeriod, type = "discrete")
}

absoluteMomentum <- function(symbol, cash, longMomenrum = 52, shortMomentum = 0) {
  frequency <- "weekly"
  symbol.weekly <- getPrices(symbol, frequency)
  cash.weekly <- getPrices(cash, frequency)
  
  symbol.returns <- getReturns(symbol, frequency)
  cash.returns <- getReturns(cash, frequency)
  
  startDate <- max(min(index(symbol.returns)), min(index(cash.returns)))
  startDateFilter <- paste0(startDate,"::")
  
  symbol.tr52wk8wk <- totalReturn(Ad(symbol.weekly), longMomenrum, shortMomentum)[startDateFilter]
  cash.tr52wk <- totalReturn(Ad(cash.weekly), longMomenrum, 0)[startDateFilter]
  
  signal <- ifelse(symbol.tr52wk8wk > cash.tr52wk, 1, 0)
  
  strategy <- 
      lag(signal) * symbol.returns[startDateFilter] 
    + lag(1-signal) * cash.returns[startDateFilter]
  
  
  strategies <- cbind(symbol.returns, cash.returns, strategy)
  colnames(strategies) <- c(symbol, cash, paste0(symbol," - Absolute momentum"))
  
  return(strategies)
}

absoluteMomentum("SPY", "SHY")

spy.tr52wk8wk <- totalReturn(Ad(spy.weekly), 52, 8)["2003::"]
shy.tr52wk <- totalReturn(Ad(shy.weekly), 52, 0)["2003::"]

signal <- ifelse(spy.tr52wk8wk > shy.tr52wk, 1, 0)

strategy <- lag(signal) * spy.returns["2003::"] + lag(1-signal) * shy.returns["2003::"]

strategies <- cbind(spy.returns, shy.returns, strategy)
colnames(strategies) <- c("S&P", "T-Bill", "S&P Absolute momentum")

dev.new()
charts.PerformanceSummary(strategies)
t(table.AnnualizedReturns(strategies))
table.DownsideRisk(strategies)
table.DrawdownsRatio(strategies)


dev.new()
layout(rbind(c(1),c(2), c(3)))
chart.CumReturns(strategy)
chart.TimeSeries(signal)
chart.Drawdown(strategy)
