require(xts)
require(quantmod)
require(PerformanceAnalytics)
require(TTR)

### The PAA model will be backtested from Dec 1970 - Dec 2015 (45 years) on
# monthly total return data (see paper for data construction). The universe 
# of choice is a global diversified multi-asset universe consisting of proxies 
# for 12 so called "risky" ETFs: SPY, QQQ, IWM (US equities: S&P500, Nasdaq100 
# and Russell2000 Small Cap), VGK, EWJ (Developed International Market equities: 
# Europe and Japan), EEM (Emerging Market equities), IYR, GSG, GLD 
# (Alternatives: REIT, Commodities, Gold), HYG, LQD and TLT (US High Yield bonds, 
# US Investment Grade Corporate bonds and Long Term US Treasuries). 
# The broadness of the universe makes it suitable for harvesting risk premia
# during different economical regimes. 


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

MOM <- function(ts, lookback) {
  return ((ts / SMA(ts, lookback)) - 1)
}

BF <- function(mom, risky.symbols, protection) {
  N <- length(risky.symbols)
  good.assets <- rowSums(mom[, risky.symbols] > 0, na.rm=TRUE)
  
  BF <- pmin((N - good.assets) / (N - (protection * N/4)), 1)
  return(BF)
}

minimum.correlation.portfolio <- function(returns) {
  s0 <- apply(data.frame(returns), 2, sd)
  correlation <- cor(returns, use='complete.obs', method='pearson') 
  covariance <- correlation * (s0 %*% t(s0))
  upper.index <- upper.tri(correlation)
  cor.m <- correlation[upper.index]
  cor.mu <- mean(cor.m)
  cor.sd <- sd(cor.m)
  
  norm.dist.m <- 0 * correlation
  diag(norm.dist.m) <- NA
  norm.dist.m[upper.index] <- 1-pnorm(cor.m, cor.mu, cor.sd)
  norm.dist.m <- (norm.dist.m + t(norm.dist.m))
  norm.dist.avg <- rowMeans(norm.dist.m, na.rm=T)
  norm.dist.rank <- rank(-norm.dist.avg)
  norm.dist.weight <- norm.dist.rank / sum(norm.dist.rank)
  diag(norm.dist.m) <- 0
  weighted.norm.dist.average <- norm.dist.weight %*% norm.dist.m
  final.weight <- weighted.norm.dist.average / sum(weighted.norm.dist.average)
  
  # re-scale weights to penalize for risk
  x <- final.weight
  x <- x / sqrt( diag(covariance) )
  
  # normalize weights to sum up to 1
  weights <- x / sum(x) 
  return(weights)
}

PAAWeights <- function(risky.symbols, nonrisky.symbols, frequency, lookback, protection, top) {
  syms <- c(risky.symbols, nonrisky.symbols)
  prices <- getPrices(syms, frequency)
  returns <- getReturns(syms, frequency)
  
  mom <- apply(prices, 2, FUN = function(c) MOM(c, lookback))
  bf <- BF(mom, risky.symbols, protection)
  mom.rank <- t(apply(mom[, risky.symbols], 1, rank, ties.method="min"))
  mom.rank[mom.rank > top] <- 0
  
  weights.risk_on <- mom.rank
  weights.risk_on[weights.risk_on > 0] <- 1
  weights.risk_on <- weights.risk_on * (1 - bf) / min(top, length(risky.symbols))
  
  ### Add minimum correlatoin weight algorithm here.
  #weights.risk_on <- weights.risk_on * (1 - bf) / min(top, length(risky.symbols))
  
  risk_off.count <- length(nonrisky.symbols)
  
  weights.risk_off <-  matrix(rep(bf / risk_off.count, risk_off.count), ncol = risk_off.count)
  
  colnames(weights.risk_off) <- nonrisky.symbols
  
  weights <- cbind(weights.risk_on, weights.risk_off)
  return(weights)
}

PAA <- function(risky.symbols, nonrisky.symbols, frequency, lookback, protection, top) {
  syms <- c(risky.symbols, nonrisky.symbols)
  weights <- PAAWeights(risky.symbols, nonrisky.symbols, frequency, lookback, protection, top)
  returns <- getReturns(syms, frequency)
  strategy <- lag(weights, k = 1) * returns
  strategy.returns <- xts(rowSums(strategy), order.by = index(returns))
  colnames(strategy.returns) <- paste0(frequency, ".returns")
  return(strategy.returns)
}


printPerformance <- function(strategy.returns) {
  dev.new()
  layout(rbind(c(1,2),c(3,4)))
  #charts.PerformanceSummary(strategy.returns)
  chart.CumReturns(strategy.returns)
  chart.Drawdown(strategy.returns)
  chart.TimeSeries(strategy.returns)
  chart.Histogram(strategy.returns, main = "Density", breaks=40, methods = c("add.density", "add.normal", "add.centered", "add.rug"))
  #charts.RollingPerformance(strategy.returns, width = 52)
  
  table.Stats(strategy.returns)
  table.AnnualizedReturns(strategy.returns)
  table.Drawdowns(strategy.returns, top = 10)
  table.DrawdownsRatio(strategy.returns)
  table.CalendarReturns(strategy.returns)
}


