Sys.setenv(TZ = "UTC")

library(HenryQuant)
library(quantmod)
library(PerformanceAnalytics)

symbols = c("SPY","IEV","EWJ","EEM","TLT","IEF","IYR","RWX","GLD","DBC")
getSymbols(symbols, src='yahoo')

##################################################################
###### SPY: S&P 500 ##############################################
###### IEV: iShares S&P EURO 350 #################################
###### EWJ: iShares MSCI Japan ETF ###############################
###### EEM: iShares MSCI Emerging Markets ETF ####################
###### TLT: iShares Barclays 20+ Yr Trasry Bond ETF ##############
###### IEF: iShares Barclays 7-10 Year Trasry Bond ETF ###########
###### IYR: iShares Dow Jones US Real Estate #####################
###### RWX: SPDR Dow Jones Interntnl Real Estate ETF #############
###### GLD: SPDR Gold Trust (ETF) ################################
###### DBC: PowerShares DB Commodity  Index Trckng Fund(ETF) #####

prices = do.call(merge, lapply(symbols, function(x) Ad(get(x))))
rets = Return.calculate(prices)[-1,]

rets = asset_data

num = 5 
lookback = 12
ep = endpoints(rets)

### BackTest ###

wts = list()
for (i in (lookback+1) : length(ep)) {
  subret = rets[ep[i-lookback] : ep[i] , ]
  cum = Return.cumulative(subret)
  
  K = which(rank(-cum) <= num)
  covmat = cov(subret[, K])
  
  wt = rep(0, 10)
  wt[K] = wt_minvol(covmat, rep(0.1,num), rep(0.3, num))
  # wt[K] = wt_RiskBudget(covmat)
  wts[[i]] = xts(t(wt), order.by = index(rets[ep[i]]))
}

wts = do.call(rbind, wts)
DAA = Return.portfolio(rets, wts, verbose = TRUE)
charts.PerformanceSummary(DAA$returns)

colnames(wts) = colnames(rets)
chart.StackedBar(wts, rainbow10equal)

apply.yearly(DAA$returns, Return.cumulative)
Return.stats(DAA$returns)
