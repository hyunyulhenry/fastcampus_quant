library(xts)
library(PerformanceAnalytics)

ticker = read.csv("KOR_ticker.csv", row.names = 1)
price = read.csv("KOR_price.csv", row.names = 1)
price = as.xts(price)
value = read.csv("KOR_value.csv", row.names = 1)
fs = readRDS("KOR_fs.RDS")

value[mapply(is.infinite, value)] = NA

### Momentum ###
ret = Return.calculate(price)

ret.list = list()
ret.list[[1]] = last(ret, "3 months")
ret.list[[2]] = last(ret, "6 months")
ret.list[[3]] = last(ret, "9 months")
ret.list[[4]] = last(ret, "12 months")

ret.cum.list = sapply(ret.list, Return.cumulative)       
colnames(ret.cum.list) = c("3m", "6m", "9m", "12m")

### Quality ###
fs.temp = list()
fs.temp$ROE = fs$계속영업이익 / fs$자본
fs.temp$GPA = fs$매출총이익 / fs$자산
fs.temp$CFO = fs$영업활동으로인한현금흐름 / fs$자산

fs.profit = sapply(fs.temp, function(x) {
  x[,3]
})

### Value ###
value.normal = value[,1:4]
value.normal[value.normal < 0] = NA

### Calculate Rank ###
rank.momentum = apply(-ret.cum.list, 2, rank)
rank.momentum = rowSums(rank.momentum)
rank.momentum = data.frame(rank.momentum)

# Using magrittr #
# library(magrittr)
# rank.momentum = apply(-ret.cum.list, 2, rank) %>%
#   rowSums(.) %>%
#   data.frame(.)

rank.quality = apply(-fs.profit, 2, rank) %>%
  rowSums(.) %>%
  data.frame(.)

rank.value = apply(value.normal, 2, rank) %>%
  rowSums(.) %>%
  data.frame(.)

### Scale and Sum ###
x1 = scale(rank.momentum) 
x2 = (rank.momentum - mean(unlist(rank.momentum))) /
  sd(unlist(rank.momentum))
x3 = cbind(x1, x2)

rank.scale = cbind(scale(rank.momentum),
                   scale(rank.quality),
                   scale(rank.value))

rank.scale =
  0.333 * rank.scale[,1] +
  0.333 * rank.scale[,2] +
  0.333 * rank.scale[,3]

rank.scale = rank(rank.scale) %>%
  data.frame()

invest.QVM = which(rank.scale <= 30)

ret.cum.list[invest.QVM, ]
fs.profit[invest.QVM, ]
value.normal[invest.QVM, ]
ticker[invest.QVM, 2]


#################################
############ Advanced ###########
#################################

scale.momentum = data.frame(apply(-ret.cum.list, 2, scale))
scale.momentum.rank = apply(-ret.cum.list, 2, rank) %>%
  scale() %>%
  data.frame()

par(mfrow = c(2,2))
lapply(scale.momentum, hist)
lapply(scale.momentum.rank, hist)

max(scale.momentum, na.rm = TRUE)

scale.momentum[scale.momentum <= -3] = NA
scale.momentum[scale.momentum >= 3] = NA

max(scale.momentum, na.rm = TRUE)
min(scale.momentum, na.rm = TRUE)
lapply(scale.momentum, hist)

scale.quality = data.frame(apply(-fs.profit, 2, scale))
scale.quality[scale.quality <= -3] = NA
scale.quality[scale.quality >= 3] = NA

scale.value = data.frame(apply(value.normal, 2, scale))
scale.value[scale.value <= -3] = NA
scale.value[scale.value >= 3] = NA

scale.QVM = 1*rowSums(scale.momentum) +
  1*rowSums(scale.quality) +
  1*rowSums(scale.value)

invest.QVM = which(rank(scale.QVM) <= 30)

ret.cum.list[invest.QVM, ]
fs.profit[invest.QVM, ]
value.normal[invest.QVM, ]
ticker[invest.QVM, 2]
