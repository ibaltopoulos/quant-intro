require(xts)
require(quantmod)
require(PerformanceAnalytics)
require(TTR)

symbols.sectors <- c("XBI", "XLB", "XLE", "XLF", "XLI", "XLK", "XLP", "XLU", "XLV", "XLY")
symbols.sectors <- c("SPY", # SPDR S&P 500 ETF Trust
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

getSymbols(symbols.sectors, from="1990-01-01")
prices.sectors <- list()
for(i in 1:length(symbols.sectors)) {
  adjustedPrices <- Ad(get(symbols.sectors[i]))
  colnames(adjustedPrices) <- gsub("\\.[A-z]*", "", colnames(adjustedPrices))
  prices.sectors[[i]] <- adjustedPrices
  colnames(prices.sectors[[i]]) <- symbols.sectors[i]
}
prices.sectors <- do.call(cbind, prices.sectors)
colnames(prices.sectors) <- gsub("\\.[A-z]*", "", colnames(prices.sectors))
returns.sectors <- Return.calculate(prices.sectors)
returns.sectors <- na.omit(returns.sectors)


#returns.window <- returns.sectors["2006::2007"]

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

dates <- index(returns.sectors)
results <- NULL
for(i in dates) {
  d <- as.Date(i)
  returns <- returns.sectors[index(returns.sectors) >= d & index(returns.sectors) <= i +365]
  row <- minimum.correlation.portfolio(returns)
  xts_row <- xts(row, d)
  results <- rbind(results, xts_row)                ## add results to row
}

rs <- xts(x=rowSums(results * returns.sectors), order.by = index(returns.sectors))


charts.PerformanceSummary(rs)
cbind(
  table.AnnualizedReturns(rs),
  maxDrawdown(rs),
  CalmarRatio(rs))

table.Drawdowns(rs, top = 10)