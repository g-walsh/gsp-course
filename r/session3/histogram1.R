library(ggplot2)

set.seed(1234)
dat <- data.frame(cond = factor(rep(c("A","B"), each=200)), rating = c(rnorm(200),rnorm(200, mean=.8)))

#define subsets of dat for only conditions A or B
dat.a = dat[which(dat$cond == "A"),]
dat.b = dat[which(dat$cond == "B"),]

#plot condition A histogram
ggplot(dat.a, aes(rating)) + geom_histogram(colour="black", fill="light blue", binwidth=.5, alpha=.5, position = "identity") + labs(list(title = "Histogram of treatment A", x = "Measurement", y = "Count"))

#plot both conditions histograms on a single figure
ggplot(dat, aes(rating, fill = cond)) + geom_histogram(binwidth=.5, alpha=.5, position = "identity") + labs(list(title = "Two Histograms", x = "Measurement", y = "Count"))