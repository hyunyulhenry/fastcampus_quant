# 대부분의 코드는 'R Cookbook'의 예제입니다. #

# 기본 입력 #
1+1
max(1,3,5)

# HELP 명렁어 #
help(max) # 도움말
?max

# print, cat 통한 출력 #
print("A")
print("A","B") # Error
cat("A","B") # 2개 이상 출력시 cat 사용

# 기본 통계 명령어 #
x = c(0,1,1,2,3,5,8,13,21,34)
mean(x) # 평균
median(x) # 중위수
sd(x) # 표준편차
var(x) # 분산
y = log(x+1)
plot(x,y) # x,y축으로 그래프
cor(x,y) # 상관관계
cov(x,y) # 공분산

# 결측치 처리 #
z = c(0,1,2,3,NA)
z
mean(z) 
sd(z)
is.na(z) # NA인 곳의 위치
!is.na(z) # not NA인 곳의 위치(!는 not을 의미)
mean(z, na.rm = TRUE)  # NA 데이터를 remove
sd(z, na.rm = TRUE)

# rep와 seq 이용한 등차수열 처리 #
1:5
5:1
rep(1, 5) # 1을 5번 반복
rep("A",5) # A를 5번 반복
seq(from=1, to=5, by=2) # 1에서 5까지, 2개 숫자 등차수열
seq(from=1, to=20, length.out = 5) # 1에서 20까지, 총 5개 숫자

# 두 데이터 간 비교 #
x = 1
y = 2
x == y # 동일여부 비교
x != y # 비동일여부 비교
x > y 
x >= y 
x <= y

# 벡터 간 비교 #
m = c(1,2,3)
n = c(3,2,1)
m == n
m != n
m >= n

l = 2
m == l  # 벡터 간 갯수가 달라도 비교 가능

# 원소 선택하기 #
fibo = c(0,1,1,2,3,5,8,13,21,34)
fibo[1]
fibo[1:3]
fibo[c(1,5:7)]
fibo[c(1,3,5,7)]
fibo[-1] # 첫번째 데이터 제거
fibo[-c(1:3)] # 첫번째에서 세번째 데이터 제거
fibo < 10 # 기준에 해당하면 TRUE, 아니면 FALSE
which(fibo < 10) # 파이썬 중 np.where, TRUE인 인덱스를 반호

fibo[fibo < 10]
fibo[which(fibo < 10)]

# 벡터에 인덱스 부여하기 #
years = c(1960, 1964, 1976, 1994)
names(years) = c("Kennedy", "Johnson", "Carter", "Clinton")
years
years["Carter"]
years[c("Carter","Clinton")]

# 벡터 간 연산 #
v = c(1,2,3,4,5)
w = c(6,7,8,9,10)

v + w
v - w
v * w
v / w
v ^ w
v %*% w

v + 2
v * 2
v ^ 2
v - mean(v)
( v - mean(v) ) / sd(v) # Z-score
scale(v)

#--- 괄호 위치 ---#
n = 5
1:n + 1 # 1에서 5까지 구한 다음 1을 더함
1:(n + 1) # 1에서 6까지 구함

# head 및 tail 구문 #
data() # R Data Sets list
pressure
head(pressure) # 상위 6개
head(pressure, 10) # 상위 10개
tail(pressure) # 하위 6개
tail(pressure, 10) # 하위 10개

# 매트릭스 만들기 #
Data = rnorm(9, mean = 0, sd = 1) # 평균이 0, 표준편차가 1인 9개 랜던변수
Data
mat = matrix(Data, 3,3) # 3행 3열 매트릭스
mat

matrix(0,3,3)
matrix(NA,2,3)

t(mat) # 전치 행렬
mat * t(mat)
mat %*% t(mat)
solve(mat)

rownames(mat) = c("A", "B", "C")
colnames(mat) = c("X", "Y", "Z")
mat

# 매트릭스 행 또는 열 선택하기 #
mat[1,] # 행 선택
mat[,1] # 열 선택
mat[,2:3]
mat[,c(1,3)]

row1 = mat[1, ] # 형식이 버려짐
row2 = mat[1, , drop = FALSE] # 형식 유지

rbind(mat[1, ], mat[3, ]) # 1행과 3행을, 행의 형태로 묶기
cbind(mat[, 1], mat[ ,3]) # 1열과 3열을, 열의 형태로 묶기

# 매트릭스 행 또는 열 갯수 #
length(mat)
dim(mat)
dim(mat)[1]
dim(mat)[2]
nrow(mat)
ncol(mat)

# NA 처리하기 #
na_test = data.frame(v1 = c(-0.9714, NA, 0.3367, 1.7520, 0.4918),
                     v2 = c(-0.4578, 3.1663, NA, 0.7406, 1.4541)
                     ) # 데이터 프레임 만들기
