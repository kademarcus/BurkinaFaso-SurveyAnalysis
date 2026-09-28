rm(list=ls())

#packages
#install.packages("httr")
#install.packages("readr")
#install.packages("dplyr")
#install.packages("usethis")

#libraries
library(httr)
library(readr)
library(dplyr)
library(usethis)

#----------------GET DATA----------------
#Private token
git_token <- readline(prompt = "Enter your GitHub Token: ") #put token into console

#data set
url <- "https://raw.githubusercontent.com/kademarcus/BurkinaFaso-SurveyAnalysis/main/Data/Burkina_Faso_R9_2022%20(2).csv"

#get data
response <- GET(url,
                add_headers(Authorization = paste("Bearer", git_token))
)

survey_data <- read_csv(content(response, "text", encoding = "UTF-8"))


#remove things no longer needed 
rm(url, response, git_token)

survey_data <- read.csv(text = raw)
rm(raw)

View(survey_data)

#----------------CLEANING----------------
#DATES
survey_data$interview_date <- survey_data$DATEINTR/(86400)- 137775

#get readable dates
survey_data$interview_date <- as.Date(survey_data$interview_date, origin = "1960-01-01")

#coup start
survey_data$post_coup <- c(NA)
survey_data$post_coup <- ifelse(survey_data$interview_date > as.Date("2022-09-30"),1,0) #1 for post coup 0 for pre

#coup resolution
survey_data$post_coup1 <- c(NA)
survey_data$post_coup1 <- ifelse(survey_data$interview_date > as.Date("2022-10-3"),1,0) #1 for post coup 0 for pre

#omit days where coup uncertain
survey_data$post_coup2 <- c(NA)
survey_data$post_coup2[survey_data$interview_date > as.Date("2022-10-03")] <- 1
survey_data$post_coup2[survey_data$interview_date < as.Date("2022-09-30")] <- 0


#questions of interest
survey_data <-  survey_data %>%
  select(interview_date, post_coup, post_coup1, post_coup2,
         RESPNO, URBRUR,
         Q22B, Q29B, Q37H, Q80B_BFO, Q81_BFO, Q83A_BFO, 
         Q83B_BFO, Q83C_BFO, Q83D_BFO, Q83E_BFO, Q83F_BFO,
         EA_SEC_B, EA_SEC_B) 


