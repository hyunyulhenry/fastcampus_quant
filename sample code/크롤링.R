## 크롤링 시에는 웹브라우저로 구글의 Chrome을 사용하는 것이 훨씬 편합니다. ##

install.packages("rvest")
install.packages("httr")

library(rvest)
library(httr)

### GET ###

# 네이버 금융의 주요뉴스 #
url = "https://finance.naver.com/news/mainnews.nhn"
news = GET(url)

news = read_html(news) # 네이버는 인코딩이 euc-kr로 이루어져 있어 오류가 발생합니다.
guess_encoding(news)
news = read_html(news, encoding = "euc-kr")

# title = html_nodes(news, ".articleSubject")
# title = html_text(title)
# title = gsub("\t", "", title)
# title = gsub("\n", "", title)

title = html_nodes(news, ".articleSubject") %>%
  html_text(.) %>%
  gsub("\t", "", .) %>%
  gsub("\n", "", .)



### POST ###
url = "https://www.kodex.com/product.do?fundId=2ETF01&pageCode=020102&stkTicker=069500" # KODEX 200
# F12를 눌러 개발자도구 화면을 연 채로, 엑 다운로드
# 개발자도구 화면의 Network 확인
# getXLSProduct... 확인

# Requst URL: https://www.kodex.com/getXlsProductPdf.do?fundId=2ETF01&fundNm=KODEX%20200&searchDateFrom=&searchDateTo=20181019
# 이중 ? 뒷부분은 POST로 이루어진 부분
# 따라서 앞부분이 url, 뒷부분은 POST로 만들어진 쿼리 부분

KODEX200_PDF = POST("https://www.kodex.com/getXlsProductPdf.do",
                    query = list(fundId = "2ETF01",
                                 fundNm = "KODEX 200",
                                 searchDateTo = "20181019")
)

Sys.setlocale("LC_ALL", "Korean")

data = read_html(KODEX200_PDF) %>% html_text
data = read_csv(data)
download.file(KODEX200_PDF$url, destfile = "./PDF.xls",
              mode = "wb", method="libcurl")

library(readxl)
PDF = read_xls("PDF.xls") %>% data.frame()               

# 날짜를 20181018로 바꾸어서 다시 해보기
# Fund ID와 Fund Name을 바꾸면, 원하는 ETF 데이터 받을 수 있음

## NAVER에서 주가 데이터 다운로드 ##

# https://finance.naver.com/item/sise.nhn?code=005930
# 네이버 금융에서 주가부분 확인
# 개발자도구 화면 연 상태에서, 일별시세의 [2] 클릭
# sise_day 확인
# Request url: https://finance.naver.com/item/sise_day.nhn?code=005930&page=2
# 위의 url에서 page를 1로 변경

url = "https://finance.naver.com/item/sise_day.nhn?code=005930&page=1"
price = GET(url) %>%
  read_html() %>%
  html_text()
# 해당 방식은 지나치게 복잡해짐

Sys.setlocale("LC_ALL", "English")
price = GET(url) %>%
  read_html() %>%
  html_table()

price[[1]] # 시세 테이블
price[[2]] # 페이지 번호

price = price[[1]]
Sys.setlocale("LC_ALL", "Korean")

price = price[,c(1,5)]
price[price == ""] = NA
price = na.omit(price)

library(lubridate)
price[,1] = ymd(price[,1])
price[,2] = gsub(",", "", price[,2]) %>% as.numeric()

rownames(price) = price[,1]
price[,1] = NULL

library(xts)
price = as.xts(price)

# 동일작업을 page 번호를 for loop 돌린다면 종목의 데이터 받을 수 있음


## Daum에서 주가 다운로드

# http://finance.daum.net/quotes/A005930#current/quote
# 삼성전자의 현재가 확인
# 개발자도구 연 상태에서 일자별 주가의 [2] 클릭
# days?symbol 확인
# Request url : http://finance.daum.net/api/quote/A005930/days?symbolCode=A005930&page=2&perPage=10&pagination=true
# JSON 형태임이 확인됨

library(jsonlite)
url = "http://finance.daum.net/api/quote/A005930/days?symbolCode=A005930&page=2&perPage=10&pagination=true"
data = fromJSON(url)
data = data$data

# 훨씬 깔끔한 형태로 다운로드 받아짐이 확인됨
# perPage 부분을 1000으로 바꾸어 봄

url = "http://finance.daum.net/api/quote/A005930/days?symbolCode=A005930&page=2&perPage=1000&pagination=true"
data = fromJSON(url)
data = data$data

# 한번에 1000일의 주가가, 빠르게 다운로드 됨
price = data$tradePrice %>% data.frame()
rownames(price) = substr(data$date, 1, 10)
price = as.xts(price)

# 해당 작업을 모든 티커에 적용한 것이 get_KOR_price()


# Company Guide에서 요약재무제표 다운로드

# http://comp.fnguide.com
# 재무제표 메뉴 클릭
# http://comp.fnguide.com/SVO2/ASP/SVD_Finance.asp?pGB=1&gicode=A005930&cID=&MenuYn=Y&ReportGB=&NewMenuID=103&stkGb=701

Sys.setlocale("LC_ALL", "English")

url = "http://comp.fnguide.com/SVO2/ASP/SVD_Finance.asp?pGB=1&gicode=A005930&cID=&MenuYn=Y&ReportGB=&NewMenuID=103&stkGb=701"
tables = GET(url) %>%
  read_html() %>%
  html_table()

tables[[1]]
Sys.setlocale("LC_ALL", "Korean")
tables[[1]]

