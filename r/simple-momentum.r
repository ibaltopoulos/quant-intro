require(xts)
require(quantmod)
require(PerformanceAnalytics)
require(TTR)

getSymbols('SPY', from = '1990-01-01', src = 'yahoo')
adjustedPrices <- Ad(SPY)
monthlyAdj <- to.monthly(adjustedPrices, OHLC=TRUE)

spySMA <- SMA(Cl(monthlyAdj), 10)
spyROC <- ROC(Cl(monthlyAdj), 10)
spyRets <- Return.calculate(Cl(monthlyAdj))

smaRatio <- Cl(monthlyAdj)/spySMA - 1
smaSig <- smaRatio > 0
rocSig <- spyROC > 0

smaRets <- lag(smaSig) * spyRets
rocRets <- lag(rocSig) * spyRets

strats <- na.omit(cbind(smaRets, rocRets, spyRets))
colnames(strats) <- c("SMA10", "MOM10", "BuyHold")
charts.PerformanceSummary(strats, main = "strategies")
rbind(table.AnnualizedReturns(strats), maxDrawdown(strats), CalmarRatio(strats))

predictorsAndPredicted <- na.omit(cbind(lag(smaRatio), lag(spyROC), spyRets))
R2s <- list()
for(i in 1:(nrow(predictorsAndPredicted)-59))  { #rolling five-year regression
  subset <- predictorsAndPredicted[i:(i+59),]
  smaLM <- lm(subset[,3]~subset[,1])
  smaR2 <- summary(smaLM)$r.squared
  rocLM <- lm(subset[,3]~subset[,2])
  rocR2 <- summary(rocLM)$r.squared
  R2row <- xts(cbind(smaR2, rocR2), order.by=last(index(subset)))
  R2s[[i]] <- R2row
}
R2s <- do.call(rbind, R2s)
par(mfrow=c(1,1))
colnames(R2s) <- c("SMA", "Momentum")
chart.TimeSeries(R2s, main = "R2s", legend.loc = 'topleft')







## Evaluate the strategy described here
## http://seekingalpha.com/article/3401315-plan-to-survive-be-systematic-part-2
require(PerformanceAnalytics)
require(downloader)
require(quantmod)

getSymbols('XLP', from = '1900-01-01')
getSymbols('TLT', from = '1900-01-01')
getSymbols('UUP', from = '1900-01-01')
download('https://dl.dropboxusercontent.com/s/jk3ortdyru4sg4n/ZIVlong.TXT', destfile='ZIVlong.csv')
download('https://dl.dropboxusercontent.com/s/950x55x7jtm9x2q/VXXlong.TXT', destfile = 'VXXlong.csv')
ZIV <- xts(read.zoo('ZIVlong.csv', header=TRUE, sep=','))
VXX <- xts(read.zoo('VXXlong.csv', header=TRUE, sep=','))

symbols <- na.omit(cbind(Return.calculate(Cl(ZIV)), Return.calculate(Ad(XLP)), Return.calculate(Ad(TLT))*3,
                         Return.calculate(Ad(UUP)), Return.calculate(Cl(VXX))))
strat <- Return.portfolio(symbols, weights = c(.15, .5, .1, .2, .05), rebalance_on='years')

compare <- na.omit(cbind(strat, Return.calculate(Ad(XLP))))
charts.PerformanceSummary(compare)
rbind(table.AnnualizedReturns(compare), maxDrawdown(compare), CalmarRatio(compare))


## Test sensitivity of result on the rebalancing date
yearlyEp <- endpoints(symbols, on = 'years')
rebalanceDays <- list()
for(i in 0:251) {
  offset <- yearlyEp+i
  offset[offset > nrow(symbols)] <- nrow(symbols)
  offset[offset==0] <- 1
  wts <- matrix(rep(c(.15, .5, .1, .2, .05), length(yearlyEp)), ncol=5, byrow=TRUE)
  wts <- xts(wts, order.by=as.Date(index(symbols)[offset]))
  offsetRets <- Return.portfolio(R = symbols, weights = wts)
  colnames(offsetRets) <- paste0("offset", i)
  rebalanceDays[[i+1]] <- offsetRets
}
rebalanceDays <- do.call(cbind, rebalanceDays)
rebalanceDays <- na.omit(rebalanceDays)
stats <- rbind(table.AnnualizedReturns(rebalanceDays), maxDrawdown(rebalanceDays))
stats[5,] <- stats[1,]/stats[4,]


