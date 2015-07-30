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
library(dplyr)

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
#player_awards
###########
# Create an object for the URL where your data is stored.
url <- "https://raw.githubusercontent.com/DataWizKid/NBA-Stats/master/basketball_awards_players.csv"

# Use getURL from RCurl to download the file.
myData <- getURL(url, ssl.verifypeer = FALSE)

# Finally let R know that the file is in .csv format so that it can create a data frame.
player_awards <- read.csv(textConnection(myData), header=TRUE, 
                          sep=",") 

#player_allstar
###########
# Create an object for the URL where your data is stored.
url <- "https://raw.githubusercontent.com/DataWizKid/NBA-Stats/master/basketball_player_allstar.csv"

# Use getURL from RCurl to download the file.
myData <- getURL(url, ssl.verifypeer = FALSE)

# Finally let R know that the file is in .csv format so that it can create a data frame.
player_allstar <- read.csv(textConnection(myData), header=TRUE, 
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

<<<<<<< HEAD

e <- filter(player_allstar, season_id == yr)
f <- select(e, player_id, games_played)
f <- rename(f,allstar=games_played)
f <- rename(f,playerID=player_id)
g <-  inner_join(d,f)

g$allstar

teams <- distinct(select(d, tmID))

attach(g)
#pct of team calculations
g$pt_pct <- points / o_pts
g$pt_fgm <- fgMade / o_fgm
g$pt_fga <- fgAttempted / o_fga
g$pt_ast <- assists / o_asts
g$pt_to <- turnovers / o_to
g$pts_per48 <- points / minutes * 48


#PER calculation components
g$fac <- (2/3) * (0.50 * (log(assists)/log(fgMade)) / (2 * log(fgMade)/log(ftMade)))
g$vop <- log(points) / (log(fgAttempted)+log(oRebounds)+log(turnovers)+log(ftAttempted)*0.44)
g$drbp <- (log(rebounds) - log(oRebounds)) / log(rebounds) * 1.00
ls()
detach(g)

summary(g)
g
=======
teams <- distinct(select(d, tmID))

attach(d)
d$fac <- (2/3) * (0.50 * (log(assists)/log(fgMade)) / (2 * log(fgMade)/log(ftMade)))
d$vop <- log(points) / (log(fgAttempted)+log(oRebounds)+log(turnovers)+log(ftAttempted)*0.44)
d$drbp <- (log(rebounds) - log(oRebounds)) / log(rebounds) * 1.00
ls()
detach(d)

summary(d)
d
>>>>>>> b11515f154949ab1e1004ffc9304a1f0ef2921a3
