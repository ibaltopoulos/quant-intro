require(xts)
require(quantmod)
require(PerformanceAnalytics)
require(TTR)



# According to quantopian these are the ETFs and the weights
# https://www.quantopian.com/posts/all-seasons-strategy-from-tony-robbins-interview-with-ray-dalio
# 0.60, EDV
# 0.20, XIV
# 0.20, GLD

getReturns <- function(symbols, frequency) {
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
  colnames(prices) <- gsub("\\.[A-z]*", "", colnames(prices))
  returns <- Return.calculate(prices)
  
  return(returns)
}

symbols <- c("DBC", "GLD", "IEF", "SPY", "TLT")
getSymbols(symbols, from="1990-01-01")
portfolio.returns <- getReturns(symbols = symbols, frequency = "weekly")
portfolio.weights <- c(0.075, 0.075, 0.15, 0.30, 0.40)
strategy <-xts(x = rowSums(portfolio.returns * portfolio.weights), 
               order.by = index(portfolio.returns)) 

cbind(
  table.AnnualizedReturns(strategy),
  maxDrawdown(strategy),
  CalmarRatio(strategy))

symbols.alt <- c("EDV", "SPY", "XIV", "GLD")
getSymbols(symbols.alt, from="1990-01-01")
portfolio.alt.returns <- getReturns(symbols = symbols.alt, frequency = "weekly")
portfolio.alt.weights <- c(0.6, 0.25, 0.075, 0.075)
strategy.alt <-xts(x = rowSums(portfolio.alt.returns * portfolio.alt.weights), 
               order.by = index(portfolio.alt.returns)) 

cbind(
  table.AnnualizedReturns(strategy.alt),
  maxDrawdown(strategy.alt),
  CalmarRatio(strategy.alt))