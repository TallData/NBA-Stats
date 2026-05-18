################
#####NBA Look
####Packahist3_2008es###
#install.packahist3_2008es("xlsx")
#library(xlsx)
###############

#REmove datasets from enivronment
rm(list=ls())
#list=ls()

# Load required packahist3_2008es 
library(RCurl)
library(dplyr)
library(ggplot2)
library(gridExtra)
#library(tidyr)


#player_key
###########
# Create an object for the URL where your data is stored.
url <- "https://raw.githubusercontent.com/DataWizKid/NBA-Stats/master/basketball_master.csv"

# Use hist3_2008etURL from RCurl to download the file.
myData <- getURL(url, ssl.verifypeer = FALSE)

# Finally let R know that the file is in .csv format so that it can create a data frame.
player_key <- read.csv(textConnection(myData), header=TRUE, 
                   sep=",") 

#player_hist
###########
# Create an object for the URL where your data is stored.
url <- "https://raw.githubusercontent.com/DataWizKid/NBA-Stats/master/basketball_players.csv"

# Use hist3_2008etURL from RCurl to download the file.
myData <- getURL(url, ssl.verifypeer = FALSE)

# Finally let R know that the file is in .csv format so that it can create a data frame.
player_hist <- read.csv(textConnection(myData), header=TRUE, 
                       sep=",")

#player_hof
###########
# Create an object for the URL where your data is stored.
url <- "https://raw.githubusercontent.com/DataWizKid/NBA-Stats/master/basketball_hof.csv"

# Use hist3_2008etURL from RCurl to download the file.
myData <- getURL(url, ssl.verifypeer = FALSE)

# Finally let R know that the file is in .csv format so that it can create a data frame.
player_hof <- read.csv(textConnection(myData), header=TRUE, 
                        sep=",") 

#team_hist
###########
# Create an object for the URL where your data is stored.
url <- "https://raw.githubusercontent.com/DataWizKid/NBA-Stats/master/basketball_teams.csv"

# Use hist3_2008etURL from RCurl to download the file.
myData <- getURL(url, ssl.verifypeer = FALSE)

# Finally let R know that the file is in .csv format so that it can create a data frame.
team_hist <- read.csv(textConnection(myData), header=TRUE, 
                       sep=",") 


#playoffs
###########
# Create an object for the URL where your data is stored.
url <- "https://raw.githubusercontent.com/DataWizKid/NBA-Stats/master/basketball_series_post.csv"

# Use hist3_2008etURL from RCurl to download the file.
myData <- getURL(url, ssl.verifypeer = FALSE)

# Finally let R know that the file is in .csv format so that it can create a data frame.
team_playoffs <- read.csv(textConnection(myData), header=TRUE, 
                      sep=",") 

#abbrev
###########
# Create an object for the URL where your data is stored.
url <- "https://raw.githubusercontent.com/DataWizKid/NBA-Stats/master/basketball_abbrev.csv"

# Use hist3_2008etURL from RCurl to download the file.
myData <- getURL(url, ssl.verifypeer = FALSE)

# Finally let R know that the file is in .csv format so that it can create a data frame.
nba_abbrv <- read.csv(textConnection(myData), header=TRUE, 
                          sep=",") 
#player_awards
###########
# Create an object for the URL where your data is stored.
url <- "https://raw.githubusercontent.com/DataWizKid/NBA-Stats/master/basketball_awards_players.csv"

# Use hist3_2008etURL from RCurl to download the file.
myData <- getURL(url, ssl.verifypeer = FALSE)

# Finally let R know that the file is in .csv format so that it can create a data frame.
player_awards <- read.csv(textConnection(myData), header=TRUE, 
                          sep=",") 

#player_allstar
###########
# Create an object for the URL where your data is stored.
url <- "https://raw.githubusercontent.com/DataWizKid/NBA-Stats/master/basketball_player_allstar.csv"

# Use hist3_2008etURL from RCurl to download the file.
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

summary(team_hist)
hist_key <- merge(player_hist, player_key,by.x = "playerID", by.y = "bioID")
hist_team_key <- left_join(hist_key, team_hist,by= c("tmID"="tmID","year"="year"))

target <- c("EC", "WC")
hist_2008 <- filter(hist_team_key, year == yr, confID %in% target )

alstr_2008 <- filter(player_allstar, season_id == yr)
alstr_key <- select(alstr_2008, player_id, games_played)
alstr_key <- rename(alstr_key,allstar=games_played)
alstr_key <- rename(alstr_key,playerID=player_id)
hist2_2008 <-  left_join(hist_2008,alstr_key, by= c("playerID"="playerID"))
hist2_2008$allstar[is.na(hist2_2008$allstar)] <- 0
hist3_2008 <- subset(hist2_2008,GP>0) 

