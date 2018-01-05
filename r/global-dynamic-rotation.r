require(xts)
require(quantmod)
require(PerformanceAnalytics)
require(TTR)
require(dplyr)
require(ggplot2)
require(grid)
require(gridExtra)
require(reshape2)
require(robustHD)
require(gtable)
require(stringr)
require(lubridate)
require(scales) ## show percent scales on ggplot graphs
require(tidy)


getPrices <- function(symbols, frequency = "daily") {
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

totalReturn <- function(prices, longPeriod, shortPeriod) {
  ROC(prices, n = longPeriod, type = "discrete") - ROC(prices, n = shortPeriod, type = "discrete")
}

xts2df <- function(x) {
  data.frame(date=index(x), coredata(x))
}


symbols <- c("GREK")
getSymbols(symbols, from="1990-01-01", env=globalenv(), auto.assign = TRUE)


gr <- getPrices(symbols, "weekly")



do_regression <- function(data) {
  m <- lm(returns ~ lagMomentum52wk4wk, data=data)
  a <- coef(m)[1]
  b <-coef(m)[2]
  r.squared <- summary(m)$r.squared
  return(data.frame(a, b, r.squared))
}


ts <- 
  xts2df(gr) %>%
  mutate(
    returns = ROC(GREK, type = "continuous"),
    momentum52wk4wk = totalReturn(GREK, 52, 4),
    volatility = rollapply(data = returns, 
                              width = 3 * 52, 
                              FUN = sd, 
                              align = "right", 
                              fill = NA, 
                              by.column = TRUE,
                              na.rm = T),
    returns5yr = ROC(GREK, n = 5 * 52, type = "discrete"),
    volAdjMomentum = momentum52wk4wk / volatility,
    lagVolAdjMomentum = lag(volAdjMomentum, n = 8),
    lagMomentum52wk4wk = lag(momentum52wk4wk, n = 8)
  ) %>%
  do(do_regression(.))
  
  


last_point <- tail(ts, 1)$lagMomentum52wk4wk


ggplot(ts, aes_string(x = "lagMomentum52wk4wk", y = "returns", color = "date")) +
## Pick a theme and make the y axis black
theme_bw() +
theme(axis.line.y = element_line(color="black", size = 0.5)) +

## Draw the points
geom_point(size = 1.5, alpha = 1) + 
geom_hline(aes(yintercept = 0)) +  
geom_smooth(method = "lm", se = TRUE) + 
geom_vline(xintercept =  last_point, color="red", size = 1) + 

#scale_color_gradient() +
## Labelling and annotations
guides(color = guide_colorbar(title = "Year")) +


annotate("text", 
         x = last_point * 1.055, 
         y = -0.035, 
         label = "Current level", 
         color = "red") +
scale_y_continuous(labels=percent)