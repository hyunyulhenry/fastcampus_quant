# 워킹 디렉토리 찾기 및 설정 #
getwd()
setwd("C:/Users/Henry/Downloads")

# CSV 데이터 읽기 / 쓰기 #
data_1 = read.csv("price_m.csv") # 기본적인 csv 파일 불러오기
data_2 = read.csv("price_m.csv", header = F) # 열이름(header)를 FALSE로 지정
data_3 = read.csv("price_m.csv", row.names = 1) # 첫번째 열을 행이름으로 지정
write.csv(data_3, "price_data.csv")

# 패키지 설치 및 EXCEL 파일 불러오기 #
install.packages("openxlsx")
library(openxlsx)
price = read.xlsx("KOSPI200_data.xlsx", sheet = "price_m")
price = read.xlsx("KOSPI200_data.xlsx", sheet = "price_m",
                  rows = c(10, 15:100000), rowNames = TRUE, colNames = TRUE,
                  detectDates = TRUE)


# 수익률 및 누적수익률 구하기 #
n = nrow(price)
ret_1 = (price[2:n, ] / price[1:(n-1), ]) - 1

install.packages("PerformanceAnalytics")
library(PerformanceAnalytics)
ret_2 = Return.calculate(price)

dim(price)
dim(ret_1)
dim(ret_2)

ss = ret_2[, 1] # numeric 형태로 데이터가 깨짐
ss = ret_2[ ,1 , drop = FALSE]
ss[is.na(ss)] = 0

ss_cum = cumprod(1+ss) - 1
plot(ss_cum[,], type = 'l')
plot(as.xts(ss_cum))

chart.CumReturns(ss)

# 분기 및 년도별 수익률로 변환 #
ret_q = apply.quarterly(ss, Return.cumulative) # 분기별 수익률
ret_yr = apply.yearly(ss, Return.cumulative) # 연도별 수익률

ret_q
ret_yr

barplot(t(ret_yr))
barplot(t(ret_yr), names.arg = substr(rownames(ret_yr), 1,4), las = 2)
chart.Bar(ret_yr)

# 통계값 구하기 #
Return.cumulative(ss)
Return.annualized(ss)
StdDev.annualized(ss)
maxDrawdown(ss)
skewness(ss)

stat_f = function(ret) {
  x = rbind(Return.cumulative(ret),
            Return.annualized(ret),
            StdDev.annualized(ret),
            maxDrawdown(ret),
            skewness(ret))
  rownames(x) = c("Cum Ret", "Ann Ret", "Ann Std", "MDD", "Skew")
  return(x)
}

kepco = ret_2[,2 , drop = FALSE]
stat_f(ss)      # 삼성전자 통계값
stat_f(kepco)   # 한국전력 통계값


SharpeRatio.annualized(ss)
SharpeRatio.annualized(as.xts(ss)) # xts 형태로 데이터 변환

# 12개월 롤링 수익률 및 변동성 #
lookback = 12

ss = as.xts(ss)
roll_mom = rollapply(ss, 12, Return.cumulative)
roll_std = rollapply(ss, 12, sd)

plot(roll_mom, type = 'l')
plot(roll_std, type = 'l')

# 인터넷에서 주가 받기 #
install.packages("quantmod")
library(quantmod)
symbols = "005930.KS"
getSymbols(symbols, src='yahoo', auto.assign=TRUE, 
           from = '2000-01-01', to = Sys.Date())

price = Cl(`005930.KS`)
ret = Return.calculate(price)
charts.PerformanceSummary(ret)

# 절대모멘텀 구하기 #
symbols = "SPY"
getSymbols(symbols, src='yahoo', auto.assign=TRUE, 
           from = '2000-01-01', to = Sys.Date())
price = Cl(SPY)
ret = Return.calculate(price)
ret_m = apply.monthly(ret, Return.cumulative)
ret_mom = rollapply(ret_m, 12, Return.cumulative)

mom_test = data.frame(matrix(NA, nrow(ret_mom), 2))
rownames(mom_test) = index(ret_m) 
colnames(mom_test) = c("S&P 500 Timing", "S&P 500")
lookback = 12
for (i in lookback : (nrow(ret_mom)-1) ) {
  if (ret_mom[i, 1] > 0) {
    mom_test[i+1, 1] = ret_m[i+1, 1]
  } else {
    mom_test[i+1, 1] = 0
  }
  
  mom_test[i+1,2] = ret_m[i+1, 1]
}

mom_test = as.xts(mom_test)
chart.CumReturns(mom_test)
apply.yearly(mom_test, Return.cumulative)

chart.CumReturns(mom_test["2006::2009"])
Return.cumulative(mom_test)