par(mfrow=c(2,2))
c1 <- ggplot(data = hist3_2008, aes(x=points, colour = confID))
#c1 <- ggplot(data = hist3_2008, aes(x=points, colour = confID))
c1 + geom_density()
c1 + geom_bar()
c2 <- ggplot(data = hist3_2008, aes(x=points, fill = confID))
c2 + geom_density(position = "fill")

c3 <- ggplot(hist3_2008, aes(sample=points, colour = confID))
c3 + stat_qq(distribution=qnorm) + 
  geom_abline(data=intsl, aes(intercept=int, slope=slope)) +
  facet_wrap(~confID,nrow=1) + ylab("Point Q-Q Plot") 

grid.arrange(c1 + geom_density(), c1 + geom_bar(position="dodge"), nrow=2, ncol=1)

c4 <- ggplot(data = hist3_2008, aes(y=points, x= turnovers, colour = confID))

lm1 <- lm(hist3_2008 ,formula = points ~ turnovers)

c4 + geom_point() 

look1 <- filter(hist3_2008, is.na(confID) == TRUE)
look2 <- filter(player_key, bioID == "ajincal01")

# hist(hist3_2008$GP)
# shapiro.test(hist3_2008$GP)
# boxplot(GP~confID,data=hist3_2008, main="Car Milage Data", 
#         xlab="Number of Cylinders", ylab="Miles Per Gallon")
# 
 hist3_2008$rownumber = 1:dim(hist3_2008)[1]
# 
par(mfrow=c(2,2))
qqnorm(hist3_2008$GP)
qqline(hist3_2008$GP)
hist(hist3_2008$GP)

mn <-  mean(hist3_2008$GP)
md <-  median(hist3_2008$GP)
stdv <- sd(hist3_2008$GP)

hist3_2008$X <- ((hist3_2008$GP-mn)) / stdv

#hist3_2008 <- hist3_2008[sample(1:nrow(hist3_2008)), ]

calc1 <-  ((md-mn)) / stdv
plot(hist3_2008$rownum, hist3_2008$X)


abline(h=calc1, lty = 2)
# 
hist(hist3_2008[,6])

teams <- distinct(select(hist3_2008, tmID))

attach(hist3_2008)
#pct of team calculations
hist3_2008$pts_gm <- points / GP
hist3_2008$fgm_gm <- fgMade / GP
hist3_2008$fga_gm <- fgAttempted / GP
hist3_2008$ftm_gm <- ftMade / GP
hist3_2008$fta_gm <- ftAttempted / GP
hist3_2008$ast_gm <- assists / GP
hist3_2008$to_gm <- turnovers / GP
hist3_2008$reb_gm <- rebounds / GP
hist3_2008$oreb_gm <- oRebounds / GP
hist3_2008$min_gm <- minutes / GP

#pct of team calculations
hist3_2008$pct_pt <- points / o_pts
hist3_2008$pct_fga <- fgAttempted / o_fga
hist3_2008$pct_ast <- assists / o_asts
hist3_2008$pct_to <- turnovers / o_to
hist3_2008$pct_pp48 <- points / minutes * 48

#player effeciency
hist3_2008$ast_perto <- assists / turnovers
hist3_2008$pts_perfga <- points / fgAttempted

#PER calculation components
hist3_2008$fac <- (2/3) * (0.50 * (log(assists)/log(fgMade)) / (2 * log(fgMade)/log(ftMade)))
hist3_2008$vop <- log(points) / (log(oRebounds)+log(turnovers)+log(fgAttempted)*1.44)
hist3_2008$drbp <- (log(rebounds) - log(oRebounds)) / log(rebounds) * 1.00

ls()
detach(hist3_2008)

head(arrange(hist3_2008,desc(vop)), n = 10)

# select variables v1, v2, v3
myvars <- c("pts_gm","fga_gm","ftm_gm","fta_gm","ast_gm","to_gm","reb_gm","oreb_gm", "pct_pt")
            
h <- hist3_2008[myvars]

??colnames
numsvars1 <- sapply(hist3_2008, is.numeric)
class(numsvars1)
numvars.df <- data.frame(numsvars1)
colnames(numvars.df) <- c("columns","flag")
h2 <- log(h)
cor1 <- cor(h)
cov1 <- cov(h)
pairs(h)
pairs(h2)


?select

#principal component analysis
prc_1 <- prcomp(~pts_gm+fgm_gm+fga_gm+ftm_gm+fta_gm+ast_gm+to_gm+reb_gm+oreb_gm, data = hist3_2008 )
summary(prc_1)
print(prc_1)
plot(prc_1)
predict(prc_1)

summary(hist3_2008$allstar)# display results
class(hist3_2008$allstar)# display results

#hist3_2008$fac
#hist3_2008$drbp

train = sample(hist3_2008, size = round(0.7*n), replace=FALSE)
hist3.train = mtcars[train,]
hist3.test = mtcars[-train,]

fit <- glm(allstar~pt_to+pt_ast+pt_pct+pt_fga+pts_per48#+vop+fac+drbp
          ,data = hist3_2008, family=binomial(link="probit"))
summary(fit)# display results



