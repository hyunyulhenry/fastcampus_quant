# 가장 먼저 엑셀데이터가 있는 폴더로 
# 워킹 디렉토리를 지정해 주세요!!!!

setwd("C:/Users/Henry/Downloads")

install.packages(devtools)
devtools::install_github("hyunyulhenry/HenryQuant")
library(HenryQuant)

packages = c("PerformanceAnalytics", "quantmod", "openxlsx")
ipak(packages) # Package Download & open

# Input data (K200) #
price_m = read.xlsx("Example_LowVol.xlsx", sheet = "price_m", rows = c(10, 15:10000), rowNames = TRUE, colNames = TRUE, detectDates = TRUE)
stop = read.xlsx("Example_LowVol.xlsx", sheet = "stop", rows = c(10, 15:10000), rowNames = TRUE, colNames = TRUE, detectDates = TRUE)
including = read.xlsx("Example_LowVol.xlsx", sheet = "including", rows = c(10, 15:10000), rowNames = TRUE, colNames = TRUE, detectDates = TRUE)

price_m[is.na(price_m)] = 0
ret_m = Return.calculate(price_m)

ret_m = as.xts(ret_m)
ret_m[is.infinite(ret_m)] = NA
price_m[price_m==0] = NA

ro = dim(price_m)[1]
co = dim(price_m)[2] 
quan = 5 

# std2 = rollapply(ret_m, 60, sd)

# BackTest #
result = matrix(NA,ro,quan)
rownames(result) = rownames(price_m)
colnames(result) = rep(1:5)

st = which(index(ret_m) == "2000-12-31")
for (i in st : (ro-1)) {
  
  K = which( (including[i, ] == "Y") & ( stop[i, ] ==  "정상") )
  temp = matrix(NA,1,co)
  
  subret = ret_m[i : (i-60+1), K]
  # subret[,1]
  std = apply(subret, 2, sd)
  temp[1, K] = std

  qt =  quantile(temp[1, ], seq(0, 1, 0.2), na.rm  = TRUE)
  
  P1 = which(qt[1] <= temp[1, ] & temp[1, ] <qt[2])
  P2 = which(qt[2] <= temp[1, ] & temp[1, ] <qt[3])
  P3 = which(qt[3] <= temp[1, ] & temp[1, ] <qt[4])
  P4 = which(qt[4] <= temp[1, ] & temp[1, ] <qt[5])
  P5 = which(qt[5] <= temp[1, ] & temp[1, ] <qt[6])
  
  result[i+1, 1] = mean(ret_m[i+1, P1])
  result[i+1, 2] = mean(ret_m[i+1, P2])
  result[i+1, 3] = mean(ret_m[i+1, P3])
  result[i+1, 4] = mean(ret_m[i+1, P4])
  result[i+1, 5] = mean(ret_m[i+1, P5])
  
}

result = na.omit(result)
result = as.xts(result)

# GRAPH #
chart.CumReturns(result, main="")
chart.Drawdown(result, main = "Drawdown")
chart.RiskReturnScatter(result)
apply.yearly(result, Return.cumulative)

yr_plot(result)

Return.cumulative(result)
Return.annualized(result)
StdDev.annualized(result)
SharpeRatio.annualized(result)
maxDrawdown(result)

result.stat = function(R) {
  stat = rbind(
    Return.cumulative(R),
    Return.annualized(R),
    StdDev.annualized(R),
    SharpeRatio.annualized(R),
    maxDrawdown(R)
  )
  return(stat)
}
result.stat(result)
    

