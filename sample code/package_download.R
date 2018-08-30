# R Package Download #

# 1. CRAN에서 다운로드 가능한 패키지
install.packages("quantmod") # 패키지 설치, 초기 한번만 필요
library(quantmod) # 패키지 열기, 매번 R 실행시 필요


# 2. Github에서 다운로드 받는 경우
install.packages("devtools") #Github과의 연결 위해 devtools 패키지 설치
library(devtools) # 패키지 열기

devtools::install_github("hyunyulhenry/HenryQuant")
# devtools 패키지 중install_github 함수 사용
# 변수로는 패키지가 있는 github 주소 사용
library(HenryQuant) # 패키지 열기