plot(as.numeric(stats[1,])~c(0:251), type='l', ylab='CAGR', xlab='offset', main='CAGR vs. offset')
plot(as.numeric(stats[3,])~c(0:251), type='l', ylab='Sharpe Ratio', xlab='offset', main='Sharpe vs. offset')
plot(as.numeric(stats[5,])~c(0:251), type='l', ylab='Calmar Ratio', xlab='offset', main='Calmar vs. offset')
plot(as.numeric(stats[4,])~c(0:251), type='l', ylab='Drawdown', xlab='offset', main='Drawdown vs. offset')

rownames(stats)[5] <- "Calmar"
apply(stats, 1, quantile)




### Global market rotation strategy
require(quantmod)
require(PerformanceAnalytics)

symbols <- c("MDY", "TLT", "EEM", "ILF", "EPP", "FEZ")
getSymbols(symbols, from="1990-01-01")
prices <- list()
for(i in 1:length(symbols)) {
  prices[[i]] <- Ad(get(symbols[i]))
}
prices <- do.call(cbind, prices)
colnames(prices) <- gsub("\\.[A-z]*", "", colnames(prices))
returns <- Return.calculate(prices)
returns <- na.omit(returns)

logicInvestGMR <- function(returns, lookback = 3) {
  ep <- endpoints(returns, on = "months") 
  weights <- list()
  for(i in 2:(length(ep) - lookback)) {
    retSubset <- returns[ep[i]:ep[i+lookback],]
    cumRets <- Return.cumulative(retSubset)
    rankCum <- rank(cumRets)
    weight <- rep(0, ncol(retSubset))
    weight[which.max(cumRets)] <- 1
    weight <- xts(t(weight), order.by=index(last(retSubset)))
    weights[[i]] <- weight
  }
  weights <- do.call(rbind, weights)
  stratRets <- Return.portfolio(R = returns, weights = weights)
  return(stratRets)
}

gmr <- logicInvestGMR(returns)
charts.PerformanceSummary(gmr)

rbind(table.AnnualizedReturns(gmr), maxDrawdown(gmr), CalmarRatio(gmr))



### 
symbols <- c("GMOM", "QVAL", "IVAL", "GVAL", "GAA")

getSymbols(symbols, from = "1990-01-01")
prices <- list()
for(i in 1:length(symbols)) {
  prices[[i]] <- Ad(get(symbols[i]))  
}
prices <- do.call(cbind, prices)
colnames(prices) <- gsub("\\.[A-z]*", "", colnames(prices))

coolEtfReturns <- Return.calculate(prices)
coolEtfReturns <- na.omit(coolEtfReturns)
charts.PerformanceSummary(coolEtfReturns, main = "Quant investing for retail people.")

stats <- rbind(table.AnnualizedReturns(coolEtfReturns),
               maxDrawdown(coolEtfReturns),
               CalmarRatio(coolEtfReturns),
               SortinoRatio(coolEtfReturns) * sqrt(252))
round(stats, 3)



### a basic XL-sector/RWR rotation strategy

require(quantmod)
require(PerformanceAnalytics)
symbols <- c("XLB", "XLE", "XLF", "XLI", "XLK", "XLP", "XLU", "XLV", "XLY", "RWR", "SHY")
getSymbols(symbols, from="1990-01-01")
prices <- list()
for(i in 1:length(symbols)) {
  prices[[i]] <- Ad(get(symbols[i]))  
}
prices <- do.call(cbind, prices)
colnames(prices) <- gsub("\\.[A-z]*", "", colnames(prices))
returns <- na.omit(Return.calculate(prices))


