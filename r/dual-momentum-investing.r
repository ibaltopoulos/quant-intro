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
  
  symbol.tr52wk8wk <- totalReturn(symbol.weekly, longMomenrum, shortMomentum)[startDateFilter]
  cash.tr52wk <- totalReturn(cash.weekly, longMomenrum, 0)[startDateFilter]
  
  signal <- ifelse(symbol.tr52wk8wk > cash.tr52wk, 1, 0)
  
  strategy <- 
      lag(signal) * symbol.returns[startDateFilter] 
    + lag(1-signal) * cash.returns[startDateFilter]
  
  
  strategies <- cbind(symbol.returns, cash.returns, strategy)
  colnames(strategies) <- c(symbol, cash, paste0(symbol," - Absolute momentum"))
  
  return(strategies)
}



findOptimalPeriods <- function(asset.symbol) {

  ## OPTIMISATION
  sharpe <- matrix(ncol = 14, nrow = 40)
  rtn <- matrix(ncol = 14, nrow = 40)

  for (long in 13:52) {
    for (short in 0:13) {
      str <- absoluteMomentum(asset.symbol, "SHY", long, short)
      t <- table.AnnualizedReturns(str)
      sharpe[long - 12, short + 1] <- t[3,3]
      rtn[long - 12, short + 1] <- t[1,3]
    }
  }
  offset <- c(12, -1)
  maxSharpe <- which(sharpe == max(sharpe, na.rm = TRUE), arr.ind = TRUE)
  
  write.csv(sharpe, file = paste0(asset.symbol, "-sharpe.csv"))
  write.csv(rtn, file = paste0(asset.symbol, "-returns.csv"))
  
  maxSharpePeriod <- maxSharpe + offset
  return(maxSharpePeriod)
}
gem.symbols <- c("IVV", "BND", "VEU")
symbols.sectors <- c("XBI", "XLB", "XLE", "XLF", "XLI", "XLK", "XLP", "XLU", "XLV", "XLY")
getSymbols(c("SPY", "SHY", "IVV", "BND", "VEU"), from="1900-01-01")
getSymbols(symbols.sectors, from="1900-01-01")
symbols.country <- c(
  "UBR", # ProShares Ultra MSCI Brazil	
  "EWZ", # iShares MSCI Brazil Index Fund		
  "IDX", # Market Vectors Indonesia ETF		
  "EIDO", # iShares MSCI Indonesia Investable Market		
  "PGJ", # PowerShares Golden Dragon Halter USX China Portfolio		
  "EWY", # iShares MSCI South Korea Index Fund		
  "RBL", # SPDR S&P Russia ETF	
  "THD", # iShares MSCI Thailand Invest Mkt Index		
  "RSX", # Market Vectors Russia ETF Trust		
  "GXC", # SPDR S&P China ETF		
  "EWT", # iShares MSCI Taiwan Index Fund		
  "EWH", # iShares MSCI Hong Kong Index Fund		
  "EWA", # iShares MSCI Australia Index Fund	
  "EPI", # WisdomTree India Earnings		
  "GXG", # Global X/InterBolsa FTSE Colombia 20 ETF		
  "SPY", # SPDR S&P 500		
  "QQQ", # PowerShares QQQ	
  "EWM", # iShares MSCI Malaysia Index Fund		
  "FXI", # IShares China Large Cap ETF		
  "EWC", # iShares MSCI Canada Index Fund		
  "EWK", # iShares MSCI Belgium Index Fund		
  "IWM", # iShares Russell 2000 Index Fund		
  "INP", # iPath MSCI India ETN		
  "PIN", # PowerShares India		
  "EWJ", # iShares MSCI Japan Index Fund		
  "EWO"	, # iShares MSCI Austria Index Fund	
  "EWN", # iShares MSCI Netherlands Index Fund		
  "EWS", # iShares MSCI Singapore Index Fund		
  "TUR", # iShares MSCI Turkey Invest Mkt Index		
  "EWG", # iShares MSCI Germany Index Fund		
  "EWW", # iShares MSCI Mexico Index Fund	
  "EWQ", # iShares MSCI France Index Fund	
  "EWD", # iShares MSCI Sweden Index Fund	
  "EZA", # iShares MSCI South Africa Index Fund	
  "EWL"	, # iShares MSCI Switzerland Index Fund	
  "EWU", # iShares MSCI United Kingdom Index Fund	
  "EIS", # iShares MSCI Israel Cap Invest Mkt Index	
  "EWP", # iShares MSCI Spain Index Fund	
  "EWI" # iShares MSCI Italy Index Fund	
 )
getSymbols(symbols.country, from="1900-01-01")


