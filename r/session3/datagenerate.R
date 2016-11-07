set.seed(641)
# Make some noisily increasing data
dat2 <- data.frame(cond = rep(c("A", "B"), each=25),
                  xvar = append(1:25, 1:25),
                  yvar = append(1:25 + rnorm(25,sd=3), 1:25 + rnorm(25,sd=3)))