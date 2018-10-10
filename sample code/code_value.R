ticker = read.csv("KOR_ticker.csv", row.names = 1)
value = read.csv("KOR_value.csv", row.names = 1)

apply(value, 2, median, na.rm = TRUE)
summary(value)

value.normal = value[,1:4]
value.div = value[,5]

# High Div #
invest.div = which(rank(-value.div) <= 30)
value.div[invest.div]
ticker[invest.div, 2]

# Value (MIX) #
value.normal[value.normal < 0] = NA
rank.value = apply(value.normal, 2, rank)
rank.value = rowSums(rank.value)
rank.value = data.frame(rank(rank.value))

invest.value = which(rank.value <= 30)
value.normal[invest.value, ]
ticker[invest.value, 2]
apply(value.normal[invest.value, ], 2, median, na.rm = TRUE)


