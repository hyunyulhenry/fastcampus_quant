library(quantmod)
library(PerformanceAnalytics)
library(magrittr)

symbols = c("005930.KS", "015760.KS", "069500.KS")
getSymbols(symbols)
prices = do.call(cbind, lapply(symbols, function(x) Cl(get(x))))

ret = Return.calculate(prices)
ret.sub = ret["2016-01::2017-12"] 
# ret.sub = ret["2016::2017"] 

# 삼성전자
y = ret.sub[, 1] %>% as.numeric()
x = ret.sub[, 3] %>% as.numeric()

reg = lm(y ~ x)
summary(reg)
reg$coefficients
reg$coefficients[2]

plot(x, y, pch = 4, cex = 0.3, 
     xlab = "KOSPI 200", ylab = "Individual Stock",
     xlim = c(-0.02, 0.02), ylim = c(-0.02, 0.02))
grid()
abline(a = 0, b = 1, lty = 2)
abline(reg, col = 'red')

CAPM.beta(ret.sub[, 1], ret.sub[, 3]) # Using Function

# 유틸리티주
y = ret.sub[, 2] %>% as.numeric()
x = ret.sub[, 3] %>% as.numeric()

reg = lm(y ~ x)
summary(reg)
reg$coefficients
reg$coefficients[2]

plot(x, y, pch = 4, cex = 0.3, 
     xlab = "KOSPI 200", ylab = "Individual Stock",
     xlim = c(-0.02, 0.02), ylim = c(-0.02, 0.02))
grid()
abline(a = 0, b = 1, lty = 2)
abline(reg, col = 'red')

CAPM.beta(ret.sub[, 2], ret.sub[, 3]) # Using Function
