################
#####NBA Look
####Packages###
#install.packages("xlsx")
#library(xlsx)
###############

#REmove datasets from enivronment
rm(list=ls())
#list=ls()

# Load required packages 
library(RCurl)

#player_key
###########
# Create an object for the URL where your data is stored.
url <- "https://raw.githubusercontent.com/DataWizKid/NBA-Stats/master/basketball_master.csv"

# Use getURL from RCurl to download the file.
myData <- getURL(url, ssl.verifypeer = FALSE)

# Finally let R know that the file is in .csv format so that it can create a data frame.
player_key <- read.csv(textConnection(myData), header=TRUE, 
                   sep=",") 

#player_hist
###########
# Create an object for the URL where your data is stored.
url <- "https://raw.githubusercontent.com/DataWizKid/NBA-Stats/master/basketball_players.csv"

# Use getURL from RCurl to download the file.
myData <- getURL(url, ssl.verifypeer = FALSE)

# Finally let R know that the file is in .csv format so that it can create a data frame.
player_hist <- read.csv(textConnection(myData), header=TRUE, 
                       sep=",")

#player_hof
###########
# Create an object for the URL where your data is stored.
url <- "https://raw.githubusercontent.com/DataWizKid/NBA-Stats/master/basketball_hof.csv"

# Use getURL from RCurl to download the file.
myData <- getURL(url, ssl.verifypeer = FALSE)

# Finally let R know that the file is in .csv format so that it can create a data frame.
player_hof <- read.csv(textConnection(myData), header=TRUE, 
                        sep=",") 

#team_hist
###########
# Create an object for the URL where your data is stored.
url <- "https://raw.githubusercontent.com/DataWizKid/NBA-Stats/master/basketball_teams.csv"

# Use getURL from RCurl to download the file.
myData <- getURL(url, ssl.verifypeer = FALSE)

# Finally let R know that the file is in .csv format so that it can create a data frame.
team_hist <- read.csv(textConnection(myData), header=TRUE, 
                       sep=",") 
