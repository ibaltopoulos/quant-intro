library(downloader)
library(quantmod)
library(xts)
library(PerformanceAnalytics)

download("https://dl.dropboxusercontent.com/s/jk6der1s5lxtcfy/XIVlong.TXT",
         destfile="longXIV.txt")

download("https://dl.dropboxusercontent.com/s/950x55x7jtm9x2q/VXXlong.TXT", 
         destfile="longVXX.txt") #requires downloader package

xiv <- xts(read.zoo("longXIV.txt", format="%Y-%m-%d", sep=",", header=TRUE))
vxx <- xts(read.zoo("longVXX.txt", format="%Y-%m-%d", sep=",", header=TRUE))
vxmt <- xts(read.zoo("vxmtdailyprices.csv", format="%m/%d/%Y", sep=",", header=TRUE))
names(vxmt) <- c("Open", "High", "Low", "Close")
getSymbols("^VIX", from="2004-03-29")

vixvxmt <- merge(Cl(VIX), Cl(vxmt))
vixvxmt[is.na(vixvxmt[,2]),2] <- vixvxmt[is.na(vixvxmt[,2]),1]

getSymbols("^GSPC", from="1990-01-01")
spyRets <- diff(log(Cl(GSPC)))

spyVol <- runSD(spyRets, n=2)
annSpyVol <- spyVol*100*sqrt(252)

vols <- merge(vixvxmt[,2], annSpyVol, join='inner')
vols$smaDiff <- SMA(vols[,1] - vols[,2], n=5)
vols$signal <- vols$smaDiff > 0
vols$signal <- lag(vols$signal, k = 1)

xivRets <- Return.calculate(Cl(xiv))
vxxRets <- Return.calculate(Cl(vxx))
stratRets <- vols$signal*xivRets + (1-vols$signal)*vxxRets

charts.PerformanceSummary(stratRets)

stats <- data.frame(cbind(Return.annualized(stratRets)*100, 
                          maxDrawdown(stratRets)*100, 
                          SharpeRatio.annualized(stratRets)))

colnames(stats) <- c("Annualized Return", "Max Drawdown", "Annualized Sharpe")
stats$MAR <- as.numeric(stats[1])/as.numeric(stats[2])


library(changepoint)
require(xts)
require(quantmod)
require(PerformanceAnalytics)
require(TTR)
getSymbols('SPY', from = '1990-01-01', src = 'yahoo')
adjustedPrices <- Ad(SPY)
dev.new()
plot(adjustedPrices)
mvalue <- cpt.mean(SPY, method = "PELT")
cpts(mvalue)




