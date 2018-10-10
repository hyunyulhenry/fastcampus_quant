ticker = read.csv("KOR_ticker.csv", row.names = 1)
fs = readRDS("KOR_fs.RDS")

fs.ROE = fs$계속영업이익 / fs$자본
fs.GPA = fs$매출총이익 / fs$자산
fs.CFO = fs$영업활동으로인한현금흐름 / fs$자산

fs.quality = data.frame(cbind(fs.ROE[,3], fs.GPA[,3], fs.CFO[,3]))
colnames(fs.quality) = c("ROE", "GPA", "CFO")
apply(fs.quality, 2, mean, na.rm = TRUE)
apply(fs.quality, 2, median, na.rm = TRUE)
summary(fs.quality)

rank.quality = apply(-fs.quality, 2, rank)
rank.quality = rowSums(rank.quality)
rank.quality = data.frame(rank(rank.quality))

invest.quality = which(rank.quality <= 30)
fs.quality[invest.quality, ]
ticker[invest.quality, 2]
apply(fs.quality[invest.quality, ], 2, median, na.rm = TRUE)