symbols.paa <- c("SPY", # SPDR S&P 500 ETF Trust
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

getSymbols(symbols.paa, from="1900-01-01")

analysis.symbols <- c(symbols.sectors, symbols.country) 
analysis.symbols <- symbols.paa
for(sec in analysis.symbols) {
  varname <- paste0(sec, ".maxSharpePeriod")
  optimalPeriods <- findOptimalPeriods(sec)
  assign(varname, optimalPeriods, envir = globalenv())
  write.csv(optimalPeriods, file = paste0(varname, ".csv"))
}


str <- absoluteMomentum("XLV", "SHY", 37, 11)


dev.new()
charts.PerformanceSummary(str)
t(table.AnnualizedReturns(str))
table.DownsideRisk(str)
table.DrawdownsRatio(str)


dev.new()
layout(rbind(c(1),c(2), c(3)))
chart.CumReturns(strategy)
chart.TimeSeries(signal)
chart.Drawdown(strategy)


allsymbols.maxSharpePeriod <-
  
  rbind(
    SPY.maxSharpePeriod, # SPDR S&P 500 ETF Trust
    QQQ.maxSharpePeriod, # NASDAQ- 100 Index Tracking Stock
    EFA.maxSharpePeriod, #, # iShares MSCI EAFE Index Fund (ETF)
    EEM.maxSharpePeriod, # iShares MSCI Emerging Markets Indx (ETF)
    GLD.maxSharpePeriod, # SPDR Gold Trust (ETF)
    GSG.maxSharpePeriod, # iShares S&P GSCI Commodity-Indexed Trust
    IYR.maxSharpePeriod, # iShares Dow Jones US Real Estate (ETF)
    UUP.maxSharpePeriod, # PowerShares DB US Dollar Bullish ETF
    HYG.maxSharpePeriod, # iShares iBoxx $ High Yid Corp Bond (ETF)
    LQD.maxSharpePeriod, # iShares IBoxx $ Invest Grade Corp Bd Fd
    IWM.maxSharpePeriod, # iShares Russell 2000 Index (ETF)
    
    #sectors  
    XBI.maxSharpePeriod, 
    XLB.maxSharpePeriod, 
    XLE.maxSharpePeriod, 
    XLF.maxSharpePeriod, 
    XLI.maxSharpePeriod, 
    XLK.maxSharpePeriod, 
    XLP.maxSharpePeriod, 
    XLU.maxSharpePeriod, 
    XLV.maxSharpePeriod, 
    XLY.maxSharpePeriod,
    
    # countries
    UBR.maxSharpePeriod,
    EWZ.maxSharpePeriod,
    IDX.maxSharpePeriod,
    EIDO.maxSharpePeriod,
    PGJ.maxSharpePeriod,
    EWY.maxSharpePeriod,
    RBL.maxSharpePeriod,
    THD.maxSharpePeriod,
    RSX.maxSharpePeriod,
    GXC.maxSharpePeriod,
    EWT.maxSharpePeriod,
    EWH.maxSharpePeriod,
    EWA.maxSharpePeriod, # iShares MSCI Australia Index Fund	
  EPI.maxSharpePeriod, # WisdomTree India Earnings		
  GXG.maxSharpePeriod, # Global X/InterBolsa FTSE Colombia 20 ETF		
  SPY.maxSharpePeriod, # SPDR S&P 500		
  QQQ.maxSharpePeriod, # PowerShares QQQ	
  EWM.maxSharpePeriod, # iShares MSCI Malaysia Index Fund		
  FXI.maxSharpePeriod, # IShares China Large Cap ETF		
  EWC.maxSharpePeriod, # iShares MSCI Canada Index Fund		
  EWK.maxSharpePeriod, # iShares MSCI Belgium Index Fund		
  IWM.maxSharpePeriod, # iShares Russell 2000 Index Fund		
  INP.maxSharpePeriod, # iPath MSCI India ETN		
  PIN.maxSharpePeriod, # PowerShares India		
  EWJ.maxSharpePeriod, # iShares MSCI Japan Index Fund		
  EWO.maxSharpePeriod	, # iShares MSCI Austria Index Fund	
  EWN.maxSharpePeriod, # iShares MSCI Netherlands Index Fund		
  EWS.maxSharpePeriod, # iShares MSCI Singapore Index Fund		
  TUR.maxSharpePeriod, # iShares MSCI Turkey Invest Mkt Index		
  EWG.maxSharpePeriod, # iShares MSCI Germany Index Fund		
  EWW.maxSharpePeriod, # iShares MSCI Mexico Index Fund	
  EWQ.maxSharpePeriod, # iShares MSCI France Index Fund	
  EWD.maxSharpePeriod, # iShares MSCI Sweden Index Fund	
  EZA.maxSharpePeriod, # iShares MSCI South Africa Index Fund	
  EWL.maxSharpePeriod, # iShares MSCI Switzerland Index Fund	
  EWU.maxSharpePeriod, # iShares MSCI United Kingdom Index Fund	
  EIS.maxSharpePeriod, # iShares MSCI Israel Cap Invest Mkt Index	
  EWP.maxSharpePeriod, # iShares MSCI Spain Index Fund	
  EWI.maxSharpePeriod # iShares MSCI Italy Index Fund	
)

rownames(allsymbols.maxSharpePeriod) <-
  #sectors
  c(
    "SPY.maxSharpePeriod", # SPDR S&P 500 ETF Trust
    "QQQ.maxSharpePeriod", # NASDAQ- 100 Index Tracking Stock
    "EFA.maxSharpePeriod", #, # iShares MSCI EAFE Index Fund (ETF)
    "EEM.maxSharpePeriod", # iShares MSCI Emerging Markets Indx (ETF)
    "GLD.maxSharpePeriod", # SPDR Gold Trust (ETF)
    "GSG.maxSharpePeriod", # iShares S&P GSCI Commodity-Indexed Trust
    "IYR.maxSharpePeriod", # iShares Dow Jones US Real Estate (ETF)
    "UUP.maxSharpePeriod", # PowerShares DB US Dollar Bullish ETF
    "HYG.maxSharpePeriod", # iShares iBoxx $ High Yid Corp Bond (ETF)
    "LQD.maxSharpePeriod", # iShares IBoxx $ Invest Grade Corp Bd Fd
    "IWM.maxSharpePeriod", # iShares Russell 2000 Index (ETF)
    
    "XBI.maxSharpePeriod", 
    "XLB.maxSharpePeriod", 
    "XLE.maxSharpePeriod", 
    "XLF.maxSharpePeriod", 
    "XLI.maxSharpePeriod", 
    "XLK.maxSharpePeriod", 
    "XLP.maxSharpePeriod", 
    "XLU.maxSharpePeriod", 
    "XLV.maxSharpePeriod", 
    "XLY.maxSharpePeriod",
    
    "UBR.maxSharpePeriod",
    "EWZ.maxSharpePeriod",
    "IDX.maxSharpePeriod",
    "EIDO.maxSharpePeriod",
    "PGJ.maxSharpePeriod",
    "EWY.maxSharpePeriod",
    "RBL.maxSharpePeriod",
    "THD.maxSharpePeriod",
    "RSX.maxSharpePeriod",
    "GXC.maxSharpePeriod",
    "EWT.maxSharpePeriod",
    "EWH.maxSharpePeriod",
    "EWA.maxSharpePeriod", # iShares MSCI Australia Index Fund	
    "EPI.maxSharpePeriod", # WisdomTree India Earnings		
    "GXG.maxSharpePeriod", # Global X/InterBolsa FTSE Colombia 20 ETF		
    "SPY.maxSharpePeriod", # SPDR S&P 500		
    "QQQ.maxSharpePeriod", # PowerShares QQQ	
    "EWM.maxSharpePeriod", # iShares MSCI Malaysia Index Fund		
    "FXI.maxSharpePeriod", # IShares China Large Cap ETF		
    "EWC.maxSharpePeriod", # iShares MSCI Canada Index Fund		
    "EWK.maxSharpePeriod", # iShares MSCI Belgium Index Fund		
    "IWM.maxSharpePeriod", # iShares Russell 2000 Index Fund		
    "INP.maxSharpePeriod", # iPath MSCI India ETN		
    "PIN.maxSharpePeriod", # PowerShares India		
    "EWJ.maxSharpePeriod", # iShares MSCI Japan Index Fund		
    "EWO.maxSharpePeriod", # iShares MSCI Austria Index Fund	
    "EWN.maxSharpePeriod", # iShares MSCI Netherlands Index Fund		
    "EWS.maxSharpePeriod", # iShares MSCI Singapore Index Fund		
    "TUR.maxSharpePeriod", # iShares MSCI Turkey Invest Mkt Index		
    "EWG.maxSharpePeriod", # iShares MSCI Germany Index Fund		
    "EWW.maxSharpePeriod", # iShares MSCI Mexico Index Fund	
    "EWQ.maxSharpePeriod", # iShares MSCI France Index Fund	
    "EWD.maxSharpePeriod", # iShares MSCI Sweden Index Fund	
    "EZA.maxSharpePeriod", # iShares MSCI South Africa Index Fund	
    "EWL.maxSharpePeriod", # iShares MSCI Switzerland Index Fund	
    "EWU.maxSharpePeriod", # iShares MSCI United Kingdom Index Fund	
    "EIS.maxSharpePeriod", # iShares MSCI Israel Cap Invest Mkt Index 
    "EWP.maxSharpePeriod", # iShares MSCI Spain Index Fund  
    "EWI.maxSharpePeriod" # iShares MSCI Italy Index Fund	
  )
colnames(allsymbols.maxSharpePeriod) <- c("Long lookback period (weeks)", "Short lookback period (weeks)")
write.csv(allsymbols.maxSharpePeriod, file = "allsymbols-optimalperiods.csv")