# 1: 포괄손익계산서 (연결 / 연간)
# 2: 포괄손익계산서 (연결 / 분기)
# 3: 재무상태표 (연결 / 연간)
# 4: 재무상태표 (연결 / 분기)
# 5: 현금흐름표 (연결 / 연간)
# 6: 현금흐름표 (연결 / 분기)

data.IS = tables[[1]]
data.BS = tables[[3]]
data.CF = tables[[5]]

data.cleansing = function(data) {
  data[,1] = gsub("계산에 참여한 계정 펼치기", "", data[,1])
  data = data[!duplicated(data[,1]), ]
  rownames(data) = data[,1]
  data[,1] = NULL
  
  data[data == ""] = NA
  for (i in 1:ncol(data) ) {
    data[,i] = gsub(",", "", data[,i]) %>% as.numeric()
  }
  
  return(data)
}

data.IS = data.cleansing(data.IS)
data.BS = data.cleansing(data.BS)
data.CF = data.cleansing(data.CF)

data.IS = data.IS[, 1: (ncol(data.IS)-2)]
data.FS = rbind(data.IS, data.BS, data.CF)


# 원하는 부분의 데이터만 다운로드하기

# http://comp.fnguide.com/ 접속
# PER, PBR, 배당수익률, 수익률

url = "http://comp.fnguide.com/SVO2/ASP/SVD_main.asp?pGB=1&gicode=A005930&cID=&MenuYn=Y&ReportGB=&NewMenuID=11&stkGb=&strResearchYN="
data = GET(url) %>% read_html 

# PER
# xpath : //*[@id="corp_group2"]/dl[1]/dd
# "를 '로 변경 
data.PER = html_nodes(data, xpath = "//*[@id='corp_group2']/dl[1]/dd") %>%
  html_text() %>%
  as.numeric()

# PBR
# xpath : //*[@id="corp_group2"]/dl[4]/dd
data.PBR = html_nodes(data, xpath = "//*[@id='corp_group2']/dl[4]/dd") %>%
  html_text() %>%
  as.numeric()

# 배당수익률
# xpath : //*[@id="corp_group2"]/dl[5]/dd
data.DY = html_nodes(data, xpath = "//*[@id='corp_group2']/dl[5]/dd") %>%
  html_text() %>%
  gsub("%", "", .) %>%
  as.numeric()

data.value = cbind(data.PER, data.PBR, data.DY)

# 수익률 4개 -> 데이터프레임으로 만들기
# xpath : //*[@id="svdMainGrid1"]/table/tbody/tr[3]/td[1]
price = html_nodes(data, xpath = "//*[@id='svdMainGrid1']/table/tbody/tr[3]/td[1]") %>%
  html_text()

price = gsub(" ", "", price) %>%
  gsub("\r", "", .) %>%
  gsub("\n", "", .) 

price = strsplit(price, "/") %>% unlist() %>% data.frame()
rownames(price) = c("1M", "3M", "6M", "12M")


## tryCatch 구문 ##
result = tryCatch({
  expr
}, warning = function(w) {
  warning-handler-code
}, error = function(e) {
  error-handler-code
}, finally = {
  cleanup-code
}
)

# expr : 실행하고자 하는 코드
# warning-handler-code : 경고 발생시 실행할 코드
# error : 오류 발생시 실행할 코드
# finally : 여부에 관계없이 실행할 코드


sample = list(1, 2, "3", 4)
for (i in sample) {
  result = i^2
  print(result)
}

# "3"은 제곱이 불가능 하여 에러가 발생
sample = list(1, 2, "3", 4)

for (i in sample) {
  tryCatch({
    result = i^2
    print(result)
  }, error = function(e) {
  print("error") }
  )
}

# Error 발생시 error라는 단어 프린트 한 후 넘어가


# 한국거래소에서 모든종목 티커 다운로드 받기
# http://marketdata.krx.co.kr/mdi#document=040402
# 관리자 모드 연채로 csv 클릭
# GenerateOTP.. : OTP 생성

url = "http://marketdata.krx.co.kr/contents/COM/GenerateOTP.jspx"
data = POST(url, query = list(
  name = "fileDown",
  filetype = "csv",
  url = "MKD/04/0404/04040200/mkd04040200_01",
  market_gubun = "ALL", ## 전체 / 코스피 / 코스닥 부분
  sect_tp_cd = "ALL", 
  schdate = "20181022", ## 원하는 날짜
  pagePath = "/contents/MKD/04/0404/04040200/MKD04040200.jsp"
))

data_otp = read_html(data) %>% html_text

## 위에서 생선된 OTP를 바탕으로
## download.jspx에서 데이터 요청
## url: http://file.krx.co.kr/download.jspx
ticker = POST("http://file.krx.co.kr/download.jspx", query = list(
 code = data_otp 
))

## 다운로드 받은 데이터 중 텍스트 만을 뽑아냄
ticker = read_html(ticker) %>% html_text

## 위의 형식은 csv 파일이므로, read_csv 함수를 이용해 읽음
library(readr)
ticker = read_csv(ticker) %>% data.frame()

# NAVER에서 전종목 PER 크롤링하기
library(HenryQuant)
ticker = get_KOR_ticker()

PER = list()
# for (i in 1 : nrow(ticker)) {
for (i in 1 : 10) {
  name = ticker[i, 1]
  url = paste0("https://finance.naver.com/item/main.nhn?code=",name)
  tryCatch({
    data = GET(url) %>%
      read_html(., encoding = "euc-kr") %>%
      html_nodes(., xpath = "//*[@id='_per']") %>%
      html_text() %>%
      as.numeric()
  }, error = function(e) {NA}
  )

  PER[[i]] = data
  print(paste(i / nrow(ticker), ticker[i, 2]))
  Sys.sleep(2)
}

PER = do.call(rbind, PER)
write.csv(PER, "PER_list.csv")
