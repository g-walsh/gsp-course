### Lienar Equation: y = (a+b*t).unif*amp
# variables
n <- 11 # number of data points
t <- seq(0,10,1)
a <- 1
b <- 0.4
#c.unif <- runif(n)
c.norm <- rnorm(n)
amp <- 0.3

# generate data and calculate "y"
# set.seed(1)
# y1 <- a*sin(b*t)+c.unif*amp # uniform error
y1 <- a+(b*t)+c.norm*amp # Gaussian/normal error

c.norm <- rnorm(n)
y2 <- a+(b*t)+c.norm*amp # Gaussian/normal error

c.norm <- rnorm(n)
y3 <- a+(b*t)+c.norm*amp # Gaussian/normal error


data = data.frame(t,y1,y2,y3)
#ggplot(data) + geom_point(aes(x=t, y=y1, colour="red"), size = 5, shape=1) + geom_point(aes(x=t, y=y2, colour="blue"), size = 5, shape=2) + geom_point(aes(x=t, y=y3, colour="black"), size = 5, shape=3)
meltdata <- melt(data,id="t")
ggplot(meltdata,aes(x=t,y=value,colour=variable,group=variable)) + geom_line() + geom_point(shape=2, size=4)