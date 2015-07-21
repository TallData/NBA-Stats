sink("C:\\Users\\Kenneth\\Desktop\\scipt_output.txt")
print("hello")
print("This is a test")
sink()

getwd()
list.files()

class(team_hist)
summary(team_hist)
class(team_hist$o_pts)
class(team_hist$name)


num_check <- colwise(is.numeric)(team_hist)

hist(team_hist$o_pts)
test<- team_hist
test$name <-as.character(test$name)

??qplot
  
  # grouped by number of gears (indicated by color)
  qplot(o_pts, data=team_hist, geom="density", fill=name,  
        main="Distribution of Gas Milage", xlab="Miles Per Gallon", 
        ylab="Density")

# particularly when there are many different things being stacked
ggplot(team_hist, aes(year, fill=lgID)) + geom_bar()  

p <- ggplot(team_hist, aes(x=year,y=o_pts))
p + stat_sum(aes(colour=name))


