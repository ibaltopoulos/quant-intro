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
               gspc.returns[date], 
               strategy.pricesma[date]))
}

strategies <- getStrategies("1959-05-15::")
  cbind(strategy.volyz, strategy.volsd, gspc.returns, strategy.pricesma)

rbind(
  table.AnnualizedReturns(strategies),
  maxDrawdown(strategies),
  CalmarRatio(strategies))

setwd("D:/Github/quant-intro/r")
ogef <- read.csv("prices.csv")
ogef.xts <- xts(ogef$Price, order.by = as.Date(ogef$ï..Date))

ogef.returns <- Return.calculate(ogef.xts)
ogef.volatility <- volatility(ogef.xts, calc = "close", n = 10)
ogef.voladj <- ogef.returns / ogef.volatility

ogef.roc <- ROC(ogef.xts, 200) - ROC(ogef.xts, 7)
ogef.signal <- na.omit(Lag(ifelse(ogef.roc >0,1,0)))

ogef.sma <- SMA(ogef.voladj, 200)
ogef.signal <- na.omit(Lag(ifelse(ogef.sma >0,1,0)))

ogef.strategy <- ogef.signal * ogef.returns
colnames(ogef.strategy) <- "ogef timing"
colnames(ogef.returns) <- "ogef"

comparison <- cbind(ogef.returns, ogef.strategy)
