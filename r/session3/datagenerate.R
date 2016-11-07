library(ggplot2)

set.seed(1234)
dat <- data.frame(cond = factor(rep(c("A","B"), each=200)), rating = c(rnorm(200),rnorm(200, mean=.8)))

# Make some noisily increasing data
dat2 <- data.frame(cond = rep(c("A", "B"), each=25),
                  xs = append(1:25, 1:25),
                  ys = append(1:25 + rnorm(25,sd=3), 1:25 + rnorm(25,sd=3)))