sctoStrat <- function(returns, cashAsset = "SHY", lookback = 4, annVolLimit = .2,
                      topN = 5, scale = 252) {
  ep <- endpoints(returns, on = "months")
  weights <- list()
  cashCol <- grep(cashAsset, colnames(returns))
  
  #remove cash from asset returns
  cashRets <- returns[, cashCol]
  assetRets <- returns[, -cashCol]
  for(i in 2:(length(ep) - lookback)) {
    retSubset <- assetRets[ep[i]:ep[i+lookback]]
    
    #forecast is the cumulative return of the lookback period
    forecast <- Return.cumulative(retSubset)
    
    #annualized (realized) volatility uses a 22-day lookback period
    annVol <- StdDev.annualized(tail(retSubset, 22))
    
    #rank the forecasts (the cumulative returns of the lookback)
    rankForecast <- rank(forecast) - ncol(assetRets) + topN
    
    #weight is inversely proportional to annualized vol
    weight <- 1/annVol
    
    #zero out anything not in the top N assets
    weight[rankForecast <= 0] <- 0
    
    #normalize and zero out anything with a negative return
    weight <- weight/sum(weight)
    weight[forecast < 0] <- 0
    
    #compute forecasted vol of portfolio
    forecastVol <- sqrt(as.numeric(t(weight)) %*% 
                          cov(retSubset) %*% 
                          as.numeric(weight)) * sqrt(scale)
    
    #if forecasted vol greater than vol limit, cut it down
    if(as.numeric(forecastVol) > annVolLimit) {
      weight <- weight * annVolLimit/as.numeric(forecastVol)
    }
    weights[[i]] <- xts(weight, order.by=index(tail(retSubset, 1)))
  }
  
  #replace cash back into returns
  returns <- cbind(assetRets, cashRets)
  weights <- do.call(rbind, weights)
  
  #cash weights are anything not in securities
  weights$CASH <- 1-rowSums(weights)
  
  #compute and return strategy returns
  stratRets <- Return.portfolio(R = returns, weights = weights)
  return(stratRets)      
}


scto4_20 <- sctoStrat(returns)
getSymbols("SPY", from = "1990-01-01")
spyRets <- Return.calculate(Ad(SPY))
comparison <- na.omit(cbind(scto4_20, spyRets))
colnames(comparison) <- c("strategy", "SPY")
charts.PerformanceSummary(comparison)
apply.yearly(comparison, Return.cumulative)
stats <- rbind(table.AnnualizedReturns(comparison),
               maxDrawdown(comparison),
               CalmarRatio(comparison),
               SortinoRatio(comparison)*sqrt(252))
round(stats, 3)





### https://quantstrattrader.wordpress.com/2015/02/23/the-logical-invest-universal-investment-strategy-a-walk-forward-process-on-spy-and-tlt/
require(quantmod)
require(PerformanceAnalytics)
getSymbols(c("SPY", "TLT"), from="1990-01-01")
returns <- merge(Return.calculate(Ad(SPY)), Return.calculate(Ad(TLT)), join='inner')
returns <- returns[-1,]
configs <- list()
for(i in 1:21) {
  weightSPY <- (i-1)*.05
  weightTLT <- 1-weightSPY
  config <- Return.portfolio(R = returns, weights=c(weightSPY, weightTLT), rebalance_on = "months")
  configs[[i]] <- config
}
configs <- do.call(cbind, configs)
cumRets <- cumprod(1+configs)
period <- 72

roll72CumAnn <- (cumRets/lag(cumRets, period))^(252/period) - 1
roll72SD <- sapply(X = configs, runSD, n=period)*sqrt(252)


sd_f_factor <- 2.5
modSharpe <- roll72CumAnn/roll72SD^sd_f_factor
monthlyModSharpe <- modSharpe[endpoints(modSharpe, on="months"),]

findMax <- function(data) {
  return(data==max(data))
}

weights <- t(apply(monthlyModSharpe, 1, findMax))
weights <- weights*1
weights <- xts(weights, order.by=as.Date(rownames(weights)))
weights[is.na(weights)] <- 0
weights$zeroes <- 1-rowSums(weights)
configs$zeroes <- 0

stratRets <- Return.portfolio(R = configs, weights = weights)
rbind(table.AnnualizedReturns(stratRets), maxDrawdown(stratRets))
charts.PerformanceSummary(stratRets)

stratAndComponents <- merge(returns, stratRets, join='inner')
charts.PerformanceSummary(stratAndComponents)
rbind(table.AnnualizedReturns(stratAndComponents), maxDrawdown(stratAndComponents))
apply.yearly(stratAndComponents, Return.cumulative)

weightSPY <- apply(monthlyModSharpe, 1, which.max)
weightSPY <- do.call(rbind, weightSPY)
weightSPY <- (weightSPY-1)*.05
align <- cbind(weightSPY, stratRets)
align <- na.locf(align)
chart.TimeSeries(align[,1], date.format="%Y", ylab="Weight SPY", main="Weight of SPY in SPY-TLT pair")




