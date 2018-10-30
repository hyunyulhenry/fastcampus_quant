Sys.setenv(TZ = "UTC")

library(HenryQuant)
library(quantmod)
library(PerformanceAnalytics)
library(magrittr)

getSymbols("^GSPC", from = "1950-01-01")
rets = Ad(GSPC) %>% Return.calculate() %>% na.omit()

charts.PerformanceSummary(rets)
charts.PerformanceSummary(log(1+rets))

lookback = 12
ep = endpoints(rets)

### BackTest ###

wts = list()

for (i in (lookback+1) : length(ep)) {
  subret = rets[ep[i-lookback] : ep[i] , ]
  cum = Return.cumulative(subret)
  
  wt = rep(0,2)
  wt[1] = ifelse(cum>0,1,0)
  wt[2] = 1 - wt[1]
  
  wts[[i]] = xts(t(wt), order.by = index(rets[ep[i]]))
}

wts = do.call(rbind, wts)
port = Return.portfolio(cbind(rets,0), wts)
charts.PerformanceSummary(port)

colnames(wts) = colnames(rets)
chart.StackedBar(wts)

port.bind = cbind(rets, port) %>% na.omit()
colnames(port.bind) = c("S&P", "Timing")

charts.PerformanceSummary(port.bind)
charts.PerformanceSummary(port.bind["2007::"])

yr_plot(port.bind)
maxDrawdown(port.bind)
table.AnnualizedReturns(port.bind)
skewness(port.bind)


port.bind.y = apply.yearly(port.bind, Return.cumulative) %>%
  round(., 4)
