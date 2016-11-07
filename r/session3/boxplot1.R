library(ggplot2)

set.seed(1234)
dat <- data.frame(cond = factor(rep(c("A","B"), each=200)), rating = c(rnorm(200),rnorm(200, mean=.8)))

#boxplot of both
ggplot(dat, aes(x=cond, y=rating)) + geom_boxplot() + labs(list(title = "Two Box Plots", x = "Treatment", y = "Measurements"))

#density plot of both
ggplot(dat, aes(rating, colour = cond)) + geom_density() + labs(list(title = "Two Density Plots", x = "Measurement", y = "Density"))

#Create a skewed version of the data using binomial
dat.skew <- data.frame(cond = factor(rep(c("A","B"), each=500)), rating = c(rlnorm(500,0,1),rlnorm(500,0.8,1)))

ggplot(dat.skew, aes(rating, colour = cond)) + geom_density() + labs(list(title = "Skewed Density Plots", x = "Measurement", y = "Density")) + xlim(0, 10)

ggplot(dat.skew, aes(x=cond, y=rating)) + geom_boxplot() + labs(list(title = "Skewed Distribution Box Plots", x = "Treatment", y = "Measurements")) + ylim(0,10)