## https://quantstrattrader.wordpress.com/2015/04/08/the-logical-invest-enhanced-bond-rotation-strategy-and-the-importance-of-dividends/
LogicInvestEBR <- function(returns, lowerBound, upperBound, period, modSharpeF) {
  count <- 0
  configs <- list()
  instCombos <- combn(colnames(returns), m = 2)
  for(i in 1:ncol(instCombos)) {
    inst1 <- instCombos[1, i]
    inst2 <- instCombos[2, i]
    rets <- returns[,c(inst1, inst2)]
    weightSeq <- seq(lowerBound, upperBound, by = .1)
    for(j in 1:length(weightSeq)) {
      returnConfig <- Return.portfolio(R = rets, 
                                       weights = c(weightSeq[j], 1-weightSeq[j]), 
                                       rebalance_on="months")
      colnames(returnConfig) <- paste(inst1, weightSeq[j], 
                                      inst2, 1-weightSeq[j], sep="_")
      count <- count + 1
      configs[[count]] <- returnConfig
    }
  }
  
  configs <- do.call(cbind, configs)
  cumRets <- cumprod(1+configs)
  
  #rolling cumulative 
  rollAnnRets <- (cumRets/lag(cumRets, period))^(252/period) - 1
  rollingSD <- sapply(X = configs, runSD, n=period)*sqrt(252)
  
  modSharpe <- rollAnnRets/(rollingSD ^ modSharpeF)
  monthlyModSharpe <- modSharpe[endpoints(modSharpe, on="months"),]
  
  findMax <- function(data) {
    return(data==max(data))
  }
  
  #configs$zeroes <- 0 #zeroes for initial periods during calibration
  weights <- t(apply(monthlyModSharpe, 1, findMax))
  weights <- weights*1
  weights <- xts(weights, order.by=as.Date(rownames(weights)))
  weights[is.na(weights)] <- 0
  weights$zeroes <- 1-rowSums(weights)
  configCopy <- configs
  configCopy$zeroes <- 0
  
  stratRets <- Return.portfolio(R = configCopy, weights = weights)
  return(stratRets)  
}


symbols <- c("TLT", "JNK", "PCY", "CWB", "VUSTX", "PRHYX", "RPIBX", "VCVSX")
suppressMessages(getSymbols(symbols, from="1995-01-01", src="yahoo"))
etfClose <- Return.calculate(cbind(Cl(TLT), Cl(JNK), Cl(PCY), Cl(CWB)))
etfAdj <- Return.calculate(cbind(Ad(TLT), Ad(JNK), Ad(PCY), Ad(CWB)))
mfClose <- Return.calculate(cbind(Cl(VUSTX), Cl(PRHYX), Cl(RPIBX), Cl(VCVSX)))
mfAdj <- Return.calculate(cbind(Ad(VUSTX), Ad(PRHYX), Ad(RPIBX), Ad(VCVSX)))
colnames(etfClose) <- colnames(etfAdj) <- c("TLT", "JNK", "PCY", "CWB")
colnames(mfClose) <- colnames(mfAdj) <- c("VUSTX", "PRHYX", "RPIBX", "VCVSX")

etfClose <- etfClose[!is.na(etfClose[,4]),]
etfAdj <- etfAdj[!is.na(etfAdj[,4]),]
mfClose <- mfClose[-1,]
mfAdj <- mfAdj[-1,]

etfAdjTest <- LogicInvestEBR(returns = etfAdj, lowerBound = .4, upperBound = .6,
                             period = 73, modSharpeF = 2)

etfClTest <- LogicInvestEBR(returns = etfClose, lowerBound = .4, upperBound = .6,
                            period = 73, modSharpeF = 2)

mfAdjTest <- LogicInvestEBR(returns = mfAdj, lowerBound = .4, upperBound = .6,
                            period = 73, modSharpeF = 2)

mfClTest <- LogicInvestEBR(returns = mfClose, lowerBound = .4, upperBound = .6,
                           period = 73, modSharpeF = 2)

fiveStats <- function(returns) {
  return(rbind(table.AnnualizedReturns(returns), 
               maxDrawdown(returns), CalmarRatio(returns)))
}

etfs <- cbind(etfAdjTest, etfClTest)
colnames(etfs) <- c("Adjusted ETFs", "Close ETFs")
charts.PerformanceSummary((etfs))

mutualFunds <- cbind(mfAdjTest, mfClTest)
colnames(mutualFunds) <- c("Adjusted MFs", "Close MFs")
charts.PerformanceSummary(mutualFunds)
chart.TimeSeries(log(cumprod(1+mutualFunds)), legend.loc="topleft")

fiveStats(etfs)
fiveStats(mutualFunds)








### Percentile chennels
require(quantmod)
require(caTools)
require(PerformanceAnalytics)
require(TTR)
getSymbols(c("LQD", "DBC", "VTI", "ICF", "SHY"), from="1990-01-01")

prices <- cbind(Ad(LQD), Ad(DBC), Ad(VTI), Ad(ICF), Ad(SHY))
prices <- prices[!is.na(prices[,2]),]
returns <- Return.calculate(prices)
cashPrices <- prices[, 5]
assetPrices <- prices[, -5]

require(caTools)
pctChannelPosition <- function(prices,
                               dayLookback = 60, 
                               lowerPct = .25, upperPct = .75) {
  leadingNAs <- matrix(nrow=dayLookback-1, ncol=ncol(prices), NA)
  
  upperChannels <- runquantile(prices, k=dayLookback, probs=upperPct, endrule="trim")
  upperQ <- xts(rbind(leadingNAs, upperChannels), order.by=index(prices))
  
  lowerChannels <- runquantile(prices, k=dayLookback, probs=lowerPct, endrule="trim")
  lowerQ <- xts(rbind(leadingNAs, lowerChannels), order.by=index(prices))
  
  positions <- xts(matrix(nrow=nrow(prices), ncol=ncol(prices), NA), order.by=index(prices))
  positions[prices > upperQ & lag(prices) < upperQ] <- 1 #cross up
  positions[prices < lowerQ & lag(prices) > lowerQ] <- -1 #cross down
  positions <- na.locf(positions)
  positions[is.na(positions)] <- 0
  
  colnames(positions) <- colnames(prices)
  return(positions)
}

#find our positions, add them up
d60 <- pctChannelPosition(assetPrices)
d120 <- pctChannelPosition(assetPrices, dayLookback = 120)
d180 <- pctChannelPosition(assetPrices, dayLookback = 180)
d252 <- pctChannelPosition(assetPrices, dayLookback = 252)
compositePosition <- (d60 + d120 + d180 + d252)/4

compositeMonths <- compositePosition[endpoints(compositePosition, on="months"),]

returns <- Return.calculate(prices)
monthlySD20 <- xts(sapply(returns[,-5], runSD, n=20), order.by=index(prices))[index(compositeMonths),]
weight <- compositeMonths*1/monthlySD20
weight <- abs(weight)/rowSums(abs(weight))
weight[compositeMonths < 0 | is.na(weight)] <- 0
weight$CASH <- 1-rowSums(weight)

#not actually equal weight--more like composite weight, going with 
#Michael Kapler's terminology here
ewWeight <- abs(compositeMonths)/rowSums(abs(compositeMonths))
ewWeight[compositeMonths < 0 | is.na(ewWeight)] <- 0
ewWeight$CASH <- 1-rowSums(ewWeight)

rpRets <- Return.portfolio(R = returns, weights = weight)
ewRets <- Return.portfolio(R = returns, weights = ewWeight)


both <- cbind(rpRets, ewRets)
colnames(both) <- c("RiskParity", "Equal Weight")
charts.PerformanceSummary(both)
rbind(table.AnnualizedReturns(both), maxDrawdown(both))
apply.yearly(both, Return.cumulative)





### Protective Asset Allocation (PAA) 
# http://indexswingtrader.blogspot.co.uk/2016/04/introducing-protective-asset-allocation.html
# http://indexswingtrader.blogspot.co.uk/p/strategy-signals.html



### The PAA model will be backtested from Dec 1970 - Dec 2015 (45 years) on monthly total return data (see paper for data construction). The universe of choice is a global diversified multi-asset universe consisting of proxies for 12 so called "risky" ETFs: SPY, QQQ, IWM (US equities: S&P500, Nasdaq100 and Russell2000 Small Cap), VGK, EWJ (Developed International Market equities: Europe and Japan), EEM (Emerging Market equities), IYR, GSG, GLD (Alternatives: REIT, Commodities, Gold), HYG, LQD and TLT (US High Yield bonds, US Investment Grade Corporate bonds and Long Term US Treasuries). The broadness of the universe makes it suitable for harvesting risk premia during different economical regimes. 



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