na_test
cumsum(na_test)
na.omit(na_test)
cumsum(na.omit(na_test))
is.na(na_test)
which(is.na(na_test))

na_test[is.na(na_test)] = 0 # NA 데이터는 0으로 만들기
na_test

# 데이터 형식 변환하기 #
a = matrix(1:9, 3,3)
b = as.data.frame(a)
b$V1
colnames(b) = c("Alpha", "Beta", "Theta")
b$Alpha
c = as.numeric(a)
d = as.matrix(b)
e = as.matrix(c)

# apply 함수 #
mat = data.frame(matrix(1:25, 5, 5))
apply(mat, 1, mean)
apply(mat, 2, mean)
apply(mat, 1, min)
apply(mat, 2, max)

mat_frame = as.data.frame(mat)
apply(mat_frame, 1, mean)
apply(mat_frame, 2, mean)
lapply(mat_frame, mean)
sapply(mat_frame, mean)

# 문자열 #
paste("Everybody","loves","quant.")
paste("Everybody","loves","quant.",sep="-")
paste("Everybody","loves","quant.",sep="")
paste0("Everybody","loves","quant.")

tx = "HenryQuant"
substr(tx, 1, 5)
substr(tx, 6, 10)

# 날짜 #
Sys.Date()
test = c("2010-12-31")
test_2 = as.Date(test)

s = as.Date("2012-01-01")
e = as.Date("2012-02-01")
seq(from=s, to=e, by=1)
seq(from=s, by=1, length.out=7)
seq(from=s, by="month",length.out=12)
seq(from=s, by="quarter",length.out=12)
seq(from=s, by="year",length.out=12)

# 그래프 그리기 #

# https://opentutorials.org/module/1952/13002
plot(cars)
abline(a=0, b=2, col = 2)
grid()
dev.off()

par(mfrow = c(1,2))
plot(cars, pch = 2, col = 2, xlab = "", ylab ="")
legend('topleft', pch = 1, lty = 1, "CARS")
plot(cars, pch = 4, col = 4)
legend('topleft', pch = 1, lty = 1, "CARS")
dev.off()

par(mfrow = c(1,3))
plot(pressure)
plot(pressure, lty = 2, lwd = 5)
plot(pressure, type = "l")
dev.off()

par(mfrow = c(2,2))
heights = tapply(airquality$Temp, airquality$Month, mean)
barplot(heights)
barplot(heights,
        main = "Mean Temp. by Month",
        names.arg = c("May", "Jun", "Jul", "Aug", "Sep"),
        ylab = "Temp (deg. F)",
        xlab = "Month",
        col = 1:5
)
barplot(heights, col = rainbow(5))
boxplot(pressure$temperature)
dev.off()

par(mfrow = c(1,2))
x = rnorm(10000)
hist(rnorm(x))
hist(rnorm(x), main = "Normal Distribution",
     xlab = "X", ylab = "Y", xlim = c(-3,3),
     col = 3, breaks = 100, prob = T)
lines(density(x), col = 2, lwd = 2)
dev.off()

# 분위수 구하기 #
x = rnorm(1000)

quantile(x)
quantile(x, 0.2)
quantile(x, c(0.2, 0.4))

# 데이터 위치찾기 #
vec = c(100,90,80,70,60,50,40,30,20,10)
match(80, vec)
which(vec == 80)
which.max(vec)
which.min(vec)

# 정렬 및 순위 #
daily.prod = data.frame(Widgets = c(179, 153, 183, 153, 154),
                        Gadgets = c(167, 193, 190, 161, 181),
                        Thingys = c(182, 166, 170, 171, 186)
                        )
rownames(daily.prod) = c("Mon","Tue","Wed","Thu","Fri")

daily.prod$Widgets
order(daily.prod$Widgets)

rank(daily.prod$Widgets)
rank(-daily.prod$Widgets)

# 리스트 형식 #
numbers = list(1,3,5,7,9)
mean(numbers)
unlist(numbers)
mean(unlist(numbers))

lists = list(col1 = list(7,8,9),
             col2 = list(70,80,90),
             col3 = list(700,800,900))
lapply(lists, function(x) {
  mean(unlist(x))
})

# for, if 구문 #
for (i in 1 : 10) {
  print(i)
}

for (i in 1 : 10) {
  if (i %% 2 == 0) {
    print(paste(i, "is EVEN"))
  }
}

for (i in 1 : 10) {
  if (i %% 2 == 0) {
    print(paste(i, "is EVEN"))
  } else {
    print(paste(i, "is ODD"))
  }
}