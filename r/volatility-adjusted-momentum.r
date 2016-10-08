require(xts)
require(quantmod)
require(PerformanceAnalytics)
require(TTR)
library(Quandl)

setwd("D:/Github/quant-intro/r")
setwd("C:/Code/github/quant-intro/r")

source("secret.r")
Quandl.api_key(api_key = quandl.apikey)

# download daily S&P 500 prices from 1 Jan 1950 forward
gspc <-getSymbols('^gspc', from='1900-12-31', auto.assign=FALSE)

volAdjustedSmaCrossOver <- function(periods, pcs, calc = "close", vol.periods = 10) {
  rtns <- Return.calculate(Cl(pcs))
  vol <- volatility(pcs, calc = calc, n = vol.periods)
  rtns.voladj <- rtns / vol
  sma <- SMA(rtns.voladj, periods)
  signal <- ifelse(sma >0,1,0)
  returns <- lag(signal) * rtns
  returns <- na.omit(returns)
  return(returns)
}

strategy.volsd <- volAdjustedSmaCrossOver(110, gspc, calc = "close", vol.periods = 200)
strategy.volyz <- volAdjustedSmaCrossOver(110, gspc, calc = "yang.zhang", vol.periods = 200)
strategy.buyandhold <- Return.calculate(Cl(gspc))
colnames(strategy.volsd) <- "volsd"
colnames(strategy.volyz) <- "volyz"
colnames(strategy.buyandhold) <- "Buy & hold"

getStrategies <- function(date) {
  return(cbind(strategy.volyz[date], 
               strategy.volsd[date], 
               strategy.buyandhold[date]))
}

strategies <- getStrategies("2009-03-01::")
rbind(
  table.AnnualizedReturns(strategies),
  maxDrawdown(strategies),
  CalmarRatio(strategies))

sr <- matrix(nrow = 365, ncol = 365)
for(sma.window in seq(10, 365, 10)) {
  for(vol.window in seq(10, 365, 10)) {
    strategy <- volAdjustedSmaCrossOver(sma.window, gspc, calc = "close", vol.periods = vol.window)
    colnames(strategy) <- paste0(sma.window, " ", vol.window)
    r <- table.AnnualizedReturns(strategy)
    sr[sma.window, vol.window] <- r[3,]
  }
}


ief <- getSymbols("ief", from="1900-12-31", auto.assign=FALSE)
ief.returns <- Return.calculate(Ad(ief)) 
ief.volsd <- volAdjustedSmaCrossOver(110, ief, calc = "close", vol.periods = 200)

efa <- getSymbols("efa", from="1900-12-31", auto.assign=FALSE)
efa.returns <- Return.calculate(Ad(efa)) 
efa.volsd <- volAdjustedSmaCrossOver(110, efa, calc = "close", vol.periods = 200)

eem <- getSymbols("eem", from="1900-12-31", auto.assign=FALSE)
eem.returns <- Return.calculate(Ad(eem)) 
eem.volsd <- volAdjustedSmaCrossOver(110, eem, calc = "close", vol.periods = 200)

gld <- getSymbols("gld", from="1900-12-31", auto.assign=FALSE)
gld.returns <- Return.calculate(Ad(gld)) 
gld.volsd <- volAdjustedSmaCrossOver(110, gld, calc = "close", vol.periods = 200)

iyr <- getSymbols("iyr", from="1900-12-31", auto.assign=FALSE)
iyr.returns <- Return.calculate(Ad(iyr)) 
iyr.volsd <- volAdjustedSmaCrossOver(110, iyr, calc = "close", vol.periods = 200)


uup <- getSymbols("uup", from="1900-12-31", auto.assign=FALSE)
uup.returns <- Return.calculate(Ad(uup)) 
uup.volsd <- volAdjustedSmaCrossOver(110, uup, calc = "close", vol.periods = 200)


volAdjustedSemiVarSmaCrossOver <- function(periods, pcs, calc = "close", vol.periods = 10) {
  rtns <- Return.calculate(Cl(pcs))
  rtns <- rtns[rtns<0]
  vol <- volatility(pcs, calc = calc, n = vol.periods)
  rtns.voladj <- rtns / vol
  sma <- SMA(rtns.voladj, periods)
  signal <- ifelse(sma >0,1,0)
  returns <- lag(signal) * rtns
  returns <- na.omit(returns)
  return(returns)
}



"QQQ", # NASDAQ- 100 Index Tracking Stock
"EFA", #, # iShares MSCI EAFE Index Fund (ETF)
"EEM", # iShares MSCI Emerging Markets Indx (ETF)
"GLD", # SPDR Gold Trust (ETF)
"GSG", # iShares S&P GSCI Commodity-Indexed Trust
"IYR", # iShares Dow Jones US Real Estate (ETF)
"UUP", # PowerShares DB US Dollar Bullish ETF
"HYG", # iShares iBoxx $ High Yid Corp Bond (ETF)
"LQD", # iShares IBoxx $ Invest Grade Corp Bd Fd
"IWM") # iShares Russell 2000 Index (ETF)




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
