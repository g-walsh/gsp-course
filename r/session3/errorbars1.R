#import chicken weight data set
cw <- chickwts

#ensure that you have the summarySE.R script downloaded
tcw <- summarySE(cw, measurevar = "weight", groupvars = "feed")

# Create bar chart of chicken weight dataset with s.e.m bars
ggplot(tcw, aes(x=feed, y=weight, fill=feed)) + 
  geom_bar(position=position_dodge(), stat="identity", colour="black") + 
  geom_errorbar(aes(ymin=weight-se, ymax=weight+se),width=.3,size=0.7) +
  labs(list(title = "Chicken Weight with s.e.m bars", x = "Feed", y = "Weight"))

# Same bar chart with s.d. bars

ggplot(tcw, aes(x=feed, y=weight, fill=feed)) + 
  geom_bar(position=position_dodge(), stat="identity", colour="black") + 
  geom_errorbar(aes(ymin=weight-sd, ymax=weight+sd),width=.3,size=0.7) +
  labs(list(title = "Chicken Weight with s.d. bars", x = "Feed", y = "Weight"))

# and again but with 95% CI bars

ggplot(tcw, aes(x=feed, y=weight, fill=feed)) + 
  geom_bar(position=position_dodge(), stat="identity", colour="black") + 
  geom_errorbar(aes(ymin=weight-ci, ymax=weight+ci),width=.3,size=0.7) +
  labs(list(title = "Chicken Weight with 95% CI bars", x = "Feed", y = "Weight"))