library(Quandl)
library(PerformanceAnalytics)
library(TTR)
library(quantmod)

# http://mebfaber.com/2016/09/09/coppock-curve-applied-global-markets/

setwd("D:/Github/quant-intro/r")

source("secrets.r")
Quandl.api_key(api_key = quandl.apikey)

shiller_pe = Quandl("MULTPL/SHILLER_PE_RATIO_MONTH", type="xts")
snp_composite = Quandl("YALE/SPCOMP", type="xts") 

snp_index <- snp_composite[,1]

snp_roc14 <- ROC(snp_index, n = 14)
snp_roc11 <- ROC(snp_index, n = 11)

coppock <- xts(WMA(snp_roc14 + snp_roc11, n = 10), order.by = index(snp_index))

signal <- Lag(ifelse(coppock < 0, 1, 0))

snp_rtns <- Return.calculate(snp_index)
colnames(snp_rtns) <- "S&P Composite"

strategy <- signal * snp_rtns
colnames(strategy) <- "strategy"
table.AnnualizedReturns(cbind(strategy, snp_rtns))
