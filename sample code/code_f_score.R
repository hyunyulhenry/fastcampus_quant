ticker = read.csv("KOR_ticker.csv", row.names = 1)
fs = readRDS("KOR_fs.RDS")

f_score = list()
f_score$ROA = fs$계속영업이익 / fs$자산
f_score$CFO = fs$영업활동으로인한현금흐름 / fs$자산
f_score$accrual = f_score$CFO - f_score$ROA 
f_score$lev = fs$장기차입금 / fs$자산
f_score$liquid = fs$유동자산 / fs$유동부채
f_score$margin = fs$매출총이익 / fs$매출액
f_score$turnover = fs$매출액 / fs$자산
f_score$offer = fs$유상증자
f_score$offer[is.na(f_score$offer)] = 0

f_score$delta.ROA = data.frame(f_score$ROA[, 3] - f_score$ROA[, 2])
f_score$delta.lev = data.frame(f_score$lev[, 3] - f_score$lev[, 2])
f_score$delta.liquid = data.frame(f_score$liquid[, 3] - f_score$liquid[, 2])
f_score$delta.margin = data.frame(f_score$margin[, 3] - f_score$margin[, 2])
f_score$delta.turnover= data.frame(f_score$turnover[, 3] - f_score$turnover[, 2])

f_table = list()
f_table[[1]] = as.integer(f_score$ROA[, ncol(f_score$ROA)] > 0)
f_table[[2]] = as.integer(f_score$CFO[, ncol(f_score$CFO)] > 0)
f_table[[3]] = as.integer(f_score$delta.ROA[, ncol(f_score$delta.ROA)] > 0)
f_table[[4]] = as.integer(f_score$accrual[, ncol(f_score$accrual)] > 0)
f_table[[5]] = as.integer(f_score$delta.lev[, ncol(f_score$delta.lev)] < 0)
f_table[[6]] = as.integer(f_score$delta.liquid[, ncol(f_score$delta.liquid)] > 0)
f_table[[7]] = as.integer(f_score$offer[, ncol(f_score$offer)] == 0)
f_table[[8]] = as.integer(f_score$delta.margin[, ncol(f_score$delta.margin)] > 0)
f_table[[9]] = as.integer(f_score$delta.turnover[, ncol(f_score$delta.turnover)] > 0)

f_table = do.call(cbind, f_table)

score = data.frame(apply(f_table, 1, sum, na.rm = TRUE))
rownames(score) = ticker[, 2]
colnames(score) = "F Score"

ticker[which(score == 9), 2]
ticker[which(score == 8), 2]
