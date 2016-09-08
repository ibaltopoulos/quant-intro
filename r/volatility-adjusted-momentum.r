require(xts)
require(quantmod)
require(PerformanceAnalytics)
require(TTR)


# download daily S&P 500 prices from Dec 31, 1990 forward
gspc <-getSymbols('^gspc', from='1900-12-31', auto.assign=FALSE)

gspc.returns <- Return.calculate(Cl(gspc))


gspc.volatility.yang.zhang <- volatility(gspc, calc = "yang.zhang", n = 10)
gspc.volatility.sd <- volatility(gspc, calc = "close", n = 10)

gspc.returns.volyz <- gspc.returns / gspc.volatility.yang.zhang
gspc.returns.volsd <- gspc.returns / gspc.volatility.sd

sma.gspc.price <- SMA(Cl(gspc), 200)
sma.gspc.rtnvolyz <- SMA(gspc.returns.volyz, 200)
sma.gspc.rtnvolsd <- SMA(gspc.returns.volsd, 200)

price.signal <- na.omit(Lag(ifelse(sma.gspc.price >0,1,0)))
rtnvolyz.signal <- na.omit(Lag(ifelse(sma.gspc.rtnvolyz >0,1,0)))
rtnvolsd.signal <- na.omit(Lag(ifelse(sma.gspc.rtnvolsd >0,1,0)))

strategy.pricesma <- price.signal * gspc.returns
strategy.volyz <- rtnvolyz.signal * gspc.returns
strategy.volsd <- rtnvolsd.signal * gspc.returns

colnames(strategy.pricesma) <- "smaprice"
colnames(strategy.volsd) <- "volsd"
colnames(strategy.volyz) <- "volyz"
colnames(gspc.returns) <- "gspc.returns"


getStrategies <- function(date) {
  return(cbind(strategy.volyz[date], 
               strategy.volsd[date], 
#               gspc.returns[date], 
               strategy.pricesma[date]))
}

strategies <- getStrategies("1955::")
  cbind(strategy.volyz, strategy.volsd, gspc.returns, strategy.pricesma)

rbind(
  table.AnnualizedReturns(strategies),
  maxDrawdown(strategies),
  CalmarRatio(strategies))


