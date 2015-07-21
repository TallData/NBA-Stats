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


#playoffs
###########
# Create an object for the URL where your data is stored.
url <- "https://raw.githubusercontent.com/DataWizKid/NBA-Stats/master/basketball_series_post.csv"

# Use getURL from RCurl to download the file.
myData <- getURL(url, ssl.verifypeer = FALSE)

# Finally let R know that the file is in .csv format so that it can create a data frame.
team_playoffs <- read.csv(textConnection(myData), header=TRUE, 
                      sep=",") 

#abbrev
###########
# Create an object for the URL where your data is stored.
url <- "https://raw.githubusercontent.com/DataWizKid/NBA-Stats/master/basketball_abbrev.csv"

# Use getURL from RCurl to download the file.
myData <- getURL(url, ssl.verifypeer = FALSE)

# Finally let R know that the file is in .csv format so that it can create a data frame.
nba_abbrv <- read.csv(textConnection(myData), header=TRUE, 
                          sep=",") 

y <- c("playerID","year","GP","tmID",
       "minutes","points","assists","steals",
       "blocks","turnovers", "fgAttempted", 
       "fgMade","fgAttempted", 
       "fgMade","threeAttempted","threeMade")

yr <- 2008

a <- merge(player_hist, player_key,by.x = "playerID", by.y = "bioID")
b <- left_join(a, team_hist,by= c("tmID"="tmID","year"="year"))
d <- filter(b, year == yr)

teams <- distinct(select(d, tmID))

attach(d)
d$fac <- (2/3) * (0.50 * (log(assists)/log(fgMade)) / (2 * log(fgMade)/log(ftMade)))
d$vop <- log(points) / (log(fgAttempted)+log(oRebounds)+log(turnovers)+log(ftAttempted)*0.44)
d$drbp <- (log(rebounds) - log(oRebounds)) / log(rebounds) * 1.00
ls()
detach(d)

summary(d)
d
