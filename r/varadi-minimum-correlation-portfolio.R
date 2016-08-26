###############################################################################
# Load Systematic Investor Toolbox (SIT)
###############################################################################
setInternet2(TRUE)
con = gzcon(url('http://www.systematicportfolio.com/sit.gz', 'rb'))
source(con)
close(con)

# Load supporting R code for Minimum Correlation Algorithm Paper
con=url('http://www.systematicportfolio.com/mincorr_paper.r')
source(con)
close(con)

#*****************************************************************
# Load historical data sets
#****************************************************************** 
load.packages('quantmod')   

#*****************************************************************
# Load historical data for Futures and Forex
#****************************************************************** 
data <- new.env()
getSymbols.TB(env = data, auto.assign = T, download = T)

bt.prep(data, align='remove.na', dates='1990::')
save(data,file='FuturesForex.Rdata')


#*****************************************************************
# Load historical data for ETFs
#****************************************************************** 
tickers = spl('SPY,QQQ,EEM,IWM,EFA,TLT,IYR,GLD')

data <- new.env()
getSymbols(tickers, src = 'yahoo', from = '1980-01-01', env = data, auto.assign = T)
for(i in ls(data)) data[[i]] = adjustOHLC(data[[i]], use.Adjusted=T)                            
# TLT first date is 7/31/2002
bt.prep(data, align='keep.all', dates='2002:08::')
save(data,file='ETF.Rdata')


#*****************************************************************
# Load historical data for dow stock (engle)
#****************************************************************** 
load.packages('quantmod,quadprog')
tickers = spl('AA,AXP,BA,CAT,DD,DIS,GE,IBM,IP,JNJ,JPM,KO,MCD,MMM,MO,MRK,MSFT')

data <- new.env()
getSymbols(tickers, src = 'yahoo', from = '1980-01-01', env = data, auto.assign = T)
for(i in ls(data)) data[[i]] = adjustOHLC(data[[i]], use.Adjusted=T)                            

bt.prep(data, align='keep.all', dates='1980::')
save(data,file='Dow.Engle.Rdata')


#*****************************************************************
# Load historical data for ETFs
#****************************************************************** 
load.packages('quantmod,quadprog')
tickers = spl('VTI,IEV,EEM,EWJ,AGG,GSG,GLD,ICF')

data <- new.env()
getSymbols(tickers, src = 'yahoo', from = '1980-01-01', env = data, auto.assign = T)
for(i in ls(data)) data[[i]] = adjustOHLC(data[[i]], use.Adjusted=T)                            

bt.prep(data, align='keep.all', dates='2003:10::')  
save(data,file='ETF2.Rdata')


#*****************************************************************
# Load historical data for nasdaq 100 stocks
#****************************************************************** 
load.packages('quantmod,quadprog')
#tickers = nasdaq.100.components()
tickers = spl('ATVI,ADBE,ALTR,AMZN,AMGN,APOL,AAPL,AMAT,ADSK,ADP,BBBY,BIIB,BMC,BRCM,CHRW,CA,CELG,CEPH,CERN,CHKP,CTAS,CSCO,CTXS,CTSH,CMCSA,COST,DELL,XRAY,DISH,EBAY,ERTS,EXPD,ESRX,FAST,FISV,FLEX,FLIR,FWLT,GILD,HSIC,HOLX,INFY,INTC,INTU,JBHT,KLAC,LRCX,LIFE,LLTC,LOGI,MAT,MXIM,MCHP,MSFT,MYL,NTAP,NWSA,NVDA,ORLY,ORCL,PCAR,PDCO,PAYX,PCLN,QGEN,QCOM,RIMM,ROST,SNDK,SIAL,SPLS,SBUX,SRCL,SYMC,TEVA,URBN,VRSN,VRTX,VOD,XLNX,YHOO')

data <- new.env()
for(i in tickers) {
  try(getSymbols(i, src = 'yahoo', from = '1980-01-01', env = data, auto.assign = T), TRUE)
  data[[i]] = adjustOHLC(data[[i]], use.Adjusted=T)                           
}
bt.prep(data, align='keep.all', dates='1995::')
save(data,file='nasdaq.100.Rdata')




#*****************************************************************
# Run all strategies
#****************************************************************** 
names = spl('ETF,FuturesForex,Dow.Engle,ETF2,nasdaq.100')   
lookback.len = 60
periodicitys = spl('weeks,months')
periodicity = periodicitys[1]
prefix = paste(substr(periodicity,1,1), '.', sep='')



for(name in names) {
  load(file = paste(name, '.Rdata', sep=''))
  
  obj = portfolio.allocation.helper(data$prices, periodicity, lookback.len = lookback.len, prefix = prefix,
                                    min.risk.fns = 'min.corr.portfolio,min.corr2.portfolio,max.div.portfolio,min.var.portfolio,risk.parity.portfolio,equal.weight.portfolio',
                                    custom.stats.fn = 'portfolio.allocation.custom.stats')      
  
  save(obj, file=paste(name, lookback.len, periodicity, '.bt', '.Rdata', sep=''))
}


#*****************************************************************
# Create Reports
#****************************************************************** 
for(name in names) {
  load(file=paste(name, '.Rdata', sep=''))
  
  # create summary of inputs report
  custom.input.report.helper(paste('report.', name, sep=''), data)
  
  # create summary of strategies report
  load(file=paste(name, lookback.len, periodicity, '.bt', '.Rdata', sep=''))
  custom.report.helper(paste('report.', name, lookback.len, periodicity, sep=''), 
                       create.strategies(obj, data))   
}


#*****************************************************************
# Futures and Forex: rescale strategies to match Equal Weight strategy risk profile
#****************************************************************** 
names = spl('FuturesForex') 
for(name in names) {
  load(file=paste(name, '.Rdata', sep=''))
  
  # create summary of strategies report
  load(file=paste(name, lookback.len, periodicity, '.bt', '.Rdata', sep=''))
  leverage = c(5, 4, 15, 20, 3, 1)
  custom.report.helper(paste('report.leverage.', name, lookback.len, periodicity, sep=''), 
                       create.strategies(obj, data, leverage)) 
}