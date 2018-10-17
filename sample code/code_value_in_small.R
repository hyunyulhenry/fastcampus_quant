ticker = read.csv("KOR_ticker.csv", row.names = 1)
value = read.csv("KOR_value.csv", row.names = 1)

cut.size = quantile(ticker$시가총액, 0.5)
size.big = which(ticker$시가총액 >= cut.size)
size.small = which(ticker$시가총액 < cut.size)

apply(value[size.big, ], 2, median, na.rm = TRUE)
apply(value[size.small, ], 2, median, na.rm = TRUE)

barplot(
  t(cbind(
    apply(value[size.big, ], 2, median, na.rm = TRUE),
    apply(value[size.small, ], 2, median, na.rm = TRUE)
  )),
  beside =TRUE
)

max(ticker[size.small, '시가총액비중...'])

value.normal = value[,1:4]
value.normal[size.big, ] = NA
value.normal[value.normal < 0] = NA

rank.value = apply(value.normal, 2, rank)
rank.value = rowSums(rank.value)
rank.value = data.frame(rank(rank.value))

invest.value = which(rank.value <= 30)
ticker[invest.value, 2]
ticker[invest.value, '시가총액비중...']
value[invest.value, ]

apply(value[invest.value, ], 2, median, na.rm = TRUE)
apply(value[size.small, ], 2, median, na.rm = TRUE)