getSymbols(symbols, from = "1990-01-01")
prices.daily <- list()
for(i in 1:length(symbols)) {
  prices.daily[[i]] <- Ad(get(symbols[i]))  
}
prices.daily <- do.call(cbind, prices.daily)
prices.daily <- na.omit(prices.daily)
colnames(prices.daily) <- gsub("\\.[A-z]*", "", colnames(prices.daily))

returns.daily <- na.omit(Return.calculate(prices.daily))


prices.monthly <- xts(apply(prices.daily, 2, function(x) Cl(to.monthly(x))), 
                      order.by=index(to.monthly(prices.daily)))
prices.weekly <- xts(apply(prices.daily, 2, function(x) Cl(to.weekly(x))), 
                     order.by=index(to.weekly(prices.daily)))
  
  Cl(to.monthly(prices.daily))





ep <- endpoints(returns, on = "months")

prices.monthly <- endpoints(prices, on = "months")

prices[prices.monthly]

prices.weekly <- prices[endpoints(prices, on = "weeks")]


sma39wk <- function(x)  SMA(x, n=39)
sma.prices  <- xts(apply(prices.weekly, 2, sma39wk), 
                   order.by=index(prices.weekly) ) 

plot(prices.weekly[,1])
lines(sma.prices[,1], col="red")


lines(prices.weekly[,1])
head(prices.weekly)

plot(sma.prices)
lines(prices.weekly, col="red")





getSymbols('SPY', from = '1990-01-01', src = 'yahoo')
adjustedPrices <- Ad(SPY)
monthlyAdj <- to.monthly(adjustedPrices, OHLC=TRUE)

spySMA <- SMA(Cl(monthlyAdj), 10)
spyROC <- ROC(Cl(monthlyAdj), 10)
spyRets <- Return.calculate(Cl(monthlyAdj))

smaRatio <- Cl(monthlyAdj)/spySMA - 1
smaSig <- smaRatio > 0
rocSig <- spyROC > 0

smaRets <- lag(smaSig) * spyRets
rocRets <- lag(rocSig) * spyRets

strats <- na.omit(cbind(smaRets, rocRets, spyRets))
colnames(strats) <- c("SMA10", "MOM10", "BuyHold")
charts.PerformanceSummary(strats, main = "strategies")
rbind(table.AnnualizedReturns(strats), maxDrawdown(strats), CalmarRatio(strats))







prices.weekly.sma <- apply(prices.weekly, 



weights <- list()
#remove cash from asset returns
riskOffRets <- returns[, risk_off]
riskOnRets <- returns[, risk_on]

prices.sma <- SMA(prices[,1], n = 60)
plot(prices.sma)
lines(prices[,1], col="red")
dev.new()

lookback <- 1
i<-2
rank(Return.cumulative(riskOnRets[ep[i]:ep[i+1]]))





for(i in 2:(length(ep) - lookback)) {
  retSubset <- riskOnRets[ep[i]:ep[i+lookback]]
  
  #forecast is the cumulative return of the lookback period
  forecast <- Return.cumulative(retSubset)
  
  #annualized (realized) volatility uses a 22-day lookback period
  annVol <- StdDev.annualized(tail(retSubset, 22))
  
  #rank the forecasts (the cumulative returns of the lookback)
  rankForecast <- rank(forecast) - ncol(assetRets) + topN
  
  #weight is inversely proportional to annualized vol
  weight <- 1/annVol
  
  #zero out anything not in the top N assets
  weight[rankForecast <= 0] <- 0
  
  #normalize and zero out anything with a negative return
  weight <- weight/sum(weight)
  weight[forecast < 0] <- 0
  
  #compute forecasted vol of portfolio
  forecastVol <- sqrt(as.numeric(t(weight)) %*% 
                        cov(retSubset) %*% 
                        as.numeric(weight)) * sqrt(scale)
  
  #if forecasted vol greater than vol limit, cut it down
  if(as.numeric(forecastVol) > annVolLimit) {
    weight <- weight * annVolLimit/as.numeric(forecastVol)
  }
  weights[[i]] <- xts(weight, order.by=index(tail(retSubset, 1)))
}


