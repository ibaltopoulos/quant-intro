library(Quandl)
library(PerformanceAnalytics)
library(quantmod)

setwd("D:/Github/quant-intro/r")

source("secrets.r")

getSymbols("DGS10", src='FRED')  # 10-Year Treasury Constant Maturity Rate (Daily)
getSymbols("GS10", src='FRED')  # 10-Year Treasury Constant Maturity Rate (Monthly)

getSymbols("TB3MS", src='FRED') # 3-Month Treasury Bill: Secondary Market Rate (monthly)
getSymbols("DTB3", src='FRED') # 3-Month Treasury Bill: Secondary Market Rate (daily)

getSymbols("USRECD", src='FRED') # NBER based Recession Indicators for the United States from the Period following the Peak through the Trough

yield_spread <- GS10 - TB3MS

chart.TimeSeries(yield_spread)






getSymbols("DGS3MO", src='FRED')



Quandl.api_key(api_key = quandl.apikey)

snp500_index = Quandl("YAHOO/INDEX_GSPC", type="xts")
ustreasury_yield = Quandl("USTREASURY/YIELD", type="xts")

snp500_index <- na.locf(snp500_index)
ustreasury_yield <- na.locf(ustreasury_yield)



returns.snp500.close <- na.omit(Return.calculate(snp500_index$Close))
returns.ustreasury.10yr <- na.omit(Return.calculate(ustreasury_yield$"10 YR"))

returns <-merge(returns.snp500.close, returns.ustreasury.10yr, join="inner")

rcor <- rollapply(returns, 120, function(x) cor(x[,1], x[,2]), by.column = FALSE, align="right")

chart.TimeSeries(rcor)
plot(USRECD["1990::"])
rect()
