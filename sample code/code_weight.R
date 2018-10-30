library(HenryQuant)
library(quantmod)
library(PerformanceAnalytics)
library(FRAPO)

symbols = c("005930.KS", "005380.KS", "015760.KS", "035420.KS", "033780.KS")
# 삼성전자, 현대차, 한국전력, 네이버, KT&G
getSymbols(symbols, src='yahoo', from = "2000-01-01")

prices = do.call(merge, lapply(symbols, function(x) Cl(get(x))))
rets = na.omit(Return.calculate(prices))
colnames(rets) = c("삼성전자", "현대차", "한국전력", "네이버", "KT&G")

charts.PerformanceSummary(rets)
covmat = cov(rets)

mean = Return.annualized(rets)
vol = StdDev.annualized(rets)

par(mfrow = c(1,2))
barplot(mean, main = "MEAN")
barplot(vol, main = "VOL")

### GET Weight ###

w_ew = rep(0.2, 5)  # Equal Weight
w_naive = (1/vol) / sum(1/vol)
w_rp = wt_RiskBudget(covmat, rep(0.2, 5))  # Risk Parity
w_mv = wt_minvol(covmat) # Min Vol
w_mdp = wt_maxdiv(covmat) # Max div

rc_ew = mrc(w_ew, covmat)
rc_naive = mrc(w_naive, covmat)
rc_rp = mrc(w_rp, covmat)
rc_mv = mrc(w_mv, covmat)
rc_mdp = mrc(w_mdp, covmat)

barplot(rc_ew, main = "RC: Equal Weight")
barplot(rc_naive, main = "RC: Naive Risk Parity")
barplot(rc_rp, main = "RC: Risk Parity")
barplot(rc_mv, main = "RC: Min Vol")
barplot(rc_mdp, main = "RC: Max Diverfication")

cbind(
  dr(w_ew, covmat),
  dr(w_naive, covmat),
  dr(w_rp, covmat),
  dr(w_mv, covmat),
  dr(w_mdp, covmat)
)

