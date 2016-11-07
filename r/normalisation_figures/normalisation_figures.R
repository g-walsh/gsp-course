library(reshape)
library(ggplot2)
library(cowplot)

#Lets plot the data from the paper Demidenko (2010)

datatime <- read.csv("~/R/datatime.csv", header=FALSE) #Assume that you have the data as a csv
colnames(datatime) <- c("V1","Group 1","Group 2","Group 3")
meltreal <- melt(datatime,id="V1")
p1 <- ggplot(meltreal,aes(x=V1,y=value,colour=variable,group=variable)) +
  geom_line() +
  geom_point(shape=2, size=4) +
  theme(legend.justification=c(0,1), legend.position=c(0,1)) +
  scale_y_continuous(name=expression('Tumour volume, mm'^ 3)) +
  scale_x_continuous(name=expression('Days after treatment'))

# And lets plot the volume as a relative value (all volume data divided by V0)

relativedata <- datatime
relativedata$`Group 1` <- relativedata$`Group 1`/relativedata$`Group 1`[1]
relativedata$`Group 2` <- relativedata$`Group 2`/relativedata$`Group 2`[1]
relativedata$`Group 3` <- relativedata$`Group 3`/relativedata$`Group 3`[1]
relativemelt <- melt(relativedata,id="V1")
p2 <- ggplot(relativemelt,aes(x=V1,y=value,colour=variable,group=variable)) +
  geom_line() +
  geom_point(shape=2, size=4) +
  theme(legend.justification=c(0,1), legend.position=c(0,1)) +
  scale_y_continuous(name=expression('Relative tumour volume')) +
  scale_x_continuous(name=expression('Days after treatment'))

# Now let's plot the absolute tumour volume on a log scale with a linear fit

p3 <- ggplot(meltreal,aes(x=V1,y=value,colour=variable,group=variable)) +
  geom_line() +
  geom_point(shape=2, size=4) +
  coord_trans(y="log10")  +
  theme(legend.justification=c(0,1), legend.position=c(0,1)) +
  scale_y_continuous(name=expression(paste("Tumour volume, mm"^"3"," on the log scale"))) +
  scale_x_continuous(name=expression('Days after treatment'))

# Normalise data and calculate intercept

meltreallog <- meltreal
meltreallog$value <- log10(meltreallog$value)
ggplot(meltreallog,aes(x=V1,y=value,colour=variable,group=variable)) +
  geom_line() +
  geom_point(shape=2, size=4) +
  stat_smooth(method="lm",formula = "y~x",aes(outfit=fit<<-..y..))
intercepts <- c(fit[1],fit[81],fit[161])

# And lets plot the volume as a relative value (all volume data divided by V0).
# Here we use the previous intercepts calculated from the log-linear fit as the starting V0 rather than the first measurement.

plot4data <- datatime
plot4data$`Group 1` <- plot4data$`Group 1`/(10^intercepts[1])
plot4data$`Group 2` <- plot4data$`Group 2`/(10^intercepts[2])
plot4data$`Group 3` <- plot4data$`Group 3`/(10^intercepts[3])
plot4melt <- melt(plot4data,id="V1")
p4 <- ggplot(plot4melt,aes(x=V1,y=value,colour=variable,group=variable)) +
  geom_line() +
  geom_point(shape=2, size=4) +
  theme(legend.justification=c(0,1), legend.position=c(0,1)) +
  scale_y_continuous(name=expression(paste("Relative tumour volume"))) +
  scale_x_continuous(name=expression('Days after treatment'))

# Plot the final 2x2 grid

plot_grid(p1, p2, p3, p4, labels=c("A", "B","C","D"), ncol = 2, nrow = 2)