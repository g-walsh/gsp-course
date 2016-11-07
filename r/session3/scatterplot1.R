library(ggplot2)

set.seed(1234)
dat <- data.frame(cond = factor(rep(c("A","B"), each=200)), rating = c(rnorm(200),rnorm(200, mean=.8)))

#define subsets of dat for only conditions A or B
dat.a = dat[which(dat$cond == "A"),]
dat.b = dat[which(dat$cond == "B"),]

#Scatterlot

ggplot(dat, aes(y=rating)) + geom_point(shape=1) + labs(list(title = "Two Box Plots", x = "Treatment", y = "Measurements"))