risk_on <- c("SPY", # SPDR S&P 500 ETF Trust
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


symbols.sectors <- c("XBI", "XLB", "XLE", "XLF", "XLI", "XLK", "XLP", "XLU", "XLV", "XLY")
symbols.country <- c(
  "UBR", # ProShares Ultra MSCI Brazil	
#  "BRF", # Market Vectors Brazil Small-Cap ETF	
#  "EPU", # iShares MSCI All Peru Capped Idx		
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
#  "XPP", # ProShares Ultra FTSE/Xinhua China 25		
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
#  "INDL", # Direxion Daily India Bull 2x Shares	
  "PIN", # PowerShares India		
#  "ECH", # iShares MSCI Chile Index Fund		
#  "EZJ", # ProShares Ultra MSCI Japan		
  "EWJ", # iShares MSCI Japan Index Fund		
#  "EDEN", # iShares MSCI Denmark Cppd Investable Mkt	
  "EWO"	, # iShares MSCI Austria Index Fund	
  "EWN", # iShares MSCI Netherlands Index Fund		
  "EWS", # iShares MSCI Singapore Index Fund		
  "TUR", # iShares MSCI Turkey Invest Mkt Index		
  "EWG", # iShares MSCI Germany Index Fund		
#  "DAX", # Recon Capital DAX Germany ETF		
#  "EGPT", # Market Vectors Egypt Index ETF	
  "EWW", # iShares MSCI Mexico Index Fund	
  "EWQ", # iShares MSCI France Index Fund	
#  "EIRL", # iShares MSCI Ireland Capped Investable Market	
  "EWD", # iShares MSCI Sweden Index Fund	
  "EZA", # iShares MSCI South Africa Index Fund	
  "EWL"	, # iShares MSCI Switzerland Index Fund	
  "EWU", # iShares MSCI United Kingdom Index Fund	
  "EIS", # iShares MSCI Israel Cap Invest Mkt Index	
#  "UMX", # ProShares Ultra MSCI Mexico Investable Market	
  "EWP", # iShares MSCI Spain Index Fund	
#  "EPOL", # iShares MSCI Poland Investable Market Index Fund	
#  "YXI", # ProShares Short FTSE/Xinhua China 25	
  "EWI" # iShares MSCI Italy Index Fund	
#  "EWV", # ProShares UltraShort MSCI Japan		
#  "SMK", # ProShares UltraShort MSCI Mexico		
#  "FXP", # ProShares UltraShort FTSE/Zinhua China 25	
#  "BZQ" # ProShares UltraShort MSCI Brazil		
)

risk_off <- c(
              #"SHY", # iShares 1-3 Year Treasury Bond
              "IEF", # iShares Barclays 7-10 Year Trasry Bnd Fd
              #"AGG", # iShares Barclays Aggregate Bond Fund
              "TLT") # iShares Barclays 20+ Yr Treas.Bond (ETF)



symbols <- c(risk_on, symbols.sectors, symbols.country, risk_off)
getSymbols(symbols, from="1990-01-01")


sharpe <- matrix(ncol = 11, nrow = 26)
rtn <- matrix(ncol = 11, nrow = 26)

for(topi in 1:11) {
  for(looki in 1:26) {
    rets <- PAA(risk_on, risk_off, frequency = "weekly", lookback = 26 + looki, protection = 2, top = topi)
    tb <- table.AnnualizedReturns(rets)
    rtn[looki, topi] <- tb[1,1]
    sharpe[looki, topi] <- tb[3,1]
  }
}

strategy.returns <- PAA(risk_on, risk_off, frequency = "weekly", lookback = 26, protection = 2, top = 11)
table.AnnualizedReturns(strategy.returns)
tb <- table.AnnualizedReturns(strategy.returns)

strategy.returns <- PAA(risk_on, risk_off, frequency = "monthly", lookback = 6, protection = 2, top = 11)

printPerformance(strategy.returns)




sec.sharpe <- matrix(ncol = 10, nrow = 26)
sec.rtn <- matrix(ncol = 10, nrow = 26)

for(topi in 1:10) {
  for(looki in 1:26) {
    rets <- PAA(symbols.sectors, risk_off, frequency = "weekly", lookback = 26 + looki, protection = 2, top = topi)
    tb <- table.AnnualizedReturns(rets)
    sec.rtn[looki, topi] <- tb[1,1]
    sec.sharpe[looki, topi] <- tb[3,1]
  }
}

sector.returns <- PAA(symbols.sectors, risk_off, frequency = "weekly", lookback = 28, protection = 2, top = 10)
sector.weights <- PAAWeights(symbols.sectors, risk_off, frequency = "weekly", lookback = 30, protection = 2, top = 10)


strategy.weights <- PAAWeights(risk_on, risk_off, frequency = "weekly", lookback = 26, protection = 2, top = 11)

#filename <- "paa.pdf"
#pdf(filename)
#sink(filename, append=TRUE, split=TRUE)


#sink()
#dev.off()