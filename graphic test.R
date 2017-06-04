y <- rt(200, df = 5)
qqnorm(y); qqline(y, col = 4)

c1 <- ggplot(data = hist3_2008, aes(x=points, colour = confID))
#c1 <- ggplot(data = hist3_2008, aes(x=points, colour = confID))
c1a <-  c1 + geom_density() + theme(legend.position="none")
c1b <-  c1 + geom_bar(binwidth = 200) + theme(legend.position="none")
c2 <- ggplot(data = hist3_2008, aes(x=points, fill = confID))
c2 <- c2 + geom_density(position = "fill") + theme(legend.position="none")

intsl <- hist3_2008 %>% #group_by(confID) %>% 
  summarize(q25    = quantile(points,0.25),
            q75    = quantile(points,0.75),
            norm25 = qnorm( 0.25),
            norm75 = qnorm( 0.75),
            slope  = (q25 - q75) / (norm25 - norm75),
            int    = q25 - slope * norm25) %>%
  select(slope, int) 

c3 <- ggplot(hist3_2008, aes(sample=points, colour = confID))
c3 <- c3 +  stat_qq(distribution=qnorm) + 
  geom_abline(data=intsl, aes(intercept=int, slope=slope)) +
  #facet_wrap(~confID,nrow=1) +
  ylab("Point Q-Q Plot") + theme(legend.position=c(.9, .2))
                                   #"bottom")



grid.arrange(c1b, c2, c1a, c3, nrow=2, ncol=2)


