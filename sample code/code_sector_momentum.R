library(openxlsx)
library(quantmod)
library(PerformanceAnalytics)
library(magrittr)

Sys.setenv(TZ = "UTC")

mom = read.xlsx("C:/Users/Henry/Dropbox/강의/sector_momentum.xlsx",
                detectDates = TRUE,
                rows = c(10, 15:10000),
                rowNames = TRUE, colNames = TRUE) %>% as.xts

ret = Return.calculate(mom) %>% na.omit
lookback = 12
target = 5

# Normal Momentum (12 months) #
ret.mom = matrix(NA, nrow(ret), 1) %>% data.frame()
select.mom = matrix(0, nrow(ret), ncol(ret)) %>% data.frame()

rownames(ret.mom) = rownames(select.mom) = index(ret)
colnames(select.mom) = colnames(ret)

for (i in (lookback + 1) : (nrow(ret) - 1) ) {
  ret.cum = ret[i : (i-12+1), ] %>% Return.cumulative()
  invest = which(rank(-ret.cum) <= target) 
  ret.mom[i+1, ] = ret[i+1, invest] %>% mean()
  
  select.mom[i, invest] = 1 / length(invest)
}

ret.mom = na.omit(ret.mom) %>% as.xts() %>% round(., 4)
select.mom = as.xts(select.mom)
select.mom[rowSums(select.mom) == 0, ] = NA
select.mom = na.omit(select.mom)

charts.PerformanceSummary(ret.mom)
apply.yearly(ret.mom, Return.cumulative)
chart.StackedBar(select.mom, col = rainbow(22))

library(HenryQuant)
Return.stats(ret.mom)
yr_plot(ret.mom)
