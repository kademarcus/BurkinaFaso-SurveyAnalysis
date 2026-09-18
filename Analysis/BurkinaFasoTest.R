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
