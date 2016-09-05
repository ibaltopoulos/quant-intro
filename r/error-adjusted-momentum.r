# from http://www.capitalspectator.com/a-momentum-based-trading-signal-with-strategic-value/

library(TTR)
library(zoo)
library(quantmod)

# download daily S&P 500 prices from Dec 31, 1990 forward
gspc <-getSymbols('^gspc',from='1990-12-31',auto.assign=FALSE)

# error adjusted momentum function
eam <-function(symbol, lookback, sma) { # x=ticker, y=lookback period for forecast z=SMA period
  return <- na.omit(Return.calculate(Ad(symbol)))
  returns.trailing <-na.omit(SMA(return, lookback)) # forecast based on "y" trailing period returns
  returns.trailing.lagged <-na.omit(Lag(returns.trailing, k=1)) # lag forecasts by 1 period
  d <- na.omit(cbind(returns.trailing.lagged, return)) # combine lagged forecasts with actual returns into one file
  e <- as.xts(apply(d, 1, diff)) # actual daily return less forecast
  f <- to.daily(na.omit(rollapplyr(e, lookback, function(x) mean(abs(x)))),drop.time=TRUE,OHLC=FALSE) # mean absolute error
  g <- cbind(return,f) # combine actual return with MAE into one file
  h <- na.omit(return[,1]/g[,2]) # divide actual return by MAE
  i <- na.omit(SMA(h,z)) # generate 200-day moving average of adjusted return
  j <- na.omit(Lag(ifelse(i >0,1,0))) # lag adjusted return signal by one day for trading analysis
}

# function to generate raw EAM signal data
eam.ret <-function(x,y,z) { # x=ticker, y=lookback period for vol forecast, z=SMA period
  a <-eam(x,y,z)
  b <-na.omit(ROC(Ad(x),1,"discrete"))
  
  c <-length(a)-1
  d <-tail(b,c)
  e <-d*a
  f <-cumprod(c(100,1 + e))
  
  g <-tail(b,c)
  h <-cumprod(c(100,1 + g))
  
  i <-cbind(f,h)
  colnames(i) <-c("model","asset")
  
  date.a <-c((first(tail((as.Date(index(x))),c))-1),(tail((as.Date(index(x))),c)))
  
  j <-xts(i,date.a)
  
  return(j)
  
}



eam.model <-eam.ret(gspc,10,200)

eam.data <-function(x,y,z) { # x=ticker, y=lookback period for forecast z=SMA period
  a <-na.omit(ROC(Ad(x),1,"discrete"))
  b <-na.omit(SMA(a,y)) # forecast based on "y" trailing period returns
  c <-na.omit(Lag(b,k=1))  # lag forecasts by 1 period
  d <-na.omit(cbind(c,a))
  e <-as.xts(apply(d,1,diff))
  f <-to.daily(na.omit(rollapplyr(e,y,function(x) mean(abs(x)))),drop.time=TRUE,OHLC=FALSE)
  g <-cbind(a,f)
  h <-na.omit(a[,1]/g[,2])
  i <-na.omit(SMA(h,z))
  colnames(i) <-c("eam data")
  return(i)
}

eam.data.history <-eam.data(gspc,10,200